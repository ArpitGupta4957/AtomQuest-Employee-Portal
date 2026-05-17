import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/models/enums.dart';

class QuarterlyCheckinScreen extends StatefulWidget {
  final String goalId;
  const QuarterlyCheckinScreen({super.key, required this.goalId});

  @override
  State<QuarterlyCheckinScreen> createState() => _QuarterlyCheckinScreenState();
}

class _QuarterlyCheckinScreenState extends State<QuarterlyCheckinScreen> {
  final _achievementController = TextEditingController();
  final _notesController = TextEditingController();
  Quarter _selectedQuarter = Quarter.q1;
  int _selfRating = 3;
  GoalStatus _selectedStatus = GoalStatus.inProgress;

  @override
  void dispose() {
    _achievementController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final goal = goalProvider.goals.firstWhere((g) => g.id == widget.goalId);

    // Schedule Enforcement Logic
    final currentMonth = DateTime.now().month;
    bool isWindowOpen = false;
    String windowMessage = '';

    switch (_selectedQuarter) {
      case Quarter.q1:
        isWindowOpen = currentMonth == 7; // July
        windowMessage = 'Q1 Check-ins are only allowed in July.';
        break;
      case Quarter.q2:
        isWindowOpen = currentMonth == 10; // October
        windowMessage = 'Q2 Check-ins are only allowed in October.';
        break;
      case Quarter.q3:
        isWindowOpen = currentMonth == 1; // January
        windowMessage = 'Q3 Check-ins are only allowed in January.';
        break;
      case Quarter.q4:
        isWindowOpen = currentMonth == 3 || currentMonth == 4; // March/April
        windowMessage = 'Q4 Check-ins are only allowed in March/April.';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quarterly Check-in'),
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
                // Goal Context
                Text(
                  'Goal: ${goal.title}',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.onBackground,
                  ),
                ),
                Text(
                  'Target: ${goal.target} ${goal.uomType.shortLabel}',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 32),

                // Form
                DropdownButtonFormField<Quarter>(
                  initialValue: _selectedQuarter,
                  decoration: _inputDecoration('Select Quarter'),
                  items: Quarter.values
                      .map(
                        (q) => DropdownMenuItem(value: q, child: Text(q.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedQuarter = v!),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _achievementController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Current Achievement Value'),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<GoalStatus>(
                  initialValue: _selectedStatus,
                  decoration: _inputDecoration('Goal Status'),
                  items: const [
                    DropdownMenuItem(
                      value: GoalStatus.notStarted,
                      child: Text('Not Started'),
                    ),
                    DropdownMenuItem(
                      value: GoalStatus.inProgress,
                      child: Text('On Track'),
                    ),
                    DropdownMenuItem(
                      value: GoalStatus.completed,
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
                const SizedBox(height: 24),

                Text('Self Rating (1-5)', style: AppTypography.labelMd),
                Slider(
                  value: _selfRating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _selfRating.toString(),
                  onChanged: (val) => setState(() => _selfRating = val.toInt()),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _inputDecoration('Notes / Roadblocks'),
                ),
                const SizedBox(height: 24),

                if (!isWindowOpen)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorDeep.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: AppColors.errorDeep),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            windowMessage,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.errorDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isWindowOpen
                        ? () {
                            // Logic to save checkin
                            final checkIn = QuarterlyCheckIn(
                              quarter: _selectedQuarter,
                              achievement: double.tryParse(
                                _achievementController.text,
                              ),
                              selfRating: _selfRating,
                              notes: _notesController.text,
                              status: _selectedStatus,
                              submittedAt: DateTime.now(),
                            );
                            goalProvider.updateCheckIn(
                              goal.id,
                              _selectedQuarter,
                              checkIn,
                            );
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Check-in submitted for review'),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.textCharcoal,
                    ),
                    child: const Text('Submit Check-in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      filled: true,
      fillColor: AppColors.surfaceWhite,
    );
  }
}
