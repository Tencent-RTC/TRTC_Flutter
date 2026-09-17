import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and retrieves the last-entered User ID, numeric Room ID and
/// string Room ID.
///
/// Provides sensible default values when no history exists:
/// - User ID: a random `user_xxxx` string.
/// - Numeric Room ID: empty (users are nudged towards the string room id by default).
/// - String Room ID: a fixed example `room_test` to showcase alphanumeric support.
class RoomInputPrefs {
  static const _userIdKey = 'last_user_id';
  static const _roomIdKey = 'last_room_id';
  static const _strRoomIdKey = 'last_str_room_id';

  static SharedPreferences? _prefs;
  static String? _generatedUserId;

  static Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (_) {}
  }

  static String _generateDefaultUserId() {
    final rand = Random();
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final suffix = List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'user_$suffix';
  }

  static const String defaultRoomId = 'room_test';

  /// Returns the last saved User ID, or a generated default if none exists.
  static String get lastUserId {
    final saved = _prefs?.getString(_userIdKey);
    if (saved != null && saved.isNotEmpty) return saved;
    return _generatedUserId ??= _generateDefaultUserId();
  }

  /// Returns the last saved numeric Room ID (digits only), or empty string if none exists.
  static String get lastRoomId {
    final saved = _prefs?.getString(_roomIdKey);
    // Distinguish "never saved" (null → default) from "saved as empty" (→ empty).
    if (saved != null) return saved;
    return '';
  }

  /// Returns the last saved string Room ID, or the default example if none exists.
  static String get lastStrRoomId {
    final saved = _prefs?.getString(_strRoomIdKey);
    // Distinguish "never saved" (null → default) from "saved as empty" (→ empty).
    if (saved != null) return saved;
    return defaultRoomId;
  }

  /// Persists the given User ID for next launch.
  static Future<void> saveUserId(String userId) => _save((p) => p.setString(_userIdKey, userId));

  /// Persists the given numeric Room ID for next launch.
  static Future<void> saveRoomId(String roomId) => _save((p) => p.setString(_roomIdKey, roomId));

  /// Persists the given string Room ID for next launch.
  static Future<void> saveStrRoomId(String strRoomId) => _save((p) => p.setString(_strRoomIdKey, strRoomId));

  static Future<void> _save(Future<bool> Function(SharedPreferences prefs) action) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs ??= prefs;
      await action(prefs);
    } catch (_) {}
  }
}
