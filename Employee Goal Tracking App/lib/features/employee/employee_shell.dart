import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/auth_provider.dart';

/// Employee Shell providing the navigation scaffolding:
/// - Desktop: Sidebar navigation
/// - Mobile: Bottom navigation bar + AppBar
class EmployeeShell extends StatelessWidget {
  final Widget child;

  const EmployeeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final location = GoRouterState.of(context).matchedLocation;
    
    int currentIndex = 0;
    if (location.startsWith('/employee/goals')) {
      currentIndex = 1;
    } else if (location.startsWith('/employee/team')) {
      currentIndex = 2;
    } else if (location.startsWith('/employee/profile')) {
      currentIndex = 3;
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _SideNav(currentIndex: currentIndex),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildMobileAppBar(context),
      body: child,
      bottomNavigationBar: _BottomNav(currentIndex: currentIndex),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return AppBar(
      title: Row(
        children: [
          if (user?.avatarUrl == null)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                user?.initials ?? '?',
                style: AppTypography.labelSm.copyWith(color: AppColors.onPrimaryContainer),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            'Atomberg HRMS',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.go('/employee/notifications'),
          icon: const Badge(
            backgroundColor: AppColors.errorDeep,
            smallSize: 8,
            child: Icon(Icons.notifications_outlined, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}

class _SideNav extends StatelessWidget {
  final int currentIndex;

  const _SideNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Container(
      width: AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          right: BorderSide(color: AppColors.surfaceContainer),
        ),
      ),
      child: Column(
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    user?.initials ?? '?',
                    style: AppTypography.labelMd.copyWith(color: AppColors.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Employee',
                        style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                      ),
                      Text(
                        user?.department ?? 'Department',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        'Role: Employee',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          
          // Nav Items
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isSelected: currentIndex == 0,
            onTap: () => context.go('/employee'),
          ),
          _NavItem(
            icon: Icons.track_changes_outlined,
            label: 'My Goals',
            isSelected: currentIndex == 1,
            onTap: () => context.go('/employee/goals'),
          ),
          _NavItem(
            icon: Icons.groups_outlined,
            label: 'Team',
            isSelected: currentIndex == 2,
            onTap: () {}, // Not implemented in this demo path
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => context.go('/employee/profile'),
          ),

          const Spacer(),
          const Divider(),
          _NavItem(
            icon: Icons.logout,
            label: 'Exit Demo',
            isSelected: false,
            onTap: () {
              context.read<AuthProvider>().logout();
              context.go('/role-select');
            },
          ),
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: isSelected
                  ? AppTypography.labelMd.copyWith(color: AppColors.onPrimaryContainer)
                  : AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;

  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppColors.surfaceContainer),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x141F2937),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => context.go('/employee'),
              ),
              _BottomNavItem(
                icon: Icons.track_changes_outlined,
                activeIcon: Icons.track_changes,
                label: 'Goals',
                isSelected: currentIndex == 1,
                onTap: () => context.go('/employee/goals'),
              ),
              _BottomNavItem(
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
                label: 'Team',
                isSelected: currentIndex == 2,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isSelected: currentIndex == 3,
                onTap: () => context.go('/employee/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
