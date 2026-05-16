import '../models/enums.dart';
import '../models/models.dart';

/// Demo data seed for hackathon presentation.
/// Contains realistic enterprise data across all roles.
class DemoData {
  DemoData._();

  // ── Departments ──
  static final List<Department> departments = [
    const Department(id: 'dept-001', name: 'Engineering', headId: 'mgr-001', employeeCount: 42),
    const Department(id: 'dept-002', name: 'Marketing', headId: 'mgr-002', employeeCount: 18),
    const Department(id: 'dept-003', name: 'Sales', headId: 'mgr-003', employeeCount: 25),
    const Department(id: 'dept-004', name: 'Product', headId: 'mgr-004', employeeCount: 15),
    const Department(id: 'dept-005', name: 'HR & Operations', headId: 'mgr-005', employeeCount: 12),
    const Department(id: 'dept-006', name: 'Design', headId: 'mgr-001', employeeCount: 10),
    const Department(id: 'dept-007', name: 'QA', headId: 'mgr-001', employeeCount: 8),
  ];

  // ── Users ──
  static final List<AppUser> users = [
    // Employees
    AppUser(
      id: 'emp-001',
      name: 'Sarah Jenkins',
      email: 'sarah.jenkins@atomberg.com',
      role: UserRole.employee,
      department: 'Design',
      designation: 'Senior Product Designer',
      managerId: 'mgr-001',
      joinedDate: DateTime(2022, 3, 15),
    ),
    AppUser(
      id: 'emp-002',
      name: 'David Kim',
      email: 'david.kim@atomberg.com',
      role: UserRole.employee,
      department: 'Engineering',
      designation: 'Frontend Developer',
      managerId: 'mgr-001',
      joinedDate: DateTime(2021, 8, 1),
    ),
    AppUser(
      id: 'emp-003',
      name: 'Elena Rodriguez',
      email: 'elena.rodriguez@atomberg.com',
      role: UserRole.employee,
      department: 'Design',
      designation: 'UX Designer',
      managerId: 'mgr-001',
      joinedDate: DateTime(2023, 1, 10),
    ),
    AppUser(
      id: 'emp-004',
      name: 'Sam Smith',
      email: 'sam.smith@atomberg.com',
      role: UserRole.employee,
      department: 'Product',
      designation: 'Product Manager',
      managerId: 'mgr-004',
      joinedDate: DateTime(2022, 6, 1),
    ),
    AppUser(
      id: 'emp-005',
      name: 'Michael Chen',
      email: 'michael.chen@atomberg.com',
      role: UserRole.employee,
      department: 'Engineering',
      designation: 'Backend Developer',
      managerId: 'mgr-001',
      joinedDate: DateTime(2021, 4, 20),
    ),
    AppUser(
      id: 'emp-006',
      name: 'Priya Sharma',
      email: 'priya.sharma@atomberg.com',
      role: UserRole.employee,
      department: 'Marketing',
      designation: 'Marketing Specialist',
      managerId: 'mgr-002',
      joinedDate: DateTime(2023, 5, 1),
    ),
    AppUser(
      id: 'emp-007',
      name: 'James Wilson',
      email: 'james.wilson@atomberg.com',
      role: UserRole.employee,
      department: 'Sales',
      designation: 'Sales Executive',
      managerId: 'mgr-003',
      joinedDate: DateTime(2022, 9, 15),
    ),
    AppUser(
      id: 'emp-008',
      name: 'Anita Desai',
      email: 'anita.desai@atomberg.com',
      role: UserRole.employee,
      department: 'Engineering',
      designation: 'Full Stack Developer',
      managerId: 'mgr-001',
      joinedDate: DateTime(2023, 2, 1),
    ),
    // Managers
    AppUser(
      id: 'mgr-001',
      name: 'Rahul Verma',
      email: 'rahul.verma@atomberg.com',
      role: UserRole.manager,
      department: 'Engineering',
      designation: 'Engineering Lead',
      joinedDate: DateTime(2020, 1, 1),
    ),
    AppUser(
      id: 'mgr-002',
      name: 'Lisa Chang',
      email: 'lisa.chang@atomberg.com',
      role: UserRole.manager,
      department: 'Marketing',
      designation: 'Marketing Head',
      joinedDate: DateTime(2020, 6, 1),
    ),
    AppUser(
      id: 'mgr-003',
      name: 'Vikram Patel',
      email: 'vikram.patel@atomberg.com',
      role: UserRole.manager,
      department: 'Sales',
      designation: 'Sales Director',
      joinedDate: DateTime(2019, 3, 1),
    ),
    AppUser(
      id: 'mgr-004',
      name: 'Jennifer Lee',
      email: 'jennifer.lee@atomberg.com',
      role: UserRole.manager,
      department: 'Product',
      designation: 'VP Product',
      joinedDate: DateTime(2019, 1, 15),
    ),
    AppUser(
      id: 'mgr-005',
      name: 'Deepak Nair',
      email: 'deepak.nair@atomberg.com',
      role: UserRole.manager,
      department: 'HR & Operations',
      designation: 'HR Director',
      joinedDate: DateTime(2020, 8, 1),
    ),
    // Admin
    AppUser(
      id: 'admin-001',
      name: 'Arjun Mehta',
      email: 'arjun.mehta@atomberg.com',
      role: UserRole.admin,
      department: 'HR & Operations',
      designation: 'CHRO',
      joinedDate: DateTime(2018, 1, 1),
    ),
  ];

