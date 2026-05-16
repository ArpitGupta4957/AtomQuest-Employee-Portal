import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/shared_widgets.dart';

class TeamOverviewScreen extends StatelessWidget {
  const TeamOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Mock team data
    final teamMembers = [
      {
        'name': 'Rahul Sharma',
        'role': 'Frontend Developer',
        'progress': 85.0,
        'goals': 6,
        'pending': 0,
      },
      {
        'name': 'Priya Patel',
        'role': 'Backend Engineer',
        'progress': 62.0,
        'goals': 4,
        'pending': 2,
      },
      {
        'name': 'Amit Kumar',
        'role': 'Product Designer',
        'progress': 90.0,
        'goals': 5,
        'pending': 0,
      },
      {
        'name': 'Sneha Reddy',
        'role': 'QA Engineer',
        'progress': 45.0,
        'goals': 8,
        'pending': 1,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Overview',
                        style:
                            (isDesktop
                                    ? AppTypography.headlineLg
                                    : AppTypography.headlineLgMobile)
                                .copyWith(color: AppColors.onBackground),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor subordinates\' completion rates and goal distributions.',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // CSV Export Mock Logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Achievement Report (CSV) downloaded successfully!',
                          ),
                          backgroundColor: AppColors.successDeep,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export CSV'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Team List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teamMembers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final member = teamMembers[index];
                  final progress = member['progress'] as double;

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      children: [
                        UserAvatar(name: member['name'] as String),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member['name'] as String,
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onBackground,
                                ),
                              ),
                              Text(
                                member['role'] as String,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Avg Completion',
                                    style: AppTypography.labelSm,
                                  ),
                                  Text(
                                    '${progress.toInt()}%',
                                    style: AppTypography.labelSm,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AppProgressBar(progress: progress),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${member['goals']} Goals',
                              style: AppTypography.labelMd,
                            ),
                            if ((member['pending'] as int) > 0)
                              Text(
                                '${member['pending']} Pending Review',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.warningDeep,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _CheckInReviewDialog(
                                employeeName: member['name'] as String,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            foregroundColor: AppColors.onBackground,
                            elevation: 0,
                          ),
                          child: const Text('Review Check-in'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInReviewDialog extends StatefulWidget {
  final String employeeName;
  const _CheckInReviewDialog({required this.employeeName});

  @override
  State<_CheckInReviewDialog> createState() => _CheckInReviewDialogState();
}

class _CheckInReviewDialogState extends State<_CheckInReviewDialog> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Review Check-in: ${widget.employeeName}'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Q1 Progress: 85% Achieved'),
            const SizedBox(height: 8),
            const Text(
              'Self Rating: 4/5',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Employee Notes: "Met all major milestones but faced slight delays in vendor onboarding."',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Manager Structured Comment',
                hintText: 'Add feedback for the 1:1 discussion...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save logic
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-in Review Saved')),
            );
          },
          child: const Text('Save Review'),
        ),
      ],
    );
  }
}
