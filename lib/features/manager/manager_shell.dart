import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Professional Manager Shell with sidebar (desktop) + bottom nav (mobile).
class ManagerShell extends StatelessWidget {
  final Widget child;
  const ManagerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/manager/team')) {
      currentIndex = 1;
    } else if (location.startsWith('/manager/profile')) {
      currentIndex = 2;
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _ManagerSidebar(currentIndex: currentIndex),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) {
            switch (i) {
              case 0: context.go('/manager'); break;
              case 1: context.go('/manager/team'); break;
              case 2: context.go('/manager/profile'); break;
            }
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'My Team'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    }
  }
}

class _ManagerSidebar extends StatelessWidget {
  final int currentIndex;
  const _ManagerSidebar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.surfaceWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('MANAGER', style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 8),
                Text('AtomQuest', style: AppTypography.headlineMd.copyWith(color: AppColors.onBackground)),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', isSelected: currentIndex == 0, onTap: () => context.go('/manager')),
          _NavItem(icon: Icons.people_outline, label: 'My Team', isSelected: currentIndex == 1, onTap: () => context.go('/manager/team')),
          _NavItem(icon: Icons.person_outline, label: 'Profile', isSelected: currentIndex == 2, onTap: () => context.go('/manager/profile')),
          const Spacer(),
          const Divider(height: 1),
          _NavItem(icon: Icons.logout, label: 'Sign Out', isSelected: false, onTap: () => context.go('/login')),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withOpacity(0.4) : Colors.transparent,
          border: Border(
            left: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTypography.labelMd.copyWith(color: isSelected ? AppColors.primary : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
