import 'enums.dart';

/// User model representing an employee, manager, or admin.
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String designation;
  final String? avatarUrl;
  final String? managerId;
  final DateTime joinedDate;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.designation,
    this.avatarUrl,
    this.managerId,
    required this.joinedDate,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? department,
    String? designation,
    String? avatarUrl,
    String? managerId,
    DateTime? joinedDate,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      managerId: managerId ?? this.managerId,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}

/// Department model
class Department {
  final String id;
  final String name;
  final String? headId;
  final int employeeCount;

  const Department({
    required this.id,
    required this.name,
    this.headId,
    required this.employeeCount,
  });
}

/// Goal model — the core entity of the system.
class Goal {
  final String id;
  final String employeeId;
  final String title;
  final String description;
  final ThrustArea thrustArea;
  final UoMType uomType;
  final double target;
  final double weightage;
  final GoalStatus status;
  final Map<Quarter, QuarterlyCheckIn> checkIns;
  final List<GoalComment> comments;
  final List<AuditEntry> auditHistory;
  final String? sharedGoalId;
  final bool isShared;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.description,
    required this.thrustArea,
    required this.uomType,
    required this.target,
    required this.weightage,
    required this.status,
    this.checkIns = const {},
    this.comments = const [],
    this.auditHistory = const [],
    this.sharedGoalId,
    this.isShared = false,
    required this.startDate,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computed overall progress based on quarterly achievements and BRD formulas
  double get progressPercent {
    if (checkIns.isEmpty) return 0;
    
    // Find the latest check-in for progress calculation
    final latestCheckIn = checkIns.values.last;
    if (latestCheckIn.achievement == null) return 0;
    
    final achieved = latestCheckIn.achievement!;

    switch (uomType) {
      case UoMType.numeric:
      case UoMType.percentage:
        // Min (Higher is better): Achievement ÷ Target
        if (target == 0) return 0;
        return ((achieved / target) * 100).clamp(0, 100);
        
      case UoMType.timeline:
        // Timeline: Date-based completion
        // If achieved == 1.0 (completed) within targetDate -> 100%
        return achieved >= 1 ? 100 : 0;
        
      case UoMType.zeroBased:
        // Zero = Success: If 0 -> 100%, else 0%
        return achieved == 0 ? 100 : 0;
    }
  }

  /// Weighted score contribution
  double get weightedScore => (progressPercent * weightage) / 100;

  Goal copyWith({
    String? id,
    String? employeeId,
    String? title,
    String? description,
    ThrustArea? thrustArea,
    UoMType? uomType,
    double? target,
    double? weightage,
    GoalStatus? status,
    Map<Quarter, QuarterlyCheckIn>? checkIns,
    List<GoalComment>? comments,
    List<AuditEntry>? auditHistory,
    String? sharedGoalId,
    bool? isShared,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      title: title ?? this.title,
      description: description ?? this.description,
      thrustArea: thrustArea ?? this.thrustArea,
      uomType: uomType ?? this.uomType,
      target: target ?? this.target,
      weightage: weightage ?? this.weightage,
      status: status ?? this.status,
      checkIns: checkIns ?? this.checkIns,
      comments: comments ?? this.comments,
      auditHistory: auditHistory ?? this.auditHistory,
      sharedGoalId: sharedGoalId ?? this.sharedGoalId,
      isShared: isShared ?? this.isShared,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Quarterly check-in data for a goal
class QuarterlyCheckIn {
  final Quarter quarter;
  final double? achievement;
  final int? selfRating;
  final String? notes;
  final GoalStatus status;
  final DateTime? submittedAt;
  final String? managerComment;

  const QuarterlyCheckIn({
    required this.quarter,
    this.achievement,
    this.selfRating,
    this.notes,
    this.status = GoalStatus.draft,
    this.submittedAt,
    this.managerComment,
  });

  QuarterlyCheckIn copyWith({
    Quarter? quarter,
    double? achievement,
    int? selfRating,
    String? notes,
    GoalStatus? status,
    DateTime? submittedAt,
    String? managerComment,
  }) {
    return QuarterlyCheckIn(
      quarter: quarter ?? this.quarter,
      achievement: achievement ?? this.achievement,
      selfRating: selfRating ?? this.selfRating,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      managerComment: managerComment ?? this.managerComment,
    );
  }
}

/// Comment on a goal
class GoalComment {
  final String id;
  final String userId;
  final String userName;
  final UserRole userRole;
  final String content;
  final DateTime createdAt;

  const GoalComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    required this.createdAt,
  });
}

/// Shared goal template
class SharedGoal {
  final String id;
  final String title;
  final String description;
  final ThrustArea thrustArea;
  final UoMType uomType;
  final double target;
  final String createdBy;
  final List<String> assignedEmployeeIds;
  final List<String> assignedDepartmentIds;
  final DateTime targetDate;
  final DateTime createdAt;

  const SharedGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.thrustArea,
    required this.uomType,
    required this.target,
    required this.createdBy,
    this.assignedEmployeeIds = const [],
    this.assignedDepartmentIds = const [],
    required this.targetDate,
    required this.createdAt,
  });

  int get totalAssignees => assignedEmployeeIds.length;
}

/// Audit log entry
class AuditEntry {
  final String id;
  final AuditAction action;
  final String userId;
  final String userName;
  final UserRole userRole;
  final String? oldValue;
  final String? newValue;
  final String? fieldName;
  final DateTime timestamp;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.oldValue,
    this.newValue,
    this.fieldName,
    required this.timestamp,
  });
}

/// App notification
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedGoalId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.relatedGoalId,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      relatedGoalId: relatedGoalId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

/// Activity feed item
class ActivityItem {
  final String id;
  final String title;
  final String? subtitle;
  final String icon;
  final DateTime timestamp;
  final String? userId;

  const ActivityItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.timestamp,
    this.userId,
  });
}

/// Performance cycle configuration
class PerformanceCycle {
  final String id;
  final String name;
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const PerformanceCycle({
    required this.id,
    required this.name,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });
}
