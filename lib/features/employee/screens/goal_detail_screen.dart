import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/widgets/shared_widgets.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final goal = goalProvider.goals.firstWhere((g) => g.id == goalId);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goal Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Card ──
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
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
                          StatusChip(status: goal.status),
                          if (goal.isShared)
                            const Chip(
                              label: Text('Shared Goal'),
                              backgroundColor: AppColors.primaryContainer,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        goal.title,
                        style: AppTypography.headlineLg.copyWith(
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.description,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Divider(height: 48),

                      // ── Metrics Row ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetric(
                              'Weightage',
                              '${goal.weightage}%',
                            ),
                          ),
                          Expanded(
                            child: _buildMetric(
                              'Target',
                              '${goal.target} ${goal.uomType.name}',
                            ),
                          ),
                          Expanded(
                            child: _buildMetric(
                              'Current',
                              (goal.progressPercent / 100 * goal.target)
                                  .toStringAsFixed(1),
                            ),
                          ),
                          Expanded(
                            child: _buildMetric(
                              'Due Date',
                              DateFormat('MMM yyyy').format(goal.targetDate),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Progress & Check-ins ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quarterly Progress', style: AppTypography.headlineMd),
                    ElevatedButton(
                      onPressed: () =>
                          context.go('/employee/goals/${goal.id}/checkin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.textCharcoal,
                      ),
                      child: const Text('New Check-in'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mock Timeline
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: AppColors.surfaceContainer),
                  ),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        'Q1 Update',
                        'Achieved 25%. Manager approved.',
                        'March 31, 2026',
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        'Goal Approved',
                        'Approved by Manager.',
                        'Jan 15, 2026',
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        'Goal Created',
                        'Draft created and submitted.',
                        'Jan 10, 2026',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    String date, {
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.surfaceContainer),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onBackground,
                        ),
                      ),
                      Text(
                        date,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
