import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../models/enums.dart';
import '../repositories/notification_repository.dart';
import '../services/supabase_service.dart';

/// NotificationProvider — manages in-app notifications and realtime WebSocket connections.
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  RealtimeChannel? _subscription;
  
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unread => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unread.length;
  bool get hasUnread => unreadCount > 0;

  Future<void> initialize(String userId) async {
    // 1. Fetch initial state from DB
    _notifications = await _repository.getNotificationsForUser(userId);
    notifyListeners();

    // 2. Setup Realtime WebSocket Listener
    _subscription?.unsubscribe();
    _subscription = SupabaseService.instance.subscribeToUserNotifications(
      userId,
      (payload) {
        // Payload handling from Postgres change
        if (payload['eventType'] == 'INSERT') {
          final newRecord = payload['new'];
          final notif = AppNotification(
            id: newRecord['id'],
            type: NotificationType.values.byName(newRecord['type']),
            title: newRecord['title'],
            body: newRecord['body'],
            relatedGoalId: newRecord['related_goal_id'],
            isRead: newRecord['is_read'] ?? false,
            createdAt: DateTime.parse(newRecord['created_at']),
          );
          _notifications.insert(0, notif);
          notifyListeners();
        } else if (payload['eventType'] == 'UPDATE') {
          final updatedRecord = payload['new'];
          final index = _notifications.indexWhere((n) => n.id == updatedRecord['id']);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(
              isRead: updatedRecord['is_read'],
            );
            notifyListeners();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      // Optimistic UI update
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      
      // DB update
      await _repository.markAsRead(id);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    // Optimistic UI update
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    
    // DB update
    await _repository.markAllAsRead(userId);
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
