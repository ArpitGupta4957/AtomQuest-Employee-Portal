import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Core service for Supabase initialization and global client access.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  /// Retrieve the initialized Supabase client
  SupabaseClient get client => Supabase.instance.client;

  /// Setup the backend connection using environment variables
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Supabase: $e');
    }
  }

  /// Helper to listen to table changes (Realtime)
  Stream<List<Map<String, dynamic>>> streamTable(String tableName) {
    return client.from(tableName).stream(primaryKey: ['id']);
  }

  /// Helper for custom realtime channel subscriptions (e.g., specific user notifications)
  RealtimeChannel subscribeToUserNotifications(String userId, void Function(dynamic payload) callback) {
    return client.channel('public:notifications')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: callback,
      )
      .subscribe();
  }
}
