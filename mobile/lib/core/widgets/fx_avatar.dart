import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/colors.dart';

class FxAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isVerified;
  final bool isOnline;
  final VoidCallback? onTap;

  const FxAvatar({
    super.key,
    this.imageUrl,
    this.radius = 28,
    this.isVerified = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: isVerified ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
            decoration: isVerified
                ? const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [FxColors.primaryCoral, FxColors.accentGold],
                    ),
                  )
                : null,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: FxColors.darkCard,
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(imageUrl!) as ImageProvider
                  : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? Icon(Icons.person, size: radius * 1.1, color: FxColors.darkTextSecondary)
                  : null,
            ),
          ),
          if (isOnline)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: FxColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
