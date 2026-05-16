import '../models/models.dart';
import '../models/enums.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final response = await _supabase.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return AppUser(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        role: UserRole.values.byName(response['role']),
        department: response['department_id'] ?? 'Unknown Department', // Need join to get name ideally
        designation: response['designation'],
        avatarUrl: response['avatar_url'],
        managerId: response['manager_id'],
        joinedDate: DateTime.parse(response['joined_date']),
      );
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Note: For hackathon demo mode, we might bypass actual auth 
  // and just fetch a specific demo user directly.
}
