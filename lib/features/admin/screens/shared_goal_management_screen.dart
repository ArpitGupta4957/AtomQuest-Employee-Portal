import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/models/enums.dart';
import '../../../core/widgets/shared_widgets.dart';

class SharedGoalManagementScreen extends StatefulWidget {
  const SharedGoalManagementScreen({super.key});

  @override
  State<SharedGoalManagementScreen> createState() =>
      _SharedGoalManagementScreenState();
}

class _SharedGoalManagementScreenState
    extends State<SharedGoalManagementScreen> {
  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateSharedGoalDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final sharedGoals = goalProvider.sharedGoals;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginDesktop),
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
                        'Shared Goals (OKRs)',
                        style: AppTypography.headlineLg,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Push organizational objectives to specific departments or employees.',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Shared Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.textCharcoal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (sharedGoals.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.share,
                  title: 'No Shared Goals Active',
                  subtitle:
                      'Push organizational OKRs down to departments or employees directly from here.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sharedGoals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final goal = sharedGoals[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        border: Border.all(color: AppColors.surfaceContainer),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            child: const Icon(
                              Icons.stars,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: AppTypography.headlineSm,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal.description,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        goal.thrustArea.label,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor:
                                          AppColors.surfaceContainerHigh,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Target: ${goal.target} ${goal.uomType.shortLabel}',
                                      style: AppTypography.labelSm,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Assigned To',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${goal.assignedDepartmentIds.length} Depts | ${goal.assignedEmployeeIds.length} Users',
                                style: AppTypography.headlineSm,
                              ),
                            ],
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

class _CreateSharedGoalDialog extends StatefulWidget {
  const _CreateSharedGoalDialog();

  @override
  State<_CreateSharedGoalDialog> createState() =>
      _CreateSharedGoalDialogState();
}

class _CreateSharedGoalDialogState extends State<_CreateSharedGoalDialog> {
  final _titleController = TextEditingController();
  ThrustArea _selectedThrustArea = ThrustArea.strategicInitiative;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Shared Goal'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Goal Title'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThrustArea>(
              initialValue: _selectedThrustArea,
              decoration: const InputDecoration(labelText: 'Thrust Area'),
              items: ThrustArea.values
                  .map(
                    (ta) => DropdownMenuItem(value: ta, child: Text(ta.label)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedThrustArea = v!),
            ),
            const SizedBox(height: 24),
            const Text(
              'Assignments: In a full app, this would be a multi-select for Departments and Employees.',
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
            // Logic to create shared goal
            Navigator.pop(context);
          },
          child: const Text('Push Goal'),
        ),
      ],
    );
  }
}
