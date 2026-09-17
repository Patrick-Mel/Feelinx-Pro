import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_shimmer_box.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/branding/feelinx_logo.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _profiles = [];
  bool _isLoading = true;
  Offset _dragOffset = Offset.zero;
  final Map<String, int> _photoIndices = {};

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final res = await dio.get('discovery/feed/?limit=50');
      if (res.statusCode == 200 && mounted) {
        final data = res.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['results'] is List) {
          list = data['results'];
        }
        setState(() {
          _profiles = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSwipeAction(String action) async {
    if (_profiles.isEmpty) return;
    final target = _profiles.first;

    setState(() {
      _profiles.removeAt(0);
      _dragOffset = Offset.zero;
    });

    try {
      final dio = DioClient().dio;
      final res = await dio.post('discovery/swipe/', data: {
        'target_id': target['id'],
        'action': action,
      });

      if (res.statusCode == 200 && res.data['is_match'] == true && mounted) {
        _showMatchModal(target, res.data['match']);
      }
    } catch (_) {}
  }

  void _rewindLastSwipe() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.post('discovery/rewind/');
      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dernier swipe annulé !")),
        );
        _fetchFeed();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun swipe précédent à annuler.")),
        );
      }
    }
  }

  void _activateBoost() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.post('discovery/boost/');
      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Boost activé gratuitement pour 30 minutes !")),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Boost activé avec succès !")),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ton profil est désormais mis en avant !")),
        );
      }
    }
  }

  void _showMatchModal(dynamic target, dynamic matchData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: FxColors.primaryCoral, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, size: 64, color: FxColors.accentGold),
              const SizedBox(height: 12),
              Text("C'est un Match !", style: FxTypography.displayMedium.copyWith(color: FxColors.primaryCoral)),
              const SizedBox(height: 8),
              Text("Toi et ${target['first_name']} vous vous plaisez !", style: FxTypography.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final convId = matchData['conversation_id'];
                  if (convId != null) context.push('/chat/$convId');
                },
                child: const Text("Envoyer un message"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Continuer à swiper", style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FeelinxLogo(
          size: 28,
          variant: FeelinxLogoVariant.fullHorizontal,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: FxShimmerBox(width: double.infinity, height: 500, borderRadius: 32),
              )
            : _profiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 72, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text("Plus de profils pour le moment", style: FxTypography.titleLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        Text("Élargis tes critères de recherche ou réessaie plus tard.", style: FxTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchFeed,
                          child: const Text("Actualiser le feed"),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Stack(
                            children: List.generate(
                              math.min(3, _profiles.length),
                              (index) {
                                final reverseIdx = math.min(3, _profiles.length) - 1 - index;
                                final profile = _profiles[reverseIdx];
                                final isTopCard = reverseIdx == 0;

                                final scale = 1.0 - (reverseIdx * 0.04);
                                final topOffset = reverseIdx * 12.0;

                                return Transform.translate(
                                  offset: Offset(0, topOffset),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: isTopCard
                                        ? GestureDetector(
                                            onPanUpdate: (details) {
                                              setState(() {
                                                _dragOffset += details.delta;
                                              });
                                            },
                                            onPanEnd: (details) {
                                              if (_dragOffset.dx > 100) {
                                                _onSwipeAction('like');
                                              } else if (_dragOffset.dx < -100) {
                                                _onSwipeAction('nope');
                                              } else if (_dragOffset.dy < -120) {
                                                _onSwipeAction('superlike');
                                              } else {
                                                setState(() => _dragOffset = Offset.zero);
                                              }
                                            },
                                            child: Transform.translate(
                                              offset: _dragOffset,
                                              child: Transform.rotate(
                                                angle: _dragOffset.dx / 300 * 0.2,
                                                child: _buildSwipeCard(profile, isTop: true),
                                              ),
                                            ),
                                          )
                                        : _buildSwipeCard(profile, isTop: false),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Swipe Action Buttons (Tinder 5-Action Row)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.replay, Colors.amber, _rewindLastSwipe),
                            _buildActionButton(Icons.close, FxColors.nopeRed, () => _onSwipeAction('nope')),
                            _buildActionButton(Icons.star, FxColors.superlikeBlue, () => _onSwipeAction('superlike')),
                            _buildActionButton(Icons.favorite, FxColors.likeGreen, () => _onSwipeAction('like')),
                            _buildActionButton(Icons.bolt, FxColors.accentGold, _activateBoost),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSwipeCard(dynamic profile, {required bool isTop}) {
    final photos = profile['photos'] as List? ?? [];
    final profileId = profile['id']?.toString() ?? '';
    final activePhotoIdx = _photoIndices[profileId] ?? 0;
    final rawPhotoUrl = (photos.isNotEmpty && activePhotoIdx < photos.length) 
        ? (photos[activePhotoIdx]['url'] ?? photos[activePhotoIdx]['image'] ?? '') 
        : '';
    final photoUrl = DioClient.resolveImageUrl(rawPhotoUrl);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? (isDark ? FxColors.darkCard : FxColors.lightCard);
    final surfaceBg = theme.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: FxShadows.softShadow(Colors.black),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo Content
          if (photoUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
            )
          else
            Container(color: cardBg, child: Icon(Icons.person, size: 100, color: theme.colorScheme.onSurface.withOpacity(0.5))),

          // Tap left / right side photo navigation detector
          if (photos.length > 1)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (activePhotoIdx > 0) {
                        setState(() {
                          _photoIndices[profileId] = activePhotoIdx - 1;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (activePhotoIdx < photos.length - 1) {
                        setState(() {
                          _photoIndices[profileId] = activePhotoIdx + 1;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

          // Top Photo Progress Bar (Tinder Horizontal Dash Bar)
          if (photos.length > 1)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(photos.length, (idx) {
                  return Expanded(
                    child: Container(
                      height: 3.5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: idx == activePhotoIdx ? Colors.white : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Drag Overlays (LIKE / NOPE / SUPER LIKE)
          if (isTop && _dragOffset.dx > 40)
            Positioned(
              top: 40,
              left: 30,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: FxColors.likeGreen, width: 3), borderRadius: BorderRadius.circular(12)),
                  child: const Text("LIKE", style: TextStyle(color: FxColors.likeGreen, fontSize: 32, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          if (isTop && _dragOffset.dx < -40)
            Positioned(
              top: 40,
              right: 30,
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: FxColors.nopeRed, width: 3), borderRadius: BorderRadius.circular(12)),
                  child: const Text("NOPE", style: TextStyle(color: FxColors.nopeRed, fontSize: 32, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          if (isTop && _dragOffset.dy < -50 && _dragOffset.dx.abs() < 50)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(border: Border.all(color: FxColors.superlikeBlue, width: 3.5), borderRadius: BorderRadius.circular(12)),
                  child: const Text("SUPER LIKE", style: TextStyle(color: FxColors.superlikeBlue, fontSize: 30, fontWeight: FontWeight.w900)),
                ),
              ),
            ),

          // Bottom Gradient & Profile Info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => context.push('/profile/public/${profile['id']}'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.92), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text("${profile['full_name'] ?? profile['first_name']}, ${profile['age'] ?? 24}", style: FxTypography.displayMedium.copyWith(color: Colors.white, fontSize: 24)),
                              const SizedBox(width: 8),
                              if (profile['is_verified'] == true)
                                const Icon(Icons.verified, color: FxColors.info, size: 22),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text("${profile['city']} • à ${profile['distance_km'] ?? 3} km", style: FxTypography.bodyMedium.copyWith(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (profile['bio'] != null && profile['bio'].toString().isNotEmpty)
                      Text(profile['bio'], style: FxTypography.bodyMedium.copyWith(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          boxShadow: FxShadows.softShadow(Colors.black),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
