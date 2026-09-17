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
  List<dynamic> _allProfiles = [];
  List<dynamic> _filteredProfiles = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  final List<Map<String, String>> _categories = const [
    {"code": "all", "label": "🔥 Tous les profils"},
    {"code": "serious", "label": "💘 Looking for Love"},
    {"code": "casual", "label": "☕ Coffee Date"},
    {"code": "verified", "label": "🛡️ Profils Vérifiés"},
    {"code": "networking", "label": "💼 Networking Pro"},
  ];

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
          _allProfiles = list;
          _applyFilter(_selectedFilter);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String filterCode) {
    setState(() {
      _selectedFilter = filterCode;
      if (filterCode == 'all') {
        _filteredProfiles = List.from(_allProfiles);
      } else if (filterCode == 'verified') {
        _filteredProfiles = _allProfiles.where((p) => p['is_verified'] == true).toList();
      } else {
        _filteredProfiles = _allProfiles.where((p) => p['intention'] == filterCode).toList();
        if (_filteredProfiles.isEmpty) {
          _filteredProfiles = List.from(_allProfiles);
        }
      }
    });
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
            // Tinder Explore Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedFilter == cat['code'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FxChip(
                      label: cat['label']!,
                      isSelected: isSelected,
                      onTap: () => _applyFilter(cat['code']!),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),

            // Profile Grid
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
                    : _filteredProfiles.isEmpty
                        ? const Center(child: Text("Aucun profil correspondant dans ce canal."))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filteredProfiles.length,
                            itemBuilder: (context, index) {
                              final p = _filteredProfiles[index];
                              final photos = p['photos'] as List? ?? [];
                              final photoUrl = photos.isNotEmpty ? photos.first['url'] : '';
                              final displayName = p['full_name'] ?? p['first_name'] ?? 'Membre';

                              return GestureDetector(
                                onTap: () => context.push('/profile/public/${p['id']}'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FxColors.darkCard,
                                    borderRadius: BorderRadius.circular(16),
                                    image: (photoUrl != null && photoUrl.isNotEmpty)
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
                                        colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "$displayName, ${p['age'] ?? 24}",
                                                style: FxTypography.titleMedium.copyWith(color: Colors.white, fontSize: 15),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (p['is_verified'] == true) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified, size: 16, color: FxColors.info),
                                            ],
                                          ],
                                        ),
                                        Text("${p['city']} • ${p['distance_km'] ?? 3} km", style: FxTypography.labelSmall.copyWith(color: Colors.white70)),
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