  // ── Goals for Sarah (Employee Demo) ──
  static List<Goal> get sarahGoals => [
    Goal(
      id: 'goal-001',
      employeeId: 'emp-001',
      title: 'Launch Q3 Product Campaign',
      description: 'Coordinate with marketing to deploy the new energy-efficient fan campaign across digital channels.',
      thrustArea: ThrustArea.strategicInitiative,
      uomType: UoMType.percentage,
      target: 100,
      weightage: 25,
      status: GoalStatus.inProgress,
      startDate: DateTime(2024, 7, 1),
      targetDate: DateTime(2024, 9, 30),
      createdAt: DateTime(2024, 7, 1),
      updatedAt: DateTime(2024, 8, 15),
      checkIns: {
        Quarter.q1: const QuarterlyCheckIn(
          quarter: Quarter.q1,
          achievement: 90,
          selfRating: 4,
          notes: 'Initial campaign strategy completed ahead of schedule.',
          status: GoalStatus.completed,
          managerComment: 'Excellent groundwork laid for Q3.',
        ),
        Quarter.q2: const QuarterlyCheckIn(
          quarter: Quarter.q2,
          achievement: 75,
          selfRating: 4,
          notes: 'Creative assets in final review. Media buy confirmed.',
          status: GoalStatus.completed,
        ),
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 65,
          selfRating: 3,
          notes: 'Campaign live on 3/5 channels. Remaining launches next week.',
          status: GoalStatus.inProgress,
        ),
      },
      comments: [
        GoalComment(
          id: 'cmt-001',
          userId: 'mgr-001',
          userName: 'Rahul Verma',
          userRole: UserRole.manager,
          content: 'Great progress on the digital channels. Let\'s discuss the remaining 2 channels in our next 1:1.',
          createdAt: DateTime(2024, 8, 10),
        ),
      ],
    ),
    Goal(
      id: 'goal-002',
      employeeId: 'emp-001',
      title: 'Quarterly Sales Training',
      description: 'Design and deliver comprehensive sales training program for Q3 product line.',
      thrustArea: ThrustArea.teamDevelopment,
      uomType: UoMType.numeric,
      target: 50,
      weightage: 20,
      status: GoalStatus.completed,
      startDate: DateTime(2024, 4, 1),
      targetDate: DateTime(2024, 6, 30),
      createdAt: DateTime(2024, 4, 1),
      updatedAt: DateTime(2024, 6, 28),
      checkIns: {
        Quarter.q2: const QuarterlyCheckIn(
          quarter: Quarter.q2,
          achievement: 52,
          selfRating: 5,
          notes: 'Trained 52 team members across 4 departments.',
          status: GoalStatus.completed,
          managerComment: 'Outstanding execution. Training NPS was 4.8/5.',
        ),
      },
    ),
    Goal(
      id: 'goal-003',
      employeeId: 'emp-001',
      title: 'Q3 Design System Update',
      description: 'Audit existing UI components and prepare a migration plan for the new styling tokens.',
      thrustArea: ThrustArea.innovation,
      uomType: UoMType.percentage,
      target: 100,
      weightage: 20,
      status: GoalStatus.pendingApproval,
      startDate: DateTime(2024, 7, 1),
      targetDate: DateTime(2024, 9, 30),
      createdAt: DateTime(2024, 7, 1),
      updatedAt: DateTime(2024, 8, 20),
      checkIns: {
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 40,
          selfRating: 3,
          notes: 'Component audit complete. Migration plan in draft.',
          status: GoalStatus.inProgress,
        ),
      },
    ),
    Goal(
      id: 'goal-004',
      employeeId: 'emp-001',
      title: 'Increase Active User Engagement by 25%',
      description: 'Implement UX improvements and feature optimizations to boost monthly active engagement metrics.',
      thrustArea: ThrustArea.customerSuccess,
      uomType: UoMType.percentage,
      target: 25,
      weightage: 15,
      status: GoalStatus.inProgress,
      startDate: DateTime(2024, 1, 1),
      targetDate: DateTime(2024, 12, 31),
      createdAt: DateTime(2024, 1, 5),
      updatedAt: DateTime(2024, 8, 10),
      checkIns: {
        Quarter.q1: const QuarterlyCheckIn(
          quarter: Quarter.q1,
          achievement: 5,
          selfRating: 3,
          notes: 'Baseline metrics established. A/B test framework setup.',
          status: GoalStatus.completed,
        ),
        Quarter.q2: const QuarterlyCheckIn(
          quarter: Quarter.q2,
          achievement: 12,
          selfRating: 4,
          notes: 'First redesign shipped. 12% uplift measured.',
          status: GoalStatus.completed,
        ),
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 15,
          selfRating: 3,
          notes: 'Second phase in testing. Preliminary data shows +3% additional.',
          status: GoalStatus.inProgress,
        ),
      },
    ),
    Goal(
      id: 'goal-005',
      employeeId: 'emp-001',
      title: 'Launch New Onboarding Module',
      description: 'Revamping the digital experience for incoming hires across all departments.',
      thrustArea: ThrustArea.processImprovement,
      uomType: UoMType.percentage,
      target: 100,
      weightage: 10,
      status: GoalStatus.inProgress,
      isShared: true,
      sharedGoalId: 'sg-001',
      startDate: DateTime(2024, 6, 1),
      targetDate: DateTime(2024, 10, 31),
      createdAt: DateTime(2024, 6, 1),
      updatedAt: DateTime(2024, 8, 18),
      checkIns: {
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 85,
          selfRating: 4,
          notes: 'Module 90% complete. Final user testing in progress.',
          status: GoalStatus.inProgress,
        ),
      },
    ),
    Goal(
      id: 'goal-006',
      employeeId: 'emp-001',
      title: 'Reduce Customer Support Tickets by 15%',
      description: 'Implement self-service features and improved documentation to reduce support volume.',
      thrustArea: ThrustArea.operationalExcellence,
      uomType: UoMType.percentage,
      target: 15,
      weightage: 10,
      status: GoalStatus.inProgress,
      startDate: DateTime(2024, 1, 1),
      targetDate: DateTime(2024, 12, 31),
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime(2024, 7, 30),
      checkIns: {
        Quarter.q2: const QuarterlyCheckIn(
          quarter: Quarter.q2,
          achievement: 8,
          selfRating: 3,
          notes: 'FAQ section revamped. Chatbot V1 deployed.',
          status: GoalStatus.completed,
        ),
      },
    ),
  ];

  // ── Goals for other team members (Manager View) ──
  static List<Goal> get teamGoals => [
    // David Kim's goals
    Goal(
      id: 'goal-dk-001',
      employeeId: 'emp-002',
      title: 'API Integration Milestone',
      description: 'Complete Phase 2 API integration with payment gateway and third-party analytics.',
      thrustArea: ThrustArea.strategicInitiative,
      uomType: UoMType.percentage,
      target: 100,
      weightage: 30,
      status: GoalStatus.pendingApproval,
      startDate: DateTime(2024, 7, 1),
      targetDate: DateTime(2024, 10, 15),
      createdAt: DateTime(2024, 7, 5),
      updatedAt: DateTime(2024, 8, 20),
      checkIns: {
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 80,
          selfRating: 4,
          status: GoalStatus.inProgress,
        ),
      },
    ),
    Goal(
      id: 'goal-dk-002',
      employeeId: 'emp-002',
      title: 'Frontend Performance Optimization',
      description: 'Achieve <2s page load across all critical user flows.',
      thrustArea: ThrustArea.operationalExcellence,
      uomType: UoMType.numeric,
      target: 2,
      weightage: 25,
      status: GoalStatus.inProgress,
      startDate: DateTime(2024, 6, 1),
      targetDate: DateTime(2024, 9, 30),
      createdAt: DateTime(2024, 6, 1),
      updatedAt: DateTime(2024, 8, 15),
      checkIns: {
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 80,
          selfRating: 4,
          status: GoalStatus.inProgress,
        ),
      },
    ),
    // Elena Rodriguez's goals
    Goal(
      id: 'goal-er-001',
      employeeId: 'emp-003',
      title: 'Design System V2 Migration',
      description: 'Lead migration of 40+ components to new design system tokens.',
      thrustArea: ThrustArea.innovation,
      uomType: UoMType.percentage,
      target: 100,
      weightage: 35,
      status: GoalStatus.inProgress,
      startDate: DateTime(2024, 5, 1),
      targetDate: DateTime(2024, 11, 30),
      createdAt: DateTime(2024, 5, 1),
      updatedAt: DateTime(2024, 8, 10),
      checkIns: {
        Quarter.q2: const QuarterlyCheckIn(
          quarter: Quarter.q2,
          achievement: 30,
          selfRating: 3,
          status: GoalStatus.completed,
        ),
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 45,
          selfRating: 3,
          status: GoalStatus.inProgress,
        ),
      },
    ),
    // Michael Chen's goals
    Goal(
      id: 'goal-mc-001',
      employeeId: 'emp-005',
      title: 'Microservices Architecture Migration',
      description: 'Decompose monolith into 6 core microservices with full CI/CD pipelines.',
      thrustArea: ThrustArea.strategicInitiative,
      uomType: UoMType.numeric,
      target: 6,
      weightage: 40,
      status: GoalStatus.inProgress,
      startDate: DateTime(2024, 1, 1),
      targetDate: DateTime(2024, 12, 31),
      createdAt: DateTime(2024, 1, 5),
      updatedAt: DateTime(2024, 8, 20),
      checkIns: {
        Quarter.q1: const QuarterlyCheckIn(
          quarter: Quarter.q1,
          achievement: 1,
          selfRating: 4,
          status: GoalStatus.completed,
        ),
        Quarter.q2: const QuarterlyCheckIn(
          quarter: Quarter.q2,
          achievement: 3,
          selfRating: 4,
          status: GoalStatus.completed,
        ),
        Quarter.q3: const QuarterlyCheckIn(
          quarter: Quarter.q3,
          achievement: 4,
          selfRating: 3,
          status: GoalStatus.inProgress,
        ),
      },
    ),
  ];

  // ── Shared Goals ──
  static final List<SharedGoal> sharedGoals = [
    SharedGoal(
      id: 'sg-001',
      title: 'Launch New Onboarding Module',
      description: 'Revamping the digital experience for incoming hires across all departments.',
      thrustArea: ThrustArea.processImprovement,
      uomType: UoMType.percentage,
      target: 100,
      createdBy: 'admin-001',
      assignedEmployeeIds: ['emp-001', 'emp-002', 'emp-004', 'emp-006'],
      assignedDepartmentIds: ['dept-001', 'dept-002'],
      targetDate: DateTime(2024, 10, 31),
      createdAt: DateTime(2024, 6, 1),
    ),
    SharedGoal(
      id: 'sg-002',
      title: 'Company Sustainability Goal Q4',
      description: 'Reduce carbon footprint by 20% through operational improvements.',
      thrustArea: ThrustArea.sustainability,
      uomType: UoMType.percentage,
      target: 20,
      createdBy: 'admin-001',
      assignedEmployeeIds: ['emp-001', 'emp-003', 'emp-005', 'emp-007', 'emp-008'],
      assignedDepartmentIds: ['dept-001', 'dept-003'],
      targetDate: DateTime(2024, 12, 31),
      createdAt: DateTime(2024, 9, 1),
    ),
    SharedGoal(
      id: 'sg-003',
      title: 'Customer NPS Score Improvement',
      description: 'Achieve NPS score of 75+ across all product lines.',
      thrustArea: ThrustArea.customerSuccess,
      uomType: UoMType.numeric,
      target: 75,
      createdBy: 'mgr-004',
      assignedEmployeeIds: ['emp-004', 'emp-006', 'emp-007'],
      assignedDepartmentIds: ['dept-002', 'dept-003', 'dept-004'],
      targetDate: DateTime(2024, 12, 31),
      createdAt: DateTime(2024, 7, 1),
    ),
  ];

  // ── Notifications for Sarah ──
  static List<AppNotification> get sarahNotifications => [
    AppNotification(
      id: 'notif-001',
      type: NotificationType.goalApproved,
      title: 'Goal Approved',
      body: 'Launch Q3 Campaign has been approved by Rahul Verma.',
      relatedGoalId: 'goal-001',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      id: 'notif-002',
      type: NotificationType.checkInReminder,
      title: 'Check-in Reminder',
      body: 'Q3 quarterly check-in is due in 2 days.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    AppNotification(
      id: 'notif-003',
      type: NotificationType.managerFeedback,
      title: 'New Feedback from Manager',
      body: '"Great work on the recent Q2 report presentation. The insights were clear and actionable."',
      relatedGoalId: 'goal-002',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'notif-004',
      type: NotificationType.sharedGoalAssigned,
      title: 'Shared Goal Assigned',
      body: 'You have been assigned to "Company Sustainability Goal Q4" by Admin.',
      relatedGoalId: 'sg-002',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AppNotification(
      id: 'notif-005',
      type: NotificationType.quarterlyAlert,
      title: 'Q3 Deadline Approaching',
      body: '3 goals require Q3 updates before September 30.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ── Activity Feed ──
  static List<ActivityItem> get recentActivity => [
    ActivityItem(
      id: 'act-001',
      title: 'Q2 Performance Review completed.',
      icon: 'check_circle',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ActivityItem(
      id: 'act-002',
      title: 'David left a comment on Design Handoff.',
      icon: 'comment',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      userId: 'emp-002',
    ),
    ActivityItem(
      id: 'act-003',
      title: 'You uploaded a new document Q3_Strategy.pdf.',
      icon: 'upload_file',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ActivityItem(
      id: 'act-004',
      title: 'Goal "Launch Q3 Campaign" status updated to In Progress.',
      icon: 'trending_up',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    ),
    ActivityItem(
      id: 'act-005',
      title: 'Shared goal "Onboarding Module" progress updated to 85%.',
      icon: 'share',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // ── Performance Cycle ──
  static final PerformanceCycle currentCycle = PerformanceCycle(
    id: 'cycle-2024',
    name: 'FY 2024-25',
    year: 2024,
    startDate: DateTime(2024, 4, 1),
    endDate: DateTime(2025, 3, 31),
    isActive: true,
  );

  // ── Analytics Data ──
  static Map<String, double> get departmentCompletion => {
    'Engineering': 88,
    'Marketing': 72,
    'Sales': 81,
    'Product': 90,
    'HR & Ops': 95,
    'Design': 85,
    'QA': 78,
  };

  static Map<String, Map<String, double>> get quarterlyDeptPerformance => {
    'Engineering': {'Q1': 88, 'Q2': 92, 'Q3': 85},
    'Sales': {'Q1': 72, 'Q2': 78, 'Q3': 75},
    'Marketing': {'Q1': 81, 'Q2': 75, 'Q3': 79},
    'HR & Ops': {'Q1': 90, 'Q2': 95, 'Q3': 92},
  };

  static Map<String, double> get managerEffectiveness => {
    'Sarah Jenkins (Eng)': 96,
    'Michael Chang (HR)': 92,
    'Elena Rodriguez (Sales)': 85,
    'David Kim (Mktg)': 78,
  };

  static Map<String, double> get goalDistribution => {
    'On Track': 45,
    'At Risk': 25,
    'Completed': 20,
    'Overdue': 10,
  };

  // Helper to get user by id
  static AppUser getUserById(String id) {
    return users.firstWhere(
      (u) => u.id == id,
      orElse: () => users.first,
    );
  }

  // Helper to get team members for a manager
  static List<AppUser> getTeamMembers(String managerId) {
    return users.where((u) => u.managerId == managerId).toList();
  }

  // Helper to get all goals for a user
  static List<Goal> getGoalsForUser(String userId) {
    if (userId == 'emp-001') return sarahGoals;
    return teamGoals.where((g) => g.employeeId == userId).toList();
  }
}
