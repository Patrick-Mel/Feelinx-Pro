import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/colors.dart';
import '../network/dio_client.dart';

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
    final resolvedUrl = DioClient.resolveImageUrl(imageUrl);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? FxColors.darkCard : FxColors.lightCard;
    final iconColor = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;

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
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardBg,
              ),
              child: ClipOval(
                child: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: resolvedUrl,
                        fit: BoxFit.cover,
                        width: radius * 2,
                        height: radius * 2,
                        placeholder: (context, url) => Container(
                          color: cardBg,
                          child: Center(
                            child: SizedBox(
                              width: radius * 0.8,
                              height: radius * 0.8,
                              child: CircularProgressIndicator(strokeWidth: 2, color: FxColors.primaryCoral),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: cardBg,
                          child: Icon(Icons.person, size: radius * 1.1, color: iconColor),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.person, size: radius * 1.1, color: iconColor),
                      ),
              ),
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
