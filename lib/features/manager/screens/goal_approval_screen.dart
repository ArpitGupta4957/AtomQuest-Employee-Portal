import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/models/enums.dart';

class GoalApprovalScreen extends StatefulWidget {
  final String goalId;
  const GoalApprovalScreen({super.key, required this.goalId});

  @override
  State<GoalApprovalScreen> createState() => _GoalApprovalScreenState();
}

class _GoalApprovalScreenState extends State<GoalApprovalScreen> {
  final _commentController = TextEditingController();
  double? _editedWeightage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final goal = goalProvider.goals.firstWhere((g) => g.id == widget.goalId);
    
    // Initialize edited weightage
    _editedWeightage ??= goal.weightage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Goal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginDesktop),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal Card
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
                          Text(
                            goal.thrustArea.label,
                            style: AppTypography.labelSm.copyWith(color: AppColors.primary),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(goal.targetDate),
                            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        goal.title,
                        style: AppTypography.headlineMd.copyWith(color: AppColors.onBackground),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.description,
                        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weightage (Editable)', style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _editedWeightage!,
                                        min: 10,
                                        max: 100, // Ideally restricted by remaining employee weightage
                                        divisions: 90,
                                        label: '${_editedWeightage!.toInt()}%',
                                        onChanged: (val) => setState(() => _editedWeightage = val),
                                      ),
                                    ),
                                    Text('${_editedWeightage!.toInt()}%', style: AppTypography.headlineSm),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          _buildMetric('Target', '${goal.target} ${goal.uomType.shortLabel}'),
                          const SizedBox(width: 32),
                          _buildMetric('UoM', goal.uomType.label),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Feedback
                Text('Manager Feedback (Optional)', style: AppTypography.headlineSm),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add comments or requested changes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reject Logic
                          if (_editedWeightage != goal.weightage) {
                            goalProvider.updateGoal(goal.copyWith(
                              weightage: _editedWeightage,
                              status: GoalStatus.rejected,
                            ));
                          } else {
                            goalProvider.rejectGoal(goal.id, comment: _commentController.text);
                          }
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal Rejected / Changes Requested')));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorDeep,
                          side: const BorderSide(color: AppColors.errorDeep),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Request Changes'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Approve Logic
                          if (_editedWeightage != goal.weightage) {
                            goalProvider.updateGoal(goal.copyWith(
                              weightage: _editedWeightage,
                              status: GoalStatus.approved,
                            ));
                          } else {
                            goalProvider.approveGoal(goal.id, comment: _commentController.text);
                          }
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Goal Approved')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successDeep,
                          foregroundColor: AppColors.surfaceWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Approve Goal'),
                      ),
                    ),
                  ],
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
        Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.headlineSm.copyWith(color: AppColors.onBackground)),
      ],
    );
  }
}
