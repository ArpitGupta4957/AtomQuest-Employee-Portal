import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class CycleManagementScreen extends StatefulWidget {
  const CycleManagementScreen({super.key});

  @override
  State<CycleManagementScreen> createState() => _CycleManagementScreenState();
}

class _CycleManagementScreenState extends State<CycleManagementScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  List<PerformanceCycle> _cycles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCycles();
  }

  Future<void> _fetchCycles() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.client
          .from('performance_cycles')
          .select()
          .order('year', ascending: false);

      final cycles = (response as List).map((json) {
        return PerformanceCycle(
          id: json['id'],
          name: json['name'],
          year: json['year'],
          startDate: DateTime.parse(json['start_date']),
          endDate: DateTime.parse(json['end_date']),
          isActive: json['is_active'] ?? false,
        );
      }).toList();

      setState(() => _cycles = cycles);
    } catch (e) {
      print('Error fetching cycles: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive(PerformanceCycle cycle, bool isActive) async {
    try {
      if (isActive) {
        // Deactivate all others first (business logic: only 1 active cycle)
        await _supabase.client
            .from('performance_cycles')
            .update({'is_active': false})
            .neq('id', '00000000-0000-0000-0000-000000000000'); // hack to target all
      }
      
      await _supabase.client
          .from('performance_cycles')
          .update({'is_active': isActive})
          .eq('id', cycle.id);
          
      _fetchCycles();
    } catch (e) {
      print('Error toggling cycle: $e');
    }
  }

  Future<void> _showAddCycleDialog() async {
    final nameController = TextEditingController(text: 'FY 2024-25');
    final yearController = TextEditingController(text: '2024');
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 365));

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Cycle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Cycle Name'),
              ),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year (e.g. 2024)'),
              ),
              // Simplified for hackathon: fixed dates in UI for demo
              const SizedBox(height: AppSpacing.md),
              Text('Start: ${DateFormat.yMMMd().format(startDate)}', style: AppTypography.bodySm),
              Text('End: ${DateFormat.yMMMd().format(endDate)}', style: AppTypography.bodySm),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _supabase.client.from('performance_cycles').insert({
                  'id': const Uuid().v4(),
                  'name': nameController.text,
                  'year': int.parse(yearController.text),
                  'start_date': startDate.toIso8601String(),
                  'end_date': endDate.toIso8601String(),
                  'is_active': false,
                });
                Navigator.pop(context);
                _fetchCycles();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cycle Management'),
        backgroundColor: AppColors.surfaceWhite,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCycleDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Cycle'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _cycles.length,
            itemBuilder: (context, index) {
              final cycle = _cycles[index];
              return Card(
                color: AppColors.surfaceWhite,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  title: Text(cycle.name, style: AppTypography.headlineSm),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(cycle.startDate)} - ${DateFormat.yMMMd().format(cycle.endDate)}',
                  ),
                  trailing: Switch(
                    value: cycle.isActive,
                    activeColor: AppColors.primary,
                    onChanged: (val) => _toggleActive(cycle, val),
                  ),
                ),
              );
            },
          ),
    );
  }
}
