import '../models/models.dart';
import '../models/enums.dart';
import '../services/supabase_service.dart';

class NotificationRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  /// Fetch initial notifications for a user
  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    try {
      final response = await _supabase.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => _parseNotification(json)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking all notifications read: $e');
    }
  }

  /// Helper to parse Supabase JSON
  AppNotification _parseNotification(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: NotificationType.values.byName(json['type']),
      title: json['title'],
      body: json['body'],
      relatedGoalId: json['related_goal_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
