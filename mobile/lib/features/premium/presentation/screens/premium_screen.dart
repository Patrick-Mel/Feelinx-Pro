import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_phone_field.dart';
import '../../../../core/network/dio_client.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlanCode = 'premium_3m';
  bool _isLoading = false;
  final TextEditingController _momoPhoneController = TextEditingController();

  final List<Map<String, dynamic>> _plans = const [
    {"code": "premium_1m", "title": "1 Mois", "price": "1 000 FCFA", "popular": false},
    {"code": "premium_3m", "title": "3 Mois", "price": "2 500 FCFA", "popular": true, "save": "-17%"},
    {"code": "premium_12m", "title": "12 Mois", "price": "10 000 FCFA", "popular": false, "save": "-50%"},
  ];

  void _openPaymentSheet(String provider) {
    String providerTitle = "Paiement Mobile Money";
    if (provider == 'mtn') providerTitle = "Paiement MTN MoMo";
    else if (provider == 'orange') providerTitle = "Paiement Orange Money";

    final theme = Theme.of(context);
    final textSecondary = theme.brightness == Brightness.dark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment, color: FxColors.primaryCoral, size: 24),
                  const SizedBox(width: 8),
                  Text(providerTitle, style: FxTypography.titleLarge.copyWith(color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Entrez votre numéro de téléphone. Une demande de validation vous sera envoyée.",
                style: FxTypography.bodyMedium.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 20),
              FxPhoneField(controller: _momoPhoneController),
              const SizedBox(height: 24),
              FxButton(
                text: "Valider et Payer",
                isLoading: _isLoading,
                onPressed: () => _processPayment(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPayment(String provider) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final dio = DioClient().dio;
      final res = await dio.post('payments/subscribe/', data: {
        'plan_code': _selectedPlanCode,
        'provider': provider,
        'phone_number': "+237${_momoPhoneController.text.trim()}",
      });

      if (res.statusCode == 200 && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.workspace_premium, color: FxColors.accentGold),
                SizedBox(width: 8),
                Text("Abonnement Activé"),
              ],
            ),
            content: const Text("Félicitations ! Vous êtes maintenant membre Feelinx Premium. Profitez de tous vos avantages illimités."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/discovery');
                },
                child: const Text("Continuer"),
              ),
            ],
          ),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? FxColors.darkCard : FxColors.lightCard;
    final borderBg = isDark ? FxColors.darkBorder : FxColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Feelinx Premium", style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Gold Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [FxColors.accentGold, FxColors.primaryCoral]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium, size: 56, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      "Devenez Membre Premium",
                      style: FxTypography.displayMedium.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Accédez à des privilèges exclusifs et multipliez vos opportunités de rencontres.",
                      style: FxTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text("Avantages inclus", style: FxTypography.titleLarge.copyWith(color: textPrimary)),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.favorite, "Likes illimités sans restriction par 24h", textPrimary),
              _buildFeatureRow(Icons.visibility, "Voir qui vous a liké en temps réel", textPrimary),
              _buildFeatureRow(Icons.star, "5 Super Likes offerts chaque semaine", textPrimary),
              _buildFeatureRow(Icons.bolt, "1 Boost mensuel offert pour 3x plus de visibilité", textPrimary),
              _buildFeatureRow(Icons.replay, "Annulation du dernier passage à tout moment", textPrimary),
              _buildFeatureRow(Icons.shield, "Mode incognito et filtres de recherche avancés", textPrimary),
              const SizedBox(height: 28),

              Text("Choix de la formule", style: FxTypography.titleLarge.copyWith(color: textPrimary)),
              const SizedBox(height: 16),
              Row(
                children: _plans.map((p) {
                  final isSelected = _selectedPlanCode == p['code'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPlanCode = p['code']),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? FxColors.primaryCoral.withValues(alpha: 0.15) : cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? FxColors.primaryCoral : borderBg,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (p['popular'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(color: FxColors.accentGold, borderRadius: BorderRadius.circular(8)),
                                child: const Text("POPULAIRE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                            Text(p['title'], style: FxTypography.titleMedium.copyWith(color: textPrimary)),
                            const SizedBox(height: 4),
                            Text(p['price'], style: FxTypography.bodyMedium.copyWith(color: FxColors.primaryCoral, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              Text("Mode de paiement sécurisé", style: FxTypography.titleMedium.copyWith(color: textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FxButton(
                      text: "MTN MoMo",
                      variant: FxButtonVariant.outline,
                      onPressed: () => _openPaymentSheet('mtn'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FxButton(
                      text: "Orange Money",
                      variant: FxButtonVariant.outline,
                      onPressed: () => _openPaymentSheet('orange'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: FxColors.accentGold, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: FxTypography.bodyLarge.copyWith(color: textPrimary))),
        ],
      ),
    );
  }
}
