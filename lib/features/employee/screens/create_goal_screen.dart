import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/shared_widgets.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();

  ThrustArea _selectedThrustArea = ThrustArea.operationalExcellence;
  UoMType _selectedUomType = UoMType.numeric;
  double _weightage = 10.0;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final goalProvider = context.read<GoalProvider>();

      if (auth.currentUser == null) return;

      // Validation logic: check if weightage exceeds 100% or max goals
      final currentTotal = goalProvider.totalWeightage;
      if (currentTotal + _weightage > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot exceed 100% total weightage. You have ${100 - currentTotal}% left.',
            ),
            backgroundColor: AppColors.errorDeep,
          ),
        );
        return;
      }

      if (goalProvider.goals.length >= 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 8 goals allowed per employee.'),
            backgroundColor: AppColors.errorDeep,
          ),
        );
        return;
      }

      final newGoal = Goal(
        id: const Uuid().v4(),
        employeeId: auth.currentUser!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        thrustArea: _selectedThrustArea,
        uomType: _selectedUomType,
        target: double.parse(_targetController.text),
        weightage: _weightage,
        status: GoalStatus.draft,
        startDate: DateTime.now(),
        targetDate: _targetDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      goalProvider.addGoal(newGoal);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final availableWeightage = 100 - goalProvider.totalWeightage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create New Goal'),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Current Weightage Banner ──
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pie_chart, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Available Weightage: ${availableWeightage.toInt()}%',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onBackground,
                            ),
                          ),
                        ),
                        Text(
                          '${goalProvider.goals.length} / 8 Goals',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Basic Info ──
                  const SectionHeader(title: 'Goal Information'),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration(
                      'Goal Title',
                      'e.g., Launch Onboarding Module',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      'Description',
                      'Provide context and success criteria',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Categorization ──
                  const SectionHeader(title: 'Categorization'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ThrustArea>(
                          initialValue: _selectedThrustArea,
                          decoration: _inputDecoration('Thrust Area', ''),
                          items: ThrustArea.values.map((ta) {
                            return DropdownMenuItem(
                              value: ta,
                              child: Text(ta.label),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedThrustArea = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<UoMType>(
                          initialValue: _selectedUomType,
                          decoration: _inputDecoration('Unit of Measure', ''),
                          items: UoMType.values.map((u) {
                            return DropdownMenuItem(
                              value: u,
                              child: Text(u.label),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedUomType = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Metrics ──
                  const SectionHeader(title: 'Metrics & Targeting'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _targetController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            'Target Value',
                            'e.g., 100',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null) {
                              return 'Must be a number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _targetDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 2),
                              ),
                            );
                            if (date != null) {
                              setState(() => _targetDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: _inputDecoration('Target Date', ''),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_targetDate),
                                ),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Weightage Slider ──
                  SectionHeader(
                    title: 'Weightage',
                    trailing: Text(
                      '${_weightage.toInt()}%',
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryContainer,
                      inactiveTrackColor: AppColors.surfaceContainerHigh,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primaryContainer.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    child: Slider(
                      value: _weightage,
                      min: 10,
                      max: availableWeightage < 10 ? 10 : availableWeightage,
                      divisions:
                          ((availableWeightage < 10 ? 10 : availableWeightage) -
                                  10)
                              .toInt()
                              .clamp(1, 100),
                      label: '${_weightage.toInt()}%',
                      onChanged: availableWeightage < 10
                          ? null
                          : (val) => setState(() => _weightage = val),
                    ),
                  ),
                  Text(
                    'Minimum weightage per goal is 10%. Total across all goals cannot exceed 100%.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Actions ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.textCharcoal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Create Goal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.surfaceDim),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.surfaceDim),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.surfaceWhite,
    );
  }
}
