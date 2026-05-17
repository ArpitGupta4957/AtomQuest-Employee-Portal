import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/goal_provider.dart';

import '../../../core/widgets/shared_widgets.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    // Initialize goals for user if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<GoalProvider>().initializeForUser(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final user = auth.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 600 && !isDesktop;

    if (user == null || goalProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Section ──
            Text(
              'Good Morning, ${user.name.split(' ').first}',
              style: (isDesktop ? AppTypography.headlineLg : AppTypography.headlineLgMobile).copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here is what\'s happening with your projects today.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // ── Bento Grid ──
            if (isDesktop || isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildProgressCard(goalProvider),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildActiveGoalsCard(goalProvider),
                        const SizedBox(height: AppSpacing.lg),
                        _buildPendingApprovalsCard(goalProvider),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 2,
                    child: _buildCurrentFocusCard(goalProvider, context),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildProgressCard(goalProvider),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildActiveGoalsCard(goalProvider)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildPendingApprovalsCard(goalProvider)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildCurrentFocusCard(goalProvider, context),
                ],
              ),
            
            const SizedBox(height: 32),

            // ── Recent Activity ──
            SectionHeader(title: 'Recent Activity'),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(GoalProvider provider) {
    final progress = provider.overallProgress;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Center(
            child: CircularProgressWidget(
              progress: progress,
              size: 140,
              strokeWidth: 12,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${progress.toInt()}%',
                    style: AppTypography.headlineLg.copyWith(color: AppColors.onBackground),
                  ),
                  Text(
                    'Completed',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActiveGoalsCard(GoalProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Goals',
                style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(Icons.track_changes, size: 20, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            provider.activeGoalCount.toString().padLeft(2, '0'),
            style: AppTypography.displayLg.copyWith(color: AppColors.onBackground),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: AppColors.successDeep),
              const SizedBox(width: 4),
              Text(
                '+2 this month',
                style: AppTypography.labelSm.copyWith(color: AppColors.successDeep),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsCard(GoalProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Approvals',
                style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warningMuted,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(Icons.pending_actions, size: 20, color: AppColors.warningDeep),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            provider.pendingApprovalCount.toString().padLeft(2, '0'),
            style: AppTypography.displayLg.copyWith(color: AppColors.onBackground),
          ),
          const SizedBox(height: 4),
          Text(
            'Requires your attention.',
            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFocusCard(GoalProvider provider, BuildContext context) {
    // Grab the most important active goal
    final currentFocus = provider.goals.isNotEmpty ? provider.goals.first : null;
    
    if (currentFocus == null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.surfaceContainer),
        ),
        child: const Center(child: Text('No active goals.')),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Focus',
                style: AppTypography.headlineMd.copyWith(color: AppColors.onBackground),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Text(
                  'Q3 OKR',
                  style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            currentFocus.title,
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            currentFocus.description,
            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Text(
                '${currentFocus.progressPercent.toInt()}%',
                style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppProgressBar(progress: currentFocus.progressPercent),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mock avatars for shared goal assignees
              if (currentFocus.isShared)
                Row(
                  children: [
                    const UserAvatar(name: 'D K', size: 32),
                    Transform.translate(
                      offset: const Offset(-8, 0),
                      child: const UserAvatar(name: 'E R', size: 32),
                    ),
                    Transform.translate(
                      offset: const Offset(-16, 0),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainer,
                          border: Border.all(color: AppColors.surfaceWhite, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '+2',
                            style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(),
              
              TextButton(
                onPressed: () => context.go('/employee/goals/${currentFocus.id}'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text('View Details', style: AppTypography.labelSm),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No recent activity.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }
}
