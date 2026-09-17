import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_chip.dart';
import '../../../../core/network/dio_client.dart';

class PublicProfileScreen extends StatefulWidget {
  final String profileId;

  const PublicProfileScreen({super.key, required this.profileId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  dynamic _profile;
  bool _isLoading = true;
  int _currentPhotoIndex = 0;
  final PageController _photoPageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('profiles/${widget.profileId}/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _profile = res.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showReportDialog() async {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Signaler ce profil"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Raison du signalement (faux profil, harcèlement...)",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final dio = DioClient().dio;
                final userId = _profile?['user']?['id'] ?? widget.profileId;
                await dio.post('safety/reports/', data: {
                  'reported_user_id': userId,
                  'reason': 'other',
                  'details': reasonController.text,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signalement envoyé. Merci de nous aider à garder Feelinx sûr !")),
                  );
                }
              } catch (_) {}
            },
            child: const Text("Envoyer", style: TextStyle(color: FxColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser() async {
    try {
      final dio = DioClient().dio;
      final userId = _profile?['user']?['id'] ?? widget.profileId;
      await dio.post('safety/block/', data: {'blocked_user_id': userId});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur bloqué.")),
        );
        Navigator.pop(context);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photos = _profile?['photos'] as List? ?? [];

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final surfaceBg = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDarkMode ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Photo Carousel Header
          SliverAppBar(
            expandedHeight: 440,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: surfaceBg,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.flag, color: FxColors.error),
                          title: const Text("Signaler ce profil", style: TextStyle(color: FxColors.error)),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showReportDialog();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.block, color: textSecondary),
                          title: Text("Bloquer cet utilisateur", style: TextStyle(color: textPrimary)),
                          onTap: () {
                            Navigator.pop(ctx);
                            _blockUser();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (photos.isNotEmpty)
                    PageView.builder(
                      controller: _photoPageController,
                      itemCount: photos.length,
                      onPageChanged: (idx) => setState(() => _currentPhotoIndex = idx),
                      itemBuilder: (context, index) {
                        final rawPhotoUrl = photos[index]['url'] ?? photos[index]['image'] ?? '';
                        final photoUrl = DioClient.resolveImageUrl(rawPhotoUrl);
                        return CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  else
                    Container(
                      color: FxColors.darkCard,
                      child: const Center(
                        child: Icon(Icons.person, size: 96, color: FxColors.darkTextSecondary),
                      ),
                    ),

                  // Vignette Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // Photo Indicator Dots if multiple photos
                  if (photos.length > 1)
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (idx) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPhotoIndex == idx ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == idx ? FxColors.primaryCoral : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Back Button
                  Positioned(
                    top: 48,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Basic Profile Info overlay on cover
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${_profile['first_name']}, ${_profile['age'] ?? 24}",
                              style: FxTypography.displayMedium.copyWith(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            if (_profile['is_verified'] == true) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, color: FxColors.info, size: 24),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Content Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: FxColors.primaryCoral),
                      const SizedBox(width: 4),
                      Text(
                        "${_profile['city']} • à ${_profile['distance_km'] ?? 3} km de toi",
                        style: FxTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Intention Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: FxColors.primaryCoral.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: FxColors.primaryCoral.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, size: 16, color: FxColors.primaryCoral),
                        const SizedBox(width: 6),
                        Text(
                          "Recherche : ${_profile['intention'] ?? 'Relation sérieuse'}",
                          style: FxTypography.bodyMedium.copyWith(color: FxColors.primaryCoral, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bio Section
                  Text("À propos de moi", style: FxTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FxColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _profile['bio'] != null && _profile['bio'].toString().isNotEmpty
                          ? _profile['bio']
                          : "Passions, sourires et beaux échanges à partager sur Feelinx.",
                      style: FxTypography.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9), height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Interests Section
                  Text("Centres d'intérêt", style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ((_profile['interests'] as List? ?? [])).map((intItem) {
                      return FxChip(
                        label: "${intItem['name_fr']}",
                        isSelected: true,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons (Like & Chat)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Vous avez envoyé un Like à ${_profile['first_name']} !")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FxColors.primaryCoral,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.favorite, color: Colors.white),
                          label: const Text("Envoyer un Like", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
