import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_chip.dart';
import '../../../../core/widgets/fx_shimmer_box.dart';
import '../../../../core/network/dio_client.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  List<dynamic> _profiles = [];
  bool _isLoading = true;
  String _selectedFilter = 'near_me';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorer", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FxChip(label: "Près de moi", isSelected: _selectedFilter == 'near_me', onTap: () => setState(() => _selectedFilter = 'near_me')),
                  const SizedBox(width: 8),
                  FxChip(label: "Nouveaux", isSelected: _selectedFilter == 'new', onTap: () => setState(() => _selectedFilter = 'new')),
                  const SizedBox(width: 8),
                  FxChip(label: "En ligne", isSelected: _selectedFilter == 'online', onTap: () => setState(() => _selectedFilter = 'online')),
                  const SizedBox(width: 8),
                  FxChip(label: "Même intention", isSelected: _selectedFilter == 'intention', onTap: () => setState(() => _selectedFilter = 'intention')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchFeed,
                color: FxColors.primaryCoral,
                child: _isLoading
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 6,
                        itemBuilder: (_, __) => const FxShimmerBox(width: double.infinity, height: 200, borderRadius: 16),
                      )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _profiles.length,
                      itemBuilder: (context, index) {
                        final p = _profiles[index];
                        final photos = p['photos'] as List? ?? [];
                        final photoUrl = photos.isNotEmpty ? photos.first['url'] : '';

                        return GestureDetector(
                          onTap: () => context.push('/profile/public/${p['id']}'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FxColors.darkCard,
                              borderRadius: BorderRadius.circular(16),
                              image: photoUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(photoUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("${p['first_name']}, ${p['age'] ?? 24}", style: FxTypography.titleMedium.copyWith(color: Colors.white)),
                                      if (p['is_verified'] == true) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, size: 16, color: FxColors.info),
                                      ],
                                    ],
                                  ),
                                  Text("${p['city']} • ${p['distance_km'] ?? 3}km", style: FxTypography.labelSmall.copyWith(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
