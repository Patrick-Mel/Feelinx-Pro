from datetime import timedelta
from celery import shared_task
from django.utils import timezone
from .models import Transaction, Subscription, Plan

@shared_task
def activate_subscription_task(transaction_id_str):
    try:
        tx = Transaction.objects.get(id=transaction_id_str)
        if tx.status != 'success':
            return False

        profile = tx.profile
        plan = tx.plan

        # Calculate expiration
        now = timezone.now()
        existing_sub = Subscription.objects.filter(profile=profile, status='active').first()

        if existing_sub and existing_sub.expires_at > now:
            start_date = existing_sub.expires_at
        else:
            start_date = now

        expires_at = start_date + timedelta(days=plan.duration_days)

        sub = Subscription.objects.create(
            profile=profile,
            plan=plan,
            started_at=start_date,
            expires_at=expires_at,
            status='active'
        )

        # Update profile premium flag
        profile.is_premium = True
        profile.premium_until = expires_at
        profile.save()

        return True
    except Exception as e:
        print(f"Error activating subscription: {e}")
        return False


@shared_task
def expire_subscriptions_task():
    now = timezone.now()
    expired_subs = Subscription.objects.filter(status='active', expires_at__lte=now)

    for sub in expired_subs:
        sub.status = 'expired'
        sub.save()
        profile = sub.profile
        
        # Check if profile has any other active subs
        has_active = Subscription.objects.filter(profile=profile, status='active', expires_at__gt=now).exists()
        if not has_active:
            profile.is_premium = False
            profile.save()

    return expired_subs.count()
