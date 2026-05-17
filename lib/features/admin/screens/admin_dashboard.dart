import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/shared_widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().initializeForAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final goalProvider = context.watch<GoalProvider>();
    final isLoading = goalProvider.isLoading;

    final totalGoals = goalProvider.goals.length;
    final avgProgress = goalProvider.overallProgress.toStringAsFixed(0);
    final sharedGoals = goalProvider.goals.where((g) => g.isShared).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard', style: AppTypography.headlineLg),
            Text(
              'Organization-wide performance overview.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),

            // KPIs
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Total Goals',
                    value: totalGoals.toString(),
                    icon: Icons.track_changes,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: KpiCard(
                    title: 'Avg. Progress',
                    value: '$avgProgress%',
                    icon: Icons.trending_up,
                    iconBgColor: AppColors.successMuted,
                    iconColor: AppColors.successDeep,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: KpiCard(
                    title: 'Shared Goals',
                    value: sharedGoals.toString(),
                    icon: Icons.share,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Chart
            const SectionHeader(title: 'Goals by Thrust Area'),
            Container(
              height: 350,
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.surfaceContainer),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryFixed.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : goalProvider.goals.isEmpty
                  ? Center(
                      child: Text(
                        'No goals data available yet.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : _buildChart(goalProvider),
            ),
            const SizedBox(height: 48),

            // ── Quick Actions ──
            const SectionHeader(title: 'Admin Quick Actions'),
            GridView.count(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _QuickAction(
                  icon: Icons.calendar_month_outlined,
                  label: 'Manage Cycles',
                  color: AppColors.primary,
                  onTap: () => context.go('/admin/cycles'),
                ),
                _QuickAction(
                  icon: Icons.account_tree_outlined,
                  label: 'Org Hierarchy',
                  color: Colors.teal,
                  onTap: () => context.go('/admin/org'),
                ),
                _QuickAction(
                  icon: Icons.history_outlined,
                  label: 'Audit Trail',
                  color: Colors.purple,
                  onTap: () => context.go('/admin/audit'),
                ),
                _QuickAction(
                  icon: Icons.lock_open_outlined,
                  label: 'Unlock Goals',
                  color: AppColors.errorDeep,
                  onTap: () => context.go('/admin/unlock'),
                ),
                _QuickAction(
                  icon: Icons.download_outlined,
                  label: 'Export Report',
                  color: Colors.green,
                  onTap: () => context.go('/admin/report'),
                ),
                _QuickAction(
                  icon: Icons.share_outlined,
                  label: 'Shared Goals',
                  color: Colors.orange,
                  onTap: () => context.go('/admin/shared-goals'),
                ),
                _QuickAction(
                  icon: Icons.analytics_outlined,
                  label: 'Completion View',
                  color: Colors.indigo,
                  onTap: () => context.go('/admin/analytics'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(GoalProvider provider) {
    // Group goals by thrust area
    final Map<String, int> distribution = {};
    for (var goal in provider.goals) {
      final key = goal.thrustArea.name;
      distribution[key] = (distribution[key] ?? 0) + 1;
    }

    final keys = distribution.keys.toList();
    final maxValue = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue + (maxValue * 0.2), // 20% padding top
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= keys.length)
                  return const SizedBox.shrink();
                // Format the camelCase name to somewhat readable
                String text = keys[value.toInt()];
                if (text.length > 10) text = text.substring(0, 10) + '..';
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.surfaceContainer,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          keys.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: distribution[keys[index]]!.toDouble(),
                color: AppColors.primaryFixed,
                width: 24,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxValue + (maxValue * 0.2),
                  color: AppColors.surfaceContainerHighest.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.surfaceContainer),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
