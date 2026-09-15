from rest_framework import permissions

class IsOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to edit or view it.
    """
    def has_object_permission(self, request, view, obj):
        if hasattr(obj, 'user'):
            return obj.user == request.user
        if hasattr(obj, 'profile'):
            return obj.profile.user == request.user
        return obj == request.user


class IsPremium(permissions.BasePermission):
    """
    Allows access only to users with an active premium subscription.
    """
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        profile = getattr(request.user, 'profile', None)
        if not profile:
            return False
        return profile.is_premium_active


class IsNotBlocked(permissions.BasePermission):
    """
    Checks if the target user is not blocked by or blocking the current user.
    """
    def has_object_permission(self, request, view, obj):
        from apps.safety.models import Block
        target_user = getattr(obj, 'user', obj)
        if not hasattr(target_user, 'id'):
            return True
        
        is_blocked = Block.objects.filter(
            blocker=request.user, blocked=target_user
        ).exists() or Block.objects.filter(
            blocker=target_user, blocked=request.user
        ).exists()
        
        return not is_blocked
