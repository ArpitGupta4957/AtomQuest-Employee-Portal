import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Live Completion Dashboard — replaces the hardcoded mock analytics screen.
class OrganizationAnalyticsScreen extends StatefulWidget {
  const OrganizationAnalyticsScreen({super.key});

  @override
  State<OrganizationAnalyticsScreen> createState() =>
      _OrganizationAnalyticsScreenState();
}

class _OrganizationAnalyticsScreenState
    extends State<OrganizationAnalyticsScreen> {
  final SupabaseService _supabase = SupabaseService.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _employeeCheckinStatus = [];
  Map<String, int> _goalsByStatus = {};
  int _totalGoals = 0;
  int _totalUsers = 0;
  int _checkinsDone = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch all goals with their check-ins and employee names
      final goalsResponse = await _supabase.client
          .from('goals')
          .select(
            'id, status, employee_id, quarterly_checkins(id, quarter, status), users(name, email)',
          );

      final goals = List<Map<String, dynamic>>.from(goalsResponse);
      _totalGoals = goals.length;

      // 2. Aggregate goal counts by status
      final statusMap = <String, int>{};
      for (var g in goals) {
        final s = g['status'] as String? ?? 'unknown';
        statusMap[s] = (statusMap[s] ?? 0) + 1;
      }
      _goalsByStatus = statusMap;

      // 3. Completion dashboard: group by employee
      final employeeMap = <String, Map<String, dynamic>>{};
      for (var g in goals) {
        final empId = g['employee_id'] as String;
        final empName = (g['users'] as Map?)?.get('name') ?? 'Unknown';
        final empEmail = (g['users'] as Map?)?.get('email') ?? '';
        final checkins = List<Map<String, dynamic>>.from(
          g['quarterly_checkins'] ?? [],
        );

        if (!employeeMap.containsKey(empId)) {
          employeeMap[empId] = {
            'name': empName,
            'email': empEmail,
            'totalGoals': 0,
            'checkinsCompleted': 0,
          };
        }
        employeeMap[empId]!['totalGoals'] =
            (employeeMap[empId]!['totalGoals'] as int) + 1;
        employeeMap[empId]!['checkinsCompleted'] =
            (employeeMap[empId]!['checkinsCompleted'] as int) + checkins.length;
      }

      _employeeCheckinStatus = employeeMap.values.toList();
      _totalUsers = _employeeCheckinStatus.length;
      _checkinsDone = _employeeCheckinStatus
          .where((e) => (e['checkinsCompleted'] as int) > 0)
          .length;
    } catch (e) {
      print('Error fetching analytics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(
                isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.containerMax,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion Dashboard',
                      style: AppTypography.headlineLg,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time check-in and goal completion status across the organization.',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Summary KPIs ──
                    Row(
                      children: [
                        _KpiCard(
                          title: 'Total Employees',
                          value: '$_totalUsers',
                          icon: Icons.people_outline,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _KpiCard(
                          title: 'Check-ins Filed',
                          value: '$_checkinsDone / $_totalUsers',
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _KpiCard(
                          title: 'Total Goals',
                          value: '$_totalGoals',
                          icon: Icons.track_changes_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Goals by Status Chart ──
                    if (_goalsByStatus.isNotEmpty) ...[
                      Text('Goals by Status', style: AppTypography.headlineMd),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl,
                          ),
                          border: Border.all(color: AppColors.surfaceContainer),
                        ),
                        child: _buildStatusChart(),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // ── Per-Employee Check-in Table ──
                    Text(
                      'Employee Check-in Status',
                      style: AppTypography.headlineMd,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                        border: Border.all(color: AppColors.surfaceContainer),
                      ),
                      child: Column(
                        children: [
                          // Header
                          _TableRow(
                            name: 'Employee',
                            email: 'Email',
                            goals: 'Goals',
                            checkins: 'Check-ins',
                            isHeader: true,
                          ),
                          const Divider(height: 1),
                          ..._employeeCheckinStatus.map((emp) {
                            final checkins = emp['checkinsCompleted'] as int;
                            final goals = emp['totalGoals'] as int;
                            return Column(
                              children: [
                                _TableRow(
                                  name: emp['name'],
                                  email: emp['email'],
                                  goals: '$goals',
                                  checkins: checkins > 0
                                      ? '✅ $checkins filed'
                                      : '⚠️ None',
                                  isDone: checkins > 0,
                                ),
                                const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusChart() {
    final colors = {
      'approved': Colors.green,
      'inProgress': AppColors.primary,
      'pendingApproval': Colors.orange,
      'rejected': AppColors.errorDeep,
      'draft': AppColors.textMuted,
      'completed': Colors.teal,
    };

    final entries = _goalsByStatus.entries.toList();
    final total = _goalsByStatus.values.fold(0, (a, b) => a + b);

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: entries.map((e) {
                final pct = total > 0 ? (e.value / total * 100) : 0.0;
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  title: '${pct.toStringAsFixed(0)}%',
                  color: colors[e.key] ?? Colors.grey,
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[e.key] ?? Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.key} (${e.value})',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.surfaceContainer),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: AppTypography.headlineSm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String name;
  final String email;
  final String goals;
  final String checkins;
  final bool isHeader;
  final bool isDone;

  const _TableRow({
    required this.name,
    required this.email,
    required this.goals,
    required this.checkins,
    this.isHeader = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? AppTypography.labelSm.copyWith(color: AppColors.textMuted)
        : AppTypography.bodyMd;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: style)),
          Expanded(
            flex: 3,
            child: Text(
              email,
              style: style.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(goals, style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(
              checkins,
              style: style.copyWith(
                color: isHeader
                    ? null
                    : (isDone ? Colors.green : Colors.orange),
                fontWeight: isHeader ? null : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension MapExt on Map {
  dynamic get(String key) => this[key];
}
