import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../branding/feelinx_logo.dart';
import '../theme/colors.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/onboarding/presentation/screens/registration_wizard_screen.dart';
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/discovery/presentation/screens/explorer_screen.dart';
import '../../features/matches/presentation/screens/matches_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/profile/presentation/screens/my_profile_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/photos_manager_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/safety/presentation/screens/verification_screen.dart';
import '../widgets/fx_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

Widget _buildDesktopTab(BuildContext context, IconData icon, String label, bool isSelected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? FxColors.primaryCoral : Colors.grey, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? FxColors.primaryCoral : Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/phone',
      builder: (context, state) => const PhoneInputScreen(),
    ),
    GoRoute(
      path: '/auth/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/onboarding/wizard',
      builder: (context, state) => const RegistrationWizardScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        int currentIndex = 0;
        final location = state.uri.path;
        if (location.startsWith('/discovery')) currentIndex = 0;
        else if (location.startsWith('/explorer')) currentIndex = 1;
        else if (location.startsWith('/matches')) currentIndex = 2;
        else if (location.startsWith('/chat-list')) currentIndex = 3;
        else if (location.startsWith('/profile')) currentIndex = 4;

        final isDesktopWeb = MediaQuery.of(context).size.width > 900;

        if (isDesktopWeb) {
          return Scaffold(
            body: Row(
              children: [
                // Desktop Web Sidebar (Tinder Web Style)
                Container(
                  width: 380,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(right: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
                  ),
                  child: Column(
                    children: [
                      // Header: Profile & Brand Logo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [FxColors.primaryCoral.withValues(alpha: 0.15), Colors.transparent],
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => GoRouter.of(context).go('/profile'),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: FxColors.primaryCoral,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: FeelinxLogo(size: 24, variant: FeelinxLogoVariant.fullHorizontal),
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => context.push('/settings'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Desktop Navigation Row
                      Container(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDesktopTab(context, Icons.local_fire_department, "Swiper", currentIndex == 0, () => GoRouter.of(context).go('/discovery')),
                            _buildDesktopTab(context, Icons.grid_view, "Explorer", currentIndex == 1, () => GoRouter.of(context).go('/explorer')),
                            _buildDesktopTab(context, Icons.favorite, "Matchs", currentIndex == 2, () => GoRouter.of(context).go('/matches')),
                            _buildDesktopTab(context, Icons.chat_bubble, "Chat", currentIndex == 3, () => GoRouter.of(context).go('/chat-list')),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Sidebar Content Area (Matches or Chat List depending on selection)
                      Expanded(
                        child: currentIndex == 3
                            ? const ChatListScreen()
                            : const MatchesScreen(),
                      ),
                    ],
                  ),
                ),

                // Main Content View (Right Panel)
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: SizedBox(
                        width: currentIndex == 0 ? 520 : double.infinity,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: FxNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              switch (index) {
                case 0: GoRouter.of(context).go('/discovery'); break;
                case 1: GoRouter.of(context).go('/explorer'); break;
                case 2: GoRouter.of(context).go('/matches'); break;
                case 3: GoRouter.of(context).go('/chat-list'); break;
                case 4: GoRouter.of(context).go('/profile'); break;
              }
            },
            items: const [
              FxNavBarItem(icon: Icons.local_fire_department_outlined, activeIcon: Icons.local_fire_department, label: "Découvrir"),
              FxNavBarItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: "Explorer"),
              FxNavBarItem(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: "Matchs"),
              FxNavBarItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: "Messages"),
              FxNavBarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "Profil"),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/discovery',
          builder: (context, state) => const DiscoveryScreen(),
        ),
        GoRoute(
          path: '/explorer',
          builder: (context, state) => const ExplorerScreen(),
        ),
        GoRoute(
          path: '/matches',
          builder: (context, state) => const MatchesScreen(),
        ),
        GoRoute(
          path: '/chat-list',
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const MyProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        return ChatScreen(conversationId: conversationId);
      },
    ),
    GoRoute(
      path: '/profile/public/:profileId',
      builder: (context, state) {
        final profileId = state.pathParameters['profileId']!;
        return PublicProfileScreen(profileId: profileId);
      },
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/photos',
      builder: (context, state) => const PhotosManagerScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/safety/verification',
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

