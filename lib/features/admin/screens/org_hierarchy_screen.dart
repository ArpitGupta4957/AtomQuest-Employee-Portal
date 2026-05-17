import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/models.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class OrgHierarchyScreen extends StatefulWidget {
  const OrgHierarchyScreen({super.key});

  @override
  State<OrgHierarchyScreen> createState() => _OrgHierarchyScreenState();
}

class _OrgHierarchyScreenState extends State<OrgHierarchyScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  List<AppUser> _users = [];
  List<AppUser> _managers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.client
          .from('users')
          .select('id, name, email, role, department_id, designation, manager_id, joined_date')
          .order('name');

      final allUsers = (response as List).map((json) {
        return AppUser(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          role: UserRole.values.byName(json['role']),
          department: json['department_id'] ?? 'Unknown',
          designation: json['designation'] ?? 'Employee',
          managerId: json['manager_id'],
          joinedDate: DateTime.parse(json['joined_date']),
        );
      }).toList();

      setState(() {
        _users = allUsers;
        _managers = allUsers.where((u) => u.role == UserRole.manager || u.role == UserRole.admin).toList();
      });
    } catch (e) {
      print('Error fetching org hierarchy: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateManager(String userId, String? newManagerId) async {
    try {
      await _supabase.client
          .from('users')
          .update({'manager_id': newManagerId})
          .eq('id', userId);
          
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager updated successfully')),
      );
      _fetchUsers();
    } catch (e) {
      print('Error updating manager: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update manager')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Org Hierarchy Management'),
        backgroundColor: AppColors.surfaceWhite,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                color: AppColors.surfaceWhite,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(user.initials, style: const TextStyle(color: AppColors.primary)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: AppTypography.headlineSm),
                            Text('${user.designation} (${user.role.name})', style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      if (user.role == UserRole.employee)
                        DropdownButton<String?>(
                          value: user.managerId,
                          hint: const Text('Assign Manager'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('No Manager')),
                            ..._managers.map((m) {
                              return DropdownMenuItem(
                                value: m.id,
                                child: Text(m.name),
                              );
                            }),
                          ],
                          onChanged: (newManagerId) {
                            if (newManagerId != user.managerId) {
                              _updateManager(user.id, newManagerId);
                            }
                          },
                        )
                      else
                        Chip(
                          label: Text(user.role.name.toUpperCase()),
                          backgroundColor: AppColors.primaryContainer,
                          labelStyle: const TextStyle(color: AppColors.onPrimaryContainer, fontSize: 10),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
