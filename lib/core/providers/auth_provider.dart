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

}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
