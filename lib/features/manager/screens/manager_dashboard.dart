import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/enums.dart';
import '../../../core/widgets/shared_widgets.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        // We use the existing goals but focus on pending ones
        context.read<GoalProvider>().initializeForUser(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    // We will treat 'pendingApproval' goals as team goals needing action
    final pendingGoals = goalProvider.goals.where((g) => g.status == GoalStatus.pendingApproval).toList();
    final avgCompletion = goalProvider.overallProgress.toStringAsFixed(0);
    final uniqueEmployees = goalProvider.goals.map((g) => g.employeeId).toSet().length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manager Dashboard',
              style: (isDesktop ? AppTypography.headlineLg : AppTypography.headlineLgMobile).copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review team performance and approve submitted goals.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // ── KPI Row ──
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Action Required',
                    value: pendingGoals.length.toString().padLeft(2, '0'),
                    subtitle: 'Pending Approvals',
                    icon: Icons.pending_actions,
                    iconBgColor: AppColors.warningMuted,
                    iconColor: AppColors.warningDeep,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: KpiCard(
                    title: 'Team Performance',
                    value: '$avgCompletion%',
                    subtitle: 'Avg. Completion',
                    icon: Icons.trending_up,
                    iconBgColor: AppColors.successMuted,
                    iconColor: AppColors.successDeep,
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: KpiCard(
                      title: 'Team Members',
                      value: uniqueEmployees.toString(),
                      subtitle: 'Active Members',
                      icon: Icons.people_outline,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 48),

            // ── Pending Approvals List ──
            const SectionHeader(title: 'Pending Approvals'),
            if (pendingGoals.isEmpty)
              const EmptyStateWidget(
                icon: Icons.check_circle_outline,
                title: 'All caught up!',
                subtitle: 'There are no pending goals requiring your approval.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingGoals.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final goal = pendingGoals[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      children: [
                        const UserAvatar(name: 'Team Member'),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: AppTypography.headlineSm.copyWith(color: AppColors.onBackground),
                              ),
                              Text(
                                'Weightage: ${goal.weightage}% • Target: ${goal.target} ${goal.uomType.name}',
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => context.go('/manager/approval/${goal.id}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            foregroundColor: AppColors.onBackground,
                            elevation: 0,
                          ),
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
