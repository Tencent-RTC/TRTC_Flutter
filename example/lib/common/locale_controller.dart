import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app locale state.
///
/// - [locale] is `null` when "Follow System" is selected.
/// - The user's manual selection is persisted in [SharedPreferences].
class LocaleController extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  Locale? _locale;
  bool _initialized = false;

  Locale? get locale => _locale;
  bool get isFollowSystem => _locale == null;

  /// Initialize from persisted preference. Must be called before first build.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && code.isNotEmpty) {
        _locale = Locale(code);
      }
    } catch (_) {
      // Silently fall back to system locale
    }
    notifyListeners();
  }

  /// Set locale. Pass `null` to follow system.
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_prefKey);
      } else {
        await prefs.setString(_prefKey, locale.languageCode);
      }
    } catch (_) {
      // Ignore persistence errors
    }
  }
}
