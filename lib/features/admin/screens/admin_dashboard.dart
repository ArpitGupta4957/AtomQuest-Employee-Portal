import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/shared_widgets.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard', style: AppTypography.headlineLg),
            Text('Organization-wide performance overview.', style: AppTypography.bodyLg.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 32),
            
            // KPIs
            Row(
              children: const [
                Expanded(child: KpiCard(title: 'Total Goals', value: '1,245', icon: Icons.track_changes)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: KpiCard(title: 'Avg. Progress', value: '68%', icon: Icons.trending_up, iconBgColor: AppColors.successMuted, iconColor: AppColors.successDeep)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: KpiCard(title: 'Shared Goals', value: '4', icon: Icons.share)),
              ],
            ),
            const SizedBox(height: 48),

            // Mock Chart Section
            const SectionHeader(title: 'Department Performance'),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart, size: 64, color: AppColors.surfaceContainerHigh),
                    const SizedBox(height: 16),
                    Text('Organization charts loading...', style: AppTypography.labelMd.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
