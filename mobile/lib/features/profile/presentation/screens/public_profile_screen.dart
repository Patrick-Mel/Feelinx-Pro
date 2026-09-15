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
                    const SnackBar(content: Text("Signalement envoyé. Merci de nous aider à garder Feelinx sûr ! 🛡️")),
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
    final photoUrl = photos.isNotEmpty ? photos.first['url'] : '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: FxColors.darkSurface,
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
                          leading: const Icon(Icons.block, color: FxColors.darkTextSecondary),
                          title: const Text("Bloquer cet utilisateur"),
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
              background: photoUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover)
                  : Container(color: FxColors.darkCard),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("${_profile['first_name']}, ${_profile['age'] ?? 24}", style: FxTypography.displayMedium),
                      if (_profile['is_verified'] == true) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: FxColors.info, size: 24),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("${_profile['city']} • à ${_profile['distance_km'] ?? 3} km", style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary)),
                  const SizedBox(height: 16),

                  // Intention Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: FxColors.primaryCoral.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text("Recherche : ${_profile['intention'] ?? 'Relation sérieuse'}", style: FxTypography.bodyMedium.copyWith(color: FxColors.primaryCoral, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),

                  Text("À propos", style: FxTypography.titleLarge),
                  const SizedBox(height: 8),
                  Text(_profile['bio'] ?? 'Aucune bio rédigée pour le moment.', style: FxTypography.bodyLarge),
                  const SizedBox(height: 24),

                  Text("Centres d'intérêt", style: FxTypography.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ((_profile['interests'] as List? ?? [])).map((intItem) {
                      return FxChip(label: "${intItem['emoji']} ${intItem['name_fr']}");
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
