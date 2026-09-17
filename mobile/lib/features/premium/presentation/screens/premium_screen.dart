import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {

  void _activateFreeVip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: FxColors.accentGold),
            SizedBox(width: 8),
            Text("Statut Feelinx VIP & Pass Illimité Activé (100% Gratuit) !"),
          ],
        ),
        backgroundColor: FxColors.success,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final cardBg = isDark ? FxColors.darkCard : FxColors.lightCard;
    final borderBg = isDark ? FxColors.darkBorder : FxColors.lightBorder;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Feelinx VIP - 100% Gratuit", style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // VIP Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [FxColors.primaryCoral, FxColors.secondaryIndigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: FxColors.primaryCoral.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars_rounded, color: FxColors.accentGold, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Feelinx VIP & Pass Illimité",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "100% GRATUIT & OFFERS",
                        style: TextStyle(color: FxColors.primaryCoral, fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Toutes les fonctionnalités premium sont désormais déverrouillées sans aucun frais pour tous nos membres !",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Feature List
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Vos Privilèges Inclus :", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),

                  _buildVipFeatureTile(
                    context,
                    icon: Icons.favorite_rounded,
                    color: FxColors.primaryCoral,
                    title: "Likes Illimités",
                    subtitle: "Swipe autant de profils que tu veux sans aucune restriction.",
                    cardBg: cardBg,
                    borderBg: borderBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildVipFeatureTile(
                    context,
                    icon: Icons.visibility_rounded,
                    color: FxColors.secondaryIndigo,
                    title: "Voir Qui T'a Liké",
                    subtitle: "Découvre instantanément les personnes qui s'intéressent à toi.",
                    cardBg: cardBg,
                    borderBg: borderBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildVipFeatureTile(
                    context,
                    icon: Icons.star_rounded,
                    color: FxColors.accentGold,
                    title: "Super Likes Illimités",
                    subtitle: "Fais ressortir ton profil en envoyant des Super Likes sans compter.",
                    cardBg: cardBg,
                    borderBg: borderBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildVipFeatureTile(
                    context,
                    icon: Icons.replay_rounded,
                    color: Colors.teal,
                    title: "Rewind Gratuit (Retour en arrière)",
                    subtitle: "Annule ton dernier swipe si tu as changé d'avis par erreur.",
                    cardBg: cardBg,
                    borderBg: borderBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildVipFeatureTile(
                    context,
                    icon: Icons.rocket_launch_rounded,
                    color: Colors.purpleAccent,
                    title: "Boost Gratuit",
                    subtitle: "Multiplie ta visibilité par 10 pendant 30 minutes.",
                    cardBg: cardBg,
                    borderBg: borderBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildVipFeatureTile(
                    context,
                    icon: Icons.public_rounded,
                    color: Colors.blueAccent,
                    title: "Feelinx Passport",
                    subtitle: "Voyage virtuellement et match dans la ville de ton choix.",
                    cardBg: cardBg,
                    borderBg: borderBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              FxButton(
                text: "PROFITER DU VIP GRATUIT",
                icon: Icons.workspace_premium_rounded,
                onPressed: _activateFreeVip,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVipFeatureTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color borderBg,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderBg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_rounded, color: FxColors.success, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
