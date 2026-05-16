import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';

/// AuthProvider — Manages user authentication.
/// Connected to Supabase Auth and User Profiles table.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentRole => _currentUser?.role;

  /// Check current session on startup
  Future<void> checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await _fetchUserProfile(session.user.id);
    }
  }

  /// Login with email/password against Supabase
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _fetchUserProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Internal method to fetch profile from public.users table
  Future<void> _fetchUserProfile(String userId) async {
    _currentUser = await _repository.getUserProfile(userId);
    notifyListeners();
  }

  /// Logout from Supabase
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Hackathon Feature: Instant Role Switching 
  /// (This simulates logging in without passwords by directly fetching a profile)
  /// Note: RLS policies might block this if not authenticated, so for a true hackathon 
  /// demo, you might need to bypass RLS or use a dummy auth token.
  Future<void> switchRole(UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch any user with the requested role
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('role', role.name)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _currentUser = AppUser(
          id: response['id'],
          name: response['name'],
          email: response['email'],
          role: role,
          department: response['department_id'] ?? 'Demo Dept',
          designation: response['designation'],
          joinedDate: DateTime.parse(response['joined_date']),
        );
      } else {
        // Fallback for Hackathon: Use purely mock data if DB is empty
        _currentUser = AppUser(
          id: 'demo-${role.name}',
          name: 'Demo ${role.name.capitalize()}',
          email: 'demo@atomberg.com',
          role: role,
          department: 'Productivity',
          designation: 'Staff',
          joinedDate: DateTime.now().subtract(const Duration(days: 365)),
        );
      }
    } catch (e) {
      print('Role switch error, falling back to mock user: $e');
      _currentUser = AppUser(
        id: 'demo-${role.name}',
        name: 'Demo ${role.name.capitalize()}',
        email: 'demo@atomberg.com',
        role: role,
        department: 'Productivity',
        designation: 'Staff',
        joinedDate: DateTime.now().subtract(const Duration(days: 365)),
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
