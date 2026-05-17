import '../models/models.dart';
import '../models/enums.dart';
import '../services/supabase_service.dart';

class GoalRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// Fetch goals for a specific employee
  Future<List<Goal>> getGoalsForEmployee(String employeeId) async {
    try {
      final response = await _supabase.client
          .from('goals')
          .select('*, quarterly_checkins(*)')
          .eq('employee_id', employeeId);

      return (response as List).map((json) => _parseGoal(json)).toList();
    } catch (e) {
      print('Error fetching goals: $e');
      return [];
    }
  }

  /// Fetch all goals in the system (Admin only)
  Future<List<Goal>> getAllGoals() async {
    try {
      final response = await _supabase.client
          .from('goals')
          .select('*, quarterly_checkins(*)');

      return (response as List).map((json) => _parseGoal(json)).toList();
    } catch (e) {
      print('Error fetching all goals: $e');
      return [];
    }
  }

  /// Fetch goals for a manager's team
  Future<List<Goal>> getTeamGoals(String managerId) async {
    try {
      // Find all employees managed by this manager
      final usersResponse = await _supabase.client
          .from('users')
          .select('id')
          .eq('manager_id', managerId);
          
      final employeeIds = (usersResponse as List).map((u) => u['id'] as String).toList();
      
      if (employeeIds.isEmpty) return [];

      final response = await _supabase.client
          .from('goals')
          .select('*, quarterly_checkins(*)')
          .inFilter('employee_id', employeeIds);

      return (response as List).map((json) => _parseGoal(json)).toList();
    } catch (e) {
      print('Error fetching team goals: $e');
      return [];
    }
  }

  /// Create a new goal
  Future<Goal?> createGoal(Goal goal) async {
    try {
      final response = await _supabase.client
          .from('goals')
          .insert({
            'id': goal.id,
            'employee_id': goal.employeeId,
            'title': goal.title,
            'description': goal.description,
            'thrust_area': goal.thrustArea.name,
            'uom_type': goal.uomType.name,
            'target': goal.target,
            'weightage': goal.weightage,
            'status': goal.status.name,
            'start_date': goal.startDate.toIso8601String(),
            'target_date': goal.targetDate.toIso8601String(),
          })
          .select('*, quarterly_checkins(*)')
          .single();

      final newGoal = _parseGoal(response);
      
      // Log Audit Entry
      await _logAudit(AuditAction.goalCreated, newGoal.id, newGoal.employeeId, 'New goal submitted');

      return newGoal;
    } catch (e) {
      print('Error creating goal: $e');
      return null;
    }
  }

  /// Helper to insert audit log
  Future<void> _logAudit(AuditAction action, String goalId, String userId, String? newValue) async {
    try {
      await _supabase.client.from('audit_logs').insert({
        'action': action.name,
        'goal_id': goalId,
        'user_id': userId,
        'new_value': newValue,
      });
    } catch (e) {
      print('Audit log failed: $e');
    }
  }

  /// Update an entire goal (e.g., inline edits for weightage)
  Future<void> updateGoal(Goal goal) async {
    try {
      await _supabase.client
          .from('goals')
          .update({
            'title': goal.title,
            'description': goal.description,
            'target': goal.target,
            'weightage': goal.weightage,
            'status': goal.status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goal.id);
          
      // Log Audit
      await _logAudit(AuditAction.goalEdited, goal.id, goal.employeeId, 'Weightage updated to ${goal.weightage}');
    } catch (e) {
      print('Error updating goal: $e');
    }
  }

  /// Update goal status (e.g. for approvals)
  Future<void> updateGoalStatus(String goalId, GoalStatus newStatus) async {
    try {
      await _supabase.client
          .from('goals')
          .update({'status': newStatus.name, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', goalId);
          
      // Assuming context has auth user, but for repo we pass system/manager string or use auth.uid() in RLS
      await _logAudit(
        newStatus == GoalStatus.approved ? AuditAction.goalApproved : AuditAction.goalRejected,
        goalId,
        _supabase.client.auth.currentUser?.id ?? '', // Best effort log
        newStatus.name,
      );
    } catch (e) {
      print('Error updating goal status: $e');
    }
  }

  /// Helper to parse Supabase JSON into Goal model
  Goal _parseGoal(Map<String, dynamic> json) {
    // Parse checkins
    Map<Quarter, QuarterlyCheckIn> checkIns = {};
    if (json['quarterly_checkins'] != null) {
      for (var ci in (json['quarterly_checkins'] as List)) {
        final quarter = Quarter.values.byName(ci['quarter']);
        checkIns[quarter] = QuarterlyCheckIn(
          quarter: quarter,
          achievement: ci['achievement'] != null ? (ci['achievement'] as num).toDouble() : null,
          selfRating: ci['self_rating'],
          notes: ci['notes'],
          status: GoalStatus.values.byName(ci['status'] ?? 'draft'),
          managerComment: ci['manager_comment'],
          submittedAt: ci['submitted_at'] != null ? DateTime.parse(ci['submitted_at']) : null,
        );
      }
    }

    return Goal(
      id: json['id'],
      employeeId: json['employee_id'],
      title: json['title'],
      description: json['description'] ?? '',
      thrustArea: ThrustArea.values.byName(json['thrust_area']),
      uomType: UoMType.values.byName(json['uom_type']),
      target: (json['target'] as num).toDouble(),
      weightage: (json['weightage'] as num).toDouble(),
      status: GoalStatus.values.byName(json['status']),
      sharedGoalId: json['shared_goal_id'],
      isShared: json['is_shared'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      targetDate: DateTime.parse(json['target_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
      checkIns: checkIns,
    );
  }
}
