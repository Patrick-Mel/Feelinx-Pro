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
    {"code": "premium_1m", "title": "1 Mois", "price": "3 000 FCFA", "popular": false},
    {"code": "premium_3m", "title": "3 Mois", "price": "7 500 FCFA", "popular": true, "save": "-15%"},
    {"code": "premium_12m", "title": "12 Mois", "price": "24 000 FCFA", "popular": false, "save": "-33%"},
  ];

  void _openPaymentSheet(String provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              Text(
                provider == 'mtn' ? "Paiement MTN MoMo 🟡" : "Paiement Orange Money 🟧",
                style: FxTypography.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Entre ton numéro Mobile Money. Une demande de confirmation USSD te sera envoyée sur ton téléphone.",
                style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary),
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
    Navigator.pop(context); // Close sheet
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
            title: const Text("🎉 Abonnement Activé !"),
            content: const Text("Félicitation ! Tu es maintenant membre Feelinx Premium ! Profite de tes avantages illimités."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/discovery');
                },
                child: const Text("C'est parti !"),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feelinx Premium 👑", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [FxColors.accentGold, FxColors.primaryCoral]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium, size: 64, color: Colors.white),
                    const SizedBox(height: 12),
                    Text("Deviens Membre Premium", style: FxTypography.displayMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text("Passe au niveau supérieur et multiplie tes chances de matcher !", style: FxTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text("Avantages inclus", style: FxTypography.titleLarge),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.favorite, "Likes illimités sans restriction par 24h"),
              _buildFeatureRow(Icons.visibility, "Découvre qui t'a liké en temps réel"),
              _buildFeatureRow(Icons.star, "5 Super Likes offerts par semaine"),
              _buildFeatureRow(Icons.bolt, "1 Boost offert par mois (3x plus visible)"),
              _buildFeatureRow(Icons.replay, "Annule ton dernier swipe à tout moment"),
              _buildFeatureRow(Icons.shield, "Mode incognito & filtres avancés"),
              const SizedBox(height: 28),

              Text("Choisis ta formule", style: FxTypography.titleLarge),
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
                          color: isSelected ? FxColors.primaryCoral.withOpacity(0.15) : FxColors.darkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? FxColors.primaryCoral : FxColors.darkBorder,
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
                            Text(p['title'], style: FxTypography.titleMedium),
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

              Text("Paiement sécurisé Mobile Money", style: FxTypography.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FxButton(
                      text: "MTN MoMo 🟡",
                      variant: FxButtonVariant.outline,
                      onPressed: () => _openPaymentSheet('mtn'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FxButton(
                      text: "Orange Money 🟧",
                      variant: FxButtonVariant.outline,
                      onPressed: () => _openPaymentSheet('orange'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FxButton(
                text: "Mode Démo / Test (Instantané)",
                onPressed: () => _openPaymentSheet('mock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: FxColors.accentGold, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: FxTypography.bodyLarge)),
        ],
      ),
    );
  }
}
