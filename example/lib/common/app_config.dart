import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const defaultRoomId = '20260710';

  static late SharedPreferences _prefs;

  static String _roomId = defaultRoomId;
  static String _userId = DateTime.now()
      .millisecondsSinceEpoch.remainder(100000).toString().padLeft(5, '0');

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _roomId = _prefs.getString('room_id') ?? _roomId;
    _userId = _prefs.getString('user_id') ?? _userId;
  }

  static String get roomId => _roomId;
  static set roomId(String v) { _roomId = v; _prefs.setString('room_id', v); }

  static String get userId => _userId;
  static set userId(String v) { _userId = v; _prefs.setString('user_id', v); }
}
