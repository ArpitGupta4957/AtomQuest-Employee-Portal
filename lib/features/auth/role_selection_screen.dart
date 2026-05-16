import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/enums.dart';

/// Role Selection screen for demo mode — matches the design with
/// "Atomberg HRMS Demo" pill badge, 3 role cards (Employee, Manager, Admin).
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // ── Demo Mode Badge ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      'Atomberg HRMS Demo',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ──
                  Text(
                    'Select Your Role',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose a perspective to explore the platform\'s capabilities tailored for different organizational levels.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ── Role Cards ──
                  _RoleCard(
                    role: UserRole.employee,
                    icon: Icons.person_outline,
                    title: 'Employee',
                    description: 'Track personal goals, manage time-off requests, and view your performance reviews in a centralized hub.',
                    onTap: () {
                      context.read<AuthProvider>().switchRole(UserRole.employee);
                      context.go('/employee');
                    },
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    role: UserRole.manager,
                    icon: Icons.people_outline,
                    title: 'Manager',
                    description: 'Approve team goals, review leave requests, and monitor department performance analytics seamlessly.',
                    onTap: () {
                      context.read<AuthProvider>().switchRole(UserRole.manager);
                      context.go('/manager');
                    },
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    role: UserRole.admin,
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin',
                    description: 'Oversee global analytics, configure system settings, and manage organizational structure with full access.',
                    onTap: () {
                      context.read<AuthProvider>().switchRole(UserRole.admin);
                      context.go('/admin');
                    },
                  ),
                  const SizedBox(height: 32),

                  // ── Back to Login ──
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Sign in with credentials instead',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final UserRole role;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: _isHovered ? AppColors.primaryContainer : AppColors.surfaceContainer,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0x0F1F2937)
                    : const Color(0x051F2937),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  widget.icon,
                  size: 22,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.textCharcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
