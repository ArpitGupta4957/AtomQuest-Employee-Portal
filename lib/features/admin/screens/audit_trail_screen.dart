import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class AuditTrailScreen extends StatefulWidget {
  const AuditTrailScreen({super.key});

  @override
  State<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends State<AuditTrailScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      // Assuming foreign key relation to users table exists
      final response = await _supabase.client
          .from('audit_logs')
          .select('*, users(name)')
          .order('timestamp', ascending: false)
          .limit(100);

      setState(() {
        _logs = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching audit logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Audit Trail'),
        backgroundColor: AppColors.surfaceWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLogs,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _logs.isEmpty
            ? const Center(child: Text('No audit logs found.'))
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  final timestamp = DateTime.parse(log['timestamp']);
                  final userName = log['users']?['name'] ?? 'System/Unknown';
                  final action = log['action'] ?? 'Unknown Action';
                  final newValue = log['new_value'] ?? '';

                  return Card(
                    color: AppColors.surfaceWhite,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.history, color: AppColors.primary),
                      ),
                      title: Text('$userName performed $action', style: AppTypography.labelMd),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (newValue.isNotEmpty) Text('Details: $newValue', style: AppTypography.bodySm),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy - h:mm a').format(timestamp),
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      isThreeLine: newValue.isNotEmpty,
                    ),
                  );
                },
              ),
    );
  }
}
