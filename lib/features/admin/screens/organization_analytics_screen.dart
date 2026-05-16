import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class OrganizationAnalyticsScreen extends StatelessWidget {
  const OrganizationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Organization Analytics', style: AppTypography.headlineLg),
              const SizedBox(height: 4),
              Text('Deep-dive into performance metrics across all departments.', 
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),

              // ── Main Chart ──
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                height: 400,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Department Goal Completion (%)', style: AppTypography.headlineSm),
                    const SizedBox(height: 32),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(color: AppColors.textMuted, fontSize: 12);
                                  String text;
                                  switch (value.toInt()) {
                                    case 0: text = 'Engineering'; break;
                                    case 1: text = 'Sales'; break;
                                    case 2: text = 'Marketing'; break;
                                    case 3: text = 'HR'; break;
                                    case 4: text = 'Design'; break;
                                    default: text = ''; break;
                                  }
                                  return SideTitleWidget(meta: meta, child: Text(text, style: style));
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.surfaceContainer, strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _makeBarGroup(0, 85),
                            _makeBarGroup(1, 65),
                            _makeBarGroup(2, 92),
                            _makeBarGroup(3, 45),
                            _makeBarGroup(4, 78),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Secondary Metrics ──
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Top Performing', 'Marketing (92%)', Icons.emoji_events)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildMetricCard('Needs Attention', 'HR (45%)', Icons.warning_amber)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 32,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
              Text(value, style: AppTypography.headlineSm),
            ],
          ),
        ],
      ),
    );
  }
}
