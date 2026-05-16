import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../repositories/goal_repository.dart';

/// GoalProvider — Central state management for goals across all roles.
/// Now connected to Supabase via GoalRepository.
class GoalProvider extends ChangeNotifier {
  final GoalRepository _repository = GoalRepository();

  List<Goal> _goals = [];
  final List<SharedGoal> _sharedGoals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  List<SharedGoal> get sharedGoals => _sharedGoals;
  bool get isLoading => _isLoading;

  // ── Initialization (Real DB Fetch) ──
  Future<void> initializeForUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _repository.getGoalsForEmployee(userId);
      // Fetch shared goals from repository here (omitted for brevity)
    } catch (e) {
      print('Error initializing user goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeForManager(String managerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would fetch goals where the user's manager is managerId
      // For now, we simulate fetching all goals for the team
      // _goals = await _repository.getTeamGoals(managerId);
    } catch (e) {
      print('Error initializing manager goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Goal CRUD (Optimistic UI + DB sync) ──

  List<Goal> getGoalsForEmployee(String employeeId) {
    return _goals.where((g) => g.employeeId == employeeId).toList();
  }

  Goal? getGoalById(String goalId) {
    try {
      return _goals.firstWhere((g) => g.id == goalId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addGoal(Goal goal) async {
    // Optimistic UI Update
    _goals.add(goal);
    notifyListeners();

    // DB Update
    final newGoal = await _repository.createGoal(goal);
    if (newGoal != null) {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = newGoal;
        notifyListeners();
      }
    }
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();
      await _repository.updateGoal(updatedGoal);
    }
  }

  Future<void> submitForApproval(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      // Optimistic update
      _goals[index] = _goals[index].copyWith(
        status: GoalStatus.pendingApproval,
        updatedAt: DateTime.now(),
      );
      notifyListeners();

      // DB update
      await _repository.updateGoalStatus(goalId, GoalStatus.pendingApproval);
    }
  }

  Future<void> approveGoal(String goalId, {String? comment}) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      // Optimistic update
      _goals[index] = goal.copyWith(
        status: GoalStatus.approved,
        updatedAt: DateTime.now(),
      );
      notifyListeners();

      // DB update
      await _repository.updateGoalStatus(goalId, GoalStatus.approved);
      // (Optionally add comment to GoalComment table here via repository)
    }
  }

  Future<void> rejectGoal(String goalId, {String? comment}) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        status: GoalStatus.rejected,
        updatedAt: DateTime.now(),
      );
      notifyListeners();

      await _repository.updateGoalStatus(goalId, GoalStatus.rejected);
    }
  }

  void updateCheckIn(String goalId, Quarter quarter, QuarterlyCheckIn checkIn) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      final newCheckIns = Map<Quarter, QuarterlyCheckIn>.from(goal.checkIns);
      newCheckIns[quarter] = checkIn;
      _goals[index] = goal.copyWith(checkIns: newCheckIns);
      notifyListeners();
    }
  }

  // ── Weightage & Analytics ──

  double get totalWeightage {
    return _goals.fold(0.0, (sum, g) => sum + g.weightage);
  }

  double remainingWeightage({String? excludeGoalId}) {
    final total = _goals
        .where((g) => g.id != excludeGoalId)
        .fold(0.0, (sum, g) => sum + g.weightage);
    return 100.0 - total;
  }

  double get overallProgress {
    if (_goals.isEmpty) return 0;
    return _goals.fold(0.0, (sum, g) => sum + g.progressPercent) /
        _goals.length;
  }

  int get activeGoalCount => _goals
      .where(
        (g) =>
            g.status == GoalStatus.inProgress ||
            g.status == GoalStatus.approved,
      )
      .length;

  int get pendingApprovalCount =>
      _goals.where((g) => g.status == GoalStatus.pendingApproval).length;
}
