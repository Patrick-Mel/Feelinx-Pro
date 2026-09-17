import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_avatar.dart';
import '../../../../core/widgets/fx_shimmer_box.dart';
import '../../../../core/network/dio_client.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<dynamic> _matches = [];
  bool _isLoading = true;
  int _likesReceivedCount = 12;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final res = await dio.get('matches/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _matches = res.data ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final cardBg = isDark ? FxColors.darkSurface : FxColors.lightSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Matchs", style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Qui m'a liké / Super Likes banner
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tous tes likes et matchs sont 100% gratuits et visibles !")),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [FxColors.secondaryIndigo, FxColors.primaryCoral]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: FxColors.accentGold, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$_likesReceivedCount personnes t'ont liké(e) !", style: FxTypography.titleMedium.copyWith(color: Colors.white)),
                            const SizedBox(height: 2),
                            Text("Découvre tes coups de cœur gratuitement !", style: FxTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text("Nouveaux Matchs", style: FxTypography.titleLarge.copyWith(color: textPrimary)),
              const SizedBox(height: 16),

              _isLoading
                  ? SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (_, __) => const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: FxShimmerBox(width: 70, height: 70, borderRadius: 35),
                        ),
                      ),
                    )
                  : _matches.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                          child: Center(
                            child: Text("Aucun match pour le moment. Continue à swiper !", style: TextStyle(color: textSecondary)),
                          ),
                        )
                      : SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _matches.length,
                            itemBuilder: (context, index) {
                              final m = _matches[index];
                              final other = m['other_profile'];
                              final photos = other['photos'] as List? ?? [];
                              final rawPhotoUrl = photos.isNotEmpty ? (photos.first['url'] ?? photos.first['image'] ?? '') : '';
                              final photoUrl = DioClient.resolveImageUrl(rawPhotoUrl);

                              return GestureDetector(
                                onTap: () {
                                  final convId = m['conversation_id'];
                                  if (convId != null) context.push('/chat/$convId');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    children: [
                                      FxAvatar(
                                        imageUrl: photoUrl,
                                        radius: 32,
                                        isVerified: other['is_verified'] == true,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(other['first_name'] ?? 'Membre', style: FxTypography.labelSmall.copyWith(color: textPrimary)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
