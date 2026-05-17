import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/csv_downloader.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Achievement Report screen with CSV export capability.
class AchievementReportScreen extends StatefulWidget {
  const AchievementReportScreen({super.key});

  @override
  State<AchievementReportScreen> createState() => _AchievementReportScreenState();
}

class _AchievementReportScreenState extends State<AchievementReportScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  List<Map<String, dynamic>> _reportRows = [];
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      // Fetch goals with check-ins and employee info
      final response = await _supabase.client
          .from('goals')
          .select('id, title, thrust_area, uom_type, target, weightage, status, start_date, target_date, users(name, email), quarterly_checkins(quarter, achievement, status, manager_comment)')
          .order('title');

      final rows = <Map<String, dynamic>>[];
      for (var goal in response as List) {
        final user = goal['users'] as Map?;
        final checkins = List<Map<String, dynamic>>.from(goal['quarterly_checkins'] ?? []);

        if (checkins.isEmpty) {
          // Still show goal even if no check-ins
          rows.add({
            'employee': user?['name'] ?? 'Unknown',
            'email': user?['email'] ?? '',
            'goalTitle': goal['title'] ?? '',
            'thrustArea': goal['thrust_area'] ?? '',
            'uom': goal['uom_type'] ?? '',
            'target': goal['target']?.toString() ?? '0',
            'weightage': goal['weightage']?.toString() ?? '0',
            'status': goal['status'] ?? '',
            'quarter': 'N/A',
            'achievement': 'N/A',
            'managerComment': '',
          });
        } else {
          for (var ci in checkins) {
            rows.add({
              'employee': user?['name'] ?? 'Unknown',
              'email': user?['email'] ?? '',
              'goalTitle': goal['title'] ?? '',
              'thrustArea': goal['thrust_area'] ?? '',
              'uom': goal['uom_type'] ?? '',
              'target': goal['target']?.toString() ?? '0',
              'weightage': goal['weightage']?.toString() ?? '0',
              'status': goal['status'] ?? '',
              'quarter': (ci['quarter'] ?? '').toUpperCase(),
              'achievement': ci['achievement']?.toString() ?? 'Not filed',
              'managerComment': ci['manager_comment'] ?? '',
            });
          }
        }
      }

      setState(() => _reportRows = rows);
    } catch (e) {
      print('Error fetching report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _exportCsv() {
    setState(() => _isExporting = true);

    try {
      final buffer = StringBuffer();
      // Header row
      buffer.writeln('Employee Name,Email,Goal Title,Thrust Area,UoM,Target,Weightage (%),Status,Quarter,Actual Achievement,Manager Comment');

      // Data rows
      for (var row in _reportRows) {
        buffer.writeln([
          '"${row['employee']}"',
          '"${row['email']}"',
          '"${row['goalTitle']}"',
          '"${row['thrustArea']}"',
          '"${row['uom']}"',
          '"${row['target']}"',
          '"${row['weightage']}"',
          '"${row['status']}"',
          '"${row['quarter']}"',
          '"${row['achievement']}"',
          '"${row['managerComment']}"',
        ].join(','));
      }

      final csvContent = buffer.toString();
      final fileName = 'achievement_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      downloadCsvFile(csvContent, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ CSV exported successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Export error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export CSV'), backgroundColor: AppColors.errorDeep),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievement Report'),
        backgroundColor: AppColors.surfaceWhite,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _isExporting || _isLoading ? null : _exportCsv,
              icon: _isExporting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportRows.isEmpty
              ? const Center(child: Text('No data available.'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
                      border: TableBorder.all(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                      columns: const [
                        DataColumn(label: Text('Employee')),
                        DataColumn(label: Text('Goal')),
                        DataColumn(label: Text('Thrust Area')),
                        DataColumn(label: Text('UoM')),
                        DataColumn(label: Text('Target')),
                        DataColumn(label: Text('Weightage')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Quarter')),
                        DataColumn(label: Text('Achievement')),
                      ],
                      rows: _reportRows.map((row) {
                        return DataRow(cells: [
                          DataCell(Text(row['employee'], style: AppTypography.labelMd)),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(row['goalTitle'], overflow: TextOverflow.ellipsis, style: AppTypography.bodyMd),
                            ),
                          ),
                          DataCell(Text(row['thrustArea'])),
                          DataCell(Text(row['uom'])),
                          DataCell(Text(row['target'])),
                          DataCell(Text('${row['weightage']}%')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(row['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(row['status'],
                                  style: TextStyle(color: _statusColor(row['status']), fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          DataCell(Text(row['quarter'], style: AppTypography.labelSm.copyWith(color: AppColors.primary))),
                          DataCell(Text(
                            row['achievement'],
                            style: AppTypography.labelMd.copyWith(
                              color: row['achievement'] == 'Not filed' ? AppColors.textMuted : AppColors.onBackground,
                            ),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'inProgress': return AppColors.primary;
      case 'pendingApproval': return Colors.orange;
      case 'rejected': return AppColors.errorDeep;
      case 'completed': return Colors.teal;
      default: return AppColors.textMuted;
    }
  }
}
