import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Admin screen to view all goals and unlock any that are locked.
class GoalUnlockScreen extends StatefulWidget {
  const GoalUnlockScreen({super.key});

  @override
  State<GoalUnlockScreen> createState() => _GoalUnlockScreenState();
}

class _GoalUnlockScreenState extends State<GoalUnlockScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;
  String _filter = 'locked'; // 'locked' or 'approved'

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    setState(() => _isLoading = true);
    try {
      List<dynamic> response;
      if (_filter == 'locked') {
        response = await _supabase.client
            .from('goals')
            .select('id, title, status, updated_at, employee_id, users(name, email)')
            .eq('status', 'approved')
            .order('updated_at', ascending: false);
      } else {
        response = await _supabase.client
            .from('goals')
            .select('id, title, status, updated_at, employee_id, users(name, email)')
            .order('updated_at', ascending: false);
      }
      setState(() => _goals = List<Map<String, dynamic>>.from(response));

    } catch (e) {
      print('Error fetching goals for unlock: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlockGoal(String goalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlock Goal?'),
        content: const Text(
          'This will change the goal status back to "In Progress", allowing the employee to edit it again. This action will be logged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorDeep,
            ),
            child: const Text('Unlock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _supabase.client
          .from('goals')
          .update({
            'status': 'inProgress',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);

      // Log audit entry
      final userId = _supabase.client.auth.currentUser?.id ?? '';
      await _supabase.client.from('audit_logs').insert({
        'action': 'goalUnlocked',
        'goal_id': goalId,
        'user_id': userId,
        'new_value': 'Admin unlocked goal for editing',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Goal unlocked successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchGoals();
    } catch (e) {
      print('Error unlocking goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to unlock goal'),
          backgroundColor: AppColors.errorDeep,
        ),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'inProgress':
        return AppColors.primary;
      case 'pendingApproval':
        return Colors.orange;
      case 'rejected':
        return AppColors.errorDeep;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goal Unlock Management'),
        backgroundColor: AppColors.surfaceWhite,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchGoals),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Locked (Approved)',
                  isSelected: _filter == 'locked',
                  onTap: () {
                    setState(() => _filter = 'locked');
                    _fetchGoals();
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'All Goals',
                  isSelected: _filter == 'all',
                  onTap: () {
                    setState(() => _filter = 'all');
                    _fetchGoals();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_open,
                          size: 64,
                          color: AppColors.surfaceContainerHigh,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No locked goals found.',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop
                          ? AppSpacing.marginDesktop
                          : AppSpacing.marginMobile,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final user = goal['users'];
                      final status = goal['status'] ?? 'unknown';
                      final updatedAt = DateTime.parse(goal['updated_at']);
                      return Card(
                        color: AppColors.surfaceWhite,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      goal['title'] ?? 'Untitled Goal',
                                      style: AppTypography.headlineSm,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: _statusColor(status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${user?['name'] ?? 'Unknown'} · ${user?['email'] ?? ''}',
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${DateFormat.yMMMd().format(updatedAt)}',
                                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                              ),
                              if (status == 'approved') ...[  
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _unlockGoal(goal['id']),
                                    icon: const Icon(Icons.lock_open, size: 16),
                                    label: const Text('Unlock Goal'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.errorDeep,
                                      side: const BorderSide(color: AppColors.errorDeep),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
