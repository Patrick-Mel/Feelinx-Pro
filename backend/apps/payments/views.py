from django.utils import timezone
from rest_framework import status, permissions, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from .models import Plan, Subscription, Transaction
from .serializers import PlanSerializer, SubscribeRequestSerializer, TransactionSerializer, SubscriptionSerializer
from .providers.momo import MTNMoMoProvider
from .providers.orange import OrangeMoneyProvider
from .providers.mock import MockPaymentProvider
from .tasks import activate_subscription_task

class PlanListView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    queryset = Plan.objects.filter(is_active=True)
    serializer_class = PlanSerializer
    pagination_class = None


class SubscribeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        request=SubscribeRequestSerializer,
        responses={200: TransactionSerializer}
    )
    def post(self, request):
        serializer = SubscribeRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        plan_code = serializer.validated_data['plan_code']
        provider = serializer.validated_data['provider']
        phone_number = serializer.validated_data['phone_number']
        profile = request.user.profile

        try:
            plan = Plan.objects.get(code=plan_code, is_active=True)
        except Plan.DoesNotExist:
            return Response({"success": False, "message": "Formule d'abonnement introuvable."}, status=status.HTTP_404_NOT_FOUND)

        # Create Pending Transaction
        tx = Transaction.objects.create(
            profile=profile,
            plan=plan,
            amount_xaf=plan.price_xaf,
            provider=provider,
            phone_number=phone_number,
            status='pending'
        )

        # Trigger payment provider
        if provider == 'mtn':
            momo = MTNMoMoProvider()
            res = momo.request_to_pay(str(tx.id), phone_number, plan.price_xaf)
            if res.get('success'):
                tx.provider_reference = res.get('reference_id')
                tx.save()
            else:
                tx.status = 'failed'
                tx.save()

        elif provider == 'orange':
            om = OrangeMoneyProvider()
            res = om.initiate_payment(str(tx.id), phone_number, plan.price_xaf)
            if res.get('success'):
                tx.provider_reference = res.get('reference_id')
                tx.save()
            else:
                tx.status = 'failed'
                tx.save()

        elif provider == 'mock':
            mock = MockPaymentProvider()
            res = mock.initiate_payment(str(tx.id), phone_number, plan.price_xaf)
            tx.status = 'success'
            tx.completed_at = timezone.now()
            tx.provider_reference = res.get('reference_id')
            tx.save()
            
            # Immediately activate subscription for mock dev
            activate_subscription_task(str(tx.id))

        return Response(TransactionSerializer(tx).data, status=status.HTTP_200_OK)


class TransactionStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, transaction_id):
        try:
            tx = Transaction.objects.get(id=transaction_id, profile=request.user.profile)
            
            # If pending, query status from provider
            if tx.status == 'pending':
                if tx.provider == 'mtn' and tx.provider_reference:
                    momo = MTNMoMoProvider()
                    st = momo.check_status(tx.provider_reference)
                    if st.get('status') == 'success':
                        tx.status = 'success'
                        tx.completed_at = timezone.now()
                        tx.save()
                        activate_subscription_task(str(tx.id))
                    elif st.get('status') == 'failed':
                        tx.status = 'failed'
                        tx.save()

            return Response(TransactionSerializer(tx).data)
        except Transaction.DoesNotExist:
            return Response({"success": False, "message": "Transaction introuvable."}, status=status.HTTP_404_NOT_FOUND)


class MTNWebhookView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        data = request.data
        ref_id = data.get("externalId") or data.get("referenceId")
        momo_status = data.get("status")

        if ref_id:
            try:
                tx = Transaction.objects.get(id=ref_id)
                if tx.status == 'pending':
                    if momo_status == 'SUCCESSFUL':
                        tx.status = 'success'
                        tx.completed_at = timezone.now()
                        tx.raw_response = data
                        tx.save()
                        activate_subscription_task.delay(str(tx.id))
                    elif momo_status == 'FAILED':
                        tx.status = 'failed'
                        tx.raw_response = data
                        tx.save()
            except Transaction.DoesNotExist:
                pass

        return Response({"status": "received"})


class OrangeWebhookView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        data = request.data
        order_id = data.get("order_id")
        om_status = data.get("status")

        if order_id:
            try:
                tx = Transaction.objects.get(id=order_id)
                if tx.status == 'pending':
                    if om_status == 'SUCCESS':
                        tx.status = 'success'
                        tx.completed_at = timezone.now()
                        tx.raw_response = data
                        tx.save()
                        activate_subscription_task.delay(str(tx.id))
                    else:
                        tx.status = 'failed'
                        tx.raw_response = data
                        tx.save()
            except Transaction.DoesNotExist:
                pass

        return Response({"status": "received"})


class SubscriptionDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        sub = Subscription.objects.filter(profile=request.user.profile, status='active').first()
        if not sub:
            return Response({"is_active": False, "subscription": None})
        return Response({"is_active": True, "subscription": SubscriptionSerializer(sub).data})


class CancelSubscriptionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        sub = Subscription.objects.filter(profile=request.user.profile, status='active').first()
        if sub:
            sub.auto_renew = False
            sub.save()
            return Response({"success": True, "message": "Renouvellement automatique désactivé."})
        return Response({"success": False, "message": "Aucun abonnement actif trouvé."})
