/// Enums for the AtomQuest Goal Tracking System
library;

enum UserRole { employee, manager, admin }

enum GoalStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  notStarted,
  inProgress,
  completed,
  overdue,
  locked,
}

enum UoMType { numeric, percentage, timeline, zeroBased }

enum Quarter { q1, q2, q3, q4 }

enum NotificationType {
  goalApproved,
  goalRejected,
  checkInReminder,
  managerFeedback,
  sharedGoalAssigned,
  quarterlyAlert,
  escalation,
}

enum AuditAction {
  goalCreated,
  goalEdited,
  goalSubmitted,
  goalApproved,
  goalRejected,
  goalUnlocked,
  quarterlyUpdate,
  sharedGoalCreated,
  sharedGoalLinked,
  commentAdded,
  weightageChanged,
}

enum ThrustArea {
  strategicInitiative,
  operationalExcellence,
  innovation,
  customerSuccess,
  teamDevelopment,
  sustainability,
  revenueGrowth,
  processImprovement,
}

// ── Extension Methods ──

extension GoalStatusExtension on GoalStatus {
  String get label {
    switch (this) {
      case GoalStatus.draft:
        return 'Draft';
      case GoalStatus.pendingApproval:
        return 'Pending Approval';
      case GoalStatus.approved:
        return 'Approved';
      case GoalStatus.rejected:
        return 'Rejected';
      case GoalStatus.notStarted:
        return 'Not Started';
      case GoalStatus.inProgress:
        return 'On Track';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.overdue:
        return 'Overdue';
      case GoalStatus.locked:
        return 'Locked';
    }
  }
}

extension UoMTypeExtension on UoMType {
  String get label {
    switch (this) {
      case UoMType.numeric:
        return 'Numeric (Higher is Better)';
      case UoMType.percentage:
        return 'Percentage';
      case UoMType.timeline:
        return 'Timeline-Based';
      case UoMType.zeroBased:
        return 'Zero-Based Metric';
    }
  }

  String get shortLabel {
    switch (this) {
      case UoMType.numeric:
        return 'Numeric';
      case UoMType.percentage:
        return '%';
      case UoMType.timeline:
        return 'Timeline';
      case UoMType.zeroBased:
        return 'Zero-Based';
    }
  }
}

extension QuarterExtension on Quarter {
  String get label {
    switch (this) {
      case Quarter.q1:
        return 'Q1';
      case Quarter.q2:
        return 'Q2';
      case Quarter.q3:
        return 'Q3';
      case Quarter.q4:
        return 'Q4';
    }
  }
}

extension ThrustAreaExtension on ThrustArea {
  String get label {
    switch (this) {
      case ThrustArea.strategicInitiative:
        return 'Strategic Initiative';
      case ThrustArea.operationalExcellence:
        return 'Operational Excellence';
      case ThrustArea.innovation:
        return 'Innovation';
      case ThrustArea.customerSuccess:
        return 'Customer Success';
      case ThrustArea.teamDevelopment:
        return 'Team Development';
      case ThrustArea.sustainability:
        return 'Sustainability';
      case ThrustArea.revenueGrowth:
        return 'Revenue Growth';
      case ThrustArea.processImprovement:
        return 'Process Improvement';
    }
  }
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.manager:
        return 'Manager';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.goalApproved:
        return 'Goal Approved';
      case NotificationType.goalRejected:
        return 'Goal Rejected';
      case NotificationType.checkInReminder:
        return 'Check-in Reminder';
      case NotificationType.managerFeedback:
        return 'Manager Feedback';
      case NotificationType.sharedGoalAssigned:
        return 'Shared Goal Assigned';
      case NotificationType.quarterlyAlert:
        return 'Quarterly Alert';
      case NotificationType.escalation:
        return 'Escalation';
    }
  }
}
