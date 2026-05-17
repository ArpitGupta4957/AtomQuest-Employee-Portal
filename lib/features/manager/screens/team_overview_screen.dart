import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/models/models.dart';
import '../../../core/models/enums.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/shared_widgets.dart';

class TeamOverviewScreen extends StatefulWidget {
  const TeamOverviewScreen({super.key});

  @override
  State<TeamOverviewScreen> createState() => _TeamOverviewScreenState();
}

class _TeamOverviewScreenState extends State<TeamOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<GoalProvider>().initializeForManager(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final goalProvider = context.watch<GoalProvider>();
    final goals = goalProvider.goals;

    // Group goals by employee
    final Map<String, List<Goal>> byEmployee = {};
    for (var g in goals) {
      byEmployee.putIfAbsent(g.employeeId, () => []).add(g);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: goalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Team', style: AppTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('View planned vs. actual achievement and log check-in comments.',
                        style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 32),

                    if (byEmployee.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.people_outline,
                        title: 'No team members found',
                        subtitle: 'Make sure employees are assigned to you as their manager.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: byEmployee.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                        itemBuilder: (context, index) {
                          final empId = byEmployee.keys.elementAt(index);
                          final empGoals = byEmployee[empId]!;
                          final empName = empGoals.first.employeeId; // will be replaced below
                          final approved = empGoals.where((g) => g.status == GoalStatus.approved).length;
                          final pending = empGoals.where((g) => g.status == GoalStatus.pendingApproval).length;
                          final totalWeightage = empGoals.fold(0.0, (s, g) => s + g.weightage);

                          return _EmployeeGoalCard(
                            employeeId: empId,
                            goals: empGoals,
                            approvedCount: approved,
                            pendingCount: pending,
                            totalWeightage: totalWeightage,
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

class _EmployeeGoalCard extends StatefulWidget {
  final String employeeId;
  final List<Goal> goals;
  final int approvedCount;
  final int pendingCount;
  final double totalWeightage;

  const _EmployeeGoalCard({
    required this.employeeId,
    required this.goals,
    required this.approvedCount,
    required this.pendingCount,
    required this.totalWeightage,
  });

  @override
  State<_EmployeeGoalCard> createState() => _EmployeeGoalCardState();
}

class _EmployeeGoalCardState extends State<_EmployeeGoalCard> {
  bool _expanded = false;
  String _employeeName = '';
  String _employeeEmail = '';
  bool _loadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeName();
  }

  Future<void> _fetchEmployeeName() async {
    try {
      final res = await SupabaseService.instance.client
          .from('users')
          .select('name, email')
          .eq('id', widget.employeeId)
          .single();
      setState(() {
        _employeeName = res['name'] ?? 'Unknown';
        _employeeEmail = res['email'] ?? '';
        _loadingName = false;
      });
    } catch (_) {
      setState(() {
        _employeeName = 'Employee';
        _loadingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        children: [
          // ── Header Row ──
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                UserAvatar(name: _loadingName ? '...' : _employeeName),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _loadingName ? 'Loading...' : _employeeName,
                        style: AppTypography.labelMd,
                      ),
                      Text(_employeeEmail, style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                // Stats
                _StatBadge('${widget.goals.length} Goals', AppColors.primary),
                const SizedBox(width: 8),
                if (widget.pendingCount > 0)
                  _StatBadge('${widget.pendingCount} Pending', Colors.orange),
                const SizedBox(width: 8),
                _StatBadge('${widget.approvedCount} Approved', Colors.green),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ),
              ],
            ),
          ),

          // ── Expanded Goals + Check-in Table ──
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Goals & Check-in Status', style: AppTypography.headlineSm),
                  const SizedBox(height: 12),
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: AppColors.surfaceContainerLow,
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Goal Title', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted))),
                        Expanded(flex: 1, child: Text('Target', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted))),
                        Expanded(flex: 1, child: Text('Weight', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted))),
                        Expanded(flex: 1, child: Text('Status', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted))),
                        Expanded(flex: 2, child: Text('Q Check-ins', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted))),
                        const SizedBox(width: 100),
                      ],
                    ),
                  ),
                  ...widget.goals.map((goal) => _GoalRow(goal: goal, employeeName: _employeeName)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final Goal goal;
  final String employeeName;

  const _GoalRow({required this.goal, required this.employeeName});

  Color _statusColor(GoalStatus s) {
    switch (s) {
      case GoalStatus.approved: return Colors.green;
      case GoalStatus.pendingApproval: return Colors.orange;
      case GoalStatus.inProgress: return AppColors.primary;
      case GoalStatus.rejected: return AppColors.errorDeep;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkins = goal.checkIns;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceContainer))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(goal.title, style: AppTypography.bodyMd, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          Expanded(flex: 1, child: Text('${goal.target} ${goal.uomType.label}', style: AppTypography.bodySm)),
          Expanded(flex: 1, child: Text('${goal.weightage.toInt()}%', style: AppTypography.bodySm)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor(goal.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(goal.status.name, style: TextStyle(color: _statusColor(goal.status), fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              checkins.isEmpty ? 'No check-ins yet' : checkins.keys.map((q) => q.name.toUpperCase()).join(', '),
              style: AppTypography.bodySm.copyWith(color: checkins.isEmpty ? AppColors.textMuted : AppColors.primary),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextButton(
              onPressed: () => _showCheckinDialog(context, goal),
              child: const Text('Check-in Review'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckinDialog(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => _CheckInReviewDialog(goal: goal, employeeName: employeeName),
    );
  }
}

class _CheckInReviewDialog extends StatefulWidget {
  final Goal goal;
  final String employeeName;

  const _CheckInReviewDialog({required this.goal, required this.employeeName});

  @override
  State<_CheckInReviewDialog> createState() => _CheckInReviewDialogState();
}

class _CheckInReviewDialogState extends State<_CheckInReviewDialog> {
  final _commentController = TextEditingController();
  Quarter _selectedQuarter = Quarter.q1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Default to the latest check-in quarter if one exists
    if (widget.goal.checkIns.isNotEmpty) {
      _selectedQuarter = widget.goal.checkIns.keys.last;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      // Find the check-in record in Supabase and update the manager_comment
      final response = await SupabaseService.instance.client
          .from('quarterly_checkins')
          .select('id')
          .eq('goal_id', widget.goal.id)
          .eq('quarter', _selectedQuarter.name)
          .maybeSingle();

      if (response != null) {
        await SupabaseService.instance.client
            .from('quarterly_checkins')
            .update({'manager_comment': _commentController.text.trim()})
            .eq('id', response['id']);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Check-in comment saved'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('Error saving manager comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save comment'), backgroundColor: AppColors.errorDeep),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkins = widget.goal.checkIns;
    final selectedCi = checkins[_selectedQuarter];

    return AlertDialog(
      title: Text('Check-in Review: ${widget.employeeName}', style: AppTypography.headlineSm),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.goal.title, style: AppTypography.bodyMd.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),

            // Quarter selector
            Text('Quarter:', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Quarter.values.map((q) {
                final hasCi = checkins.containsKey(q);
                return FilterChip(
                  label: Text(q.name.toUpperCase()),
                  selected: _selectedQuarter == q,
                  onSelected: hasCi ? (_) => setState(() => _selectedQuarter = q) : null,
                  selectedColor: AppColors.primaryContainer,
                  disabledColor: AppColors.surfaceContainerLow,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            if (selectedCi != null) ...[
              // Planned vs Actual table
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('Target (Planned)', '${widget.goal.target} ${widget.goal.uomType.label}'),
                    _InfoRow('Actual Achievement', selectedCi.achievement != null ? '${selectedCi.achievement}' : 'Not filed'),
                    _InfoRow('Employee Notes', selectedCi.notes ?? 'None'),
                    _InfoRow('Submitted', selectedCi.submittedAt != null ? DateFormat.yMMMd().format(selectedCi.submittedAt!) : 'N/A'),
                    if (selectedCi.managerComment != null && selectedCi.managerComment!.isNotEmpty)
                      _InfoRow('Previous Manager Comment', selectedCi.managerComment!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.warningMuted, borderRadius: BorderRadius.circular(8)),
                child: Text('No check-in submitted for ${_selectedQuarter.name.toUpperCase()} yet.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.warningDeep)),
              ),
              const SizedBox(height: 16),
            ],

            Text('Manager Structured Comment', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add structured feedback for the 1:1 discussion...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surfaceWhite,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: selectedCi == null || _isSaving ? null : _saveComment,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.successDeep, foregroundColor: Colors.white),
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Comment'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text('$label:', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted))),
          Expanded(child: Text(value, style: AppTypography.bodyMd)),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
