// Copyright (c) 2026 Tencent. All rights reserved.
// ignore_for_file: prefer_const_declarations
// ignore_for_file: unintended_html_in_doc_comment
part of '../../impl/super_player/super_player.dart';

/// ===== Unified Vod MethodChannel wrappers =====
///
/// Added during the VodPlayer migration from SuperPlayer to the TRTC v3 plugin,
/// replacing the original Pigeon-generated API layer.
///
/// Design:
/// 1. Per-player channel: routes by `playerId`, auto-injected via [VodMethodChannel].
///    Controller signatures stay identical to the original SuperPlayer API.
/// 2. Global channel: download / pre-download / global plugin methods do not need a
///    `playerId` and use [VodGlobalChannel] directly.
/// 3. Event dispatch: the native side invokes unified callbacks such as
///    `onPlayerEvent` / `onDownloadEvent`, and [VodEventDispatcher] routes them
///    to the matching controller by `playerId` / event type.
///
/// Channel names (must match the native side):
/// - `TencentVodPlayer`   -- player instance methods + events
/// - `TencentVodDownload` -- download / pre-download
/// - `TencentVodPlugin`   -- global plugin methods (License / cache dir / log)
class VodChannelNames {
  VodChannelNames._();
  static const String player = 'TencentVodPlayer';
  static const String download = 'TencentVodDownload';
  static const String plugin = 'TencentVodPlugin';
}

/// Native -> Dart callback method names (kept in sync with native `FTXEvent`).
class VodChannelMethods {
  VodChannelMethods._();
  // Player events
  static const String onPlayerEvent = 'onPlayerEvent';
  static const String onPlayerNetEvent = 'onPlayerNetEvent';
  // Download events
  static const String onDownloadEvent = 'onDownloadEvent';
  static const String onPreDownloadEvent = 'onPreDownloadEvent';
  // Picture-in-picture events
  static const String onPipEvent = 'onPipEvent';
  // Global SDK events
  static const String onSDKListener = 'onSDKListener';
  static const String onNativeEvent = 'onNativeEvent';
}

/// Per-player MethodChannel wrapper.
///
/// Each `TXVodPlayerController` holds one and `playerId` is injected automatically.
///
/// Usage:
/// ```dart
/// final mc = VodMethodChannel(_playerId);
/// await mc.invoke<bool>('startVodPlay', {'value': url});
/// ```
class VodMethodChannel {
  VodMethodChannel(this.playerId);

  /// Player instance id, assigned by native in `createPlayer`.
  final int playerId;

  /// Shared MethodChannel singleton (its handler is managed by [VodEventDispatcher]).
  static final MethodChannel _channel =
      const MethodChannel(VodChannelNames.player);

  /// Invoke a native method with `playerId` auto-injected.
  ///
  /// - [method] native method name, same as the original Pigeon API
  ///   (e.g. `startVodPlay` / `pause`).
  /// - [args] business parameters. Omit when none.
  ///
  /// The native side returns primitive types directly (`bool` / `int` / `String` /
  /// `Map` / `List`) instead of wrapped `XxxMsg`.
  Future<T?> invoke<T>(String method, [Map<String, dynamic>? args]) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'playerId': playerId,
      if (args != null) ...args,
    };
    return _channel.invokeMethod<T>(method, payload);
  }

  /// Convenience helper when the return type is `List`.
  Future<List<dynamic>?> invokeList(String method,
      [Map<String, dynamic>? args]) async {
    final result = await invoke<List<dynamic>>(method, args);
    return result;
  }

  /// Convenience helper when the return type is `Map`.
  Future<Map<dynamic, dynamic>?> invokeMap(String method,
      [Map<String, dynamic>? args]) async {
    final result = await invoke<Map<dynamic, dynamic>>(method, args);
    return result;
  }
}

/// Global MethodChannel wrapper (download / pre-download / plugin methods).
///
/// Not bound to a `playerId`; invoked directly.
class VodGlobalChannel {
  VodGlobalChannel._(this._channel);

  final MethodChannel _channel;

  /// Download / pre-download channel (used by `TXVodDownloadController`).
  static final VodGlobalChannel download =
      VodGlobalChannel._(const MethodChannel(VodChannelNames.download));

  /// Global plugin channel (used by `SuperPlayerPlugin`: License / cache dir / log).
  static final VodGlobalChannel plugin =
      VodGlobalChannel._(const MethodChannel(VodChannelNames.plugin));

  Future<T?> invoke<T>(String method, [Map<String, dynamic>? args]) {
    return _channel.invokeMethod<T>(method, args ?? const {});
  }

  Future<List<dynamic>?> invokeList(String method,
      [Map<String, dynamic>? args]) async {
    return await invoke<List<dynamic>>(method, args);
  }

  Future<Map<dynamic, dynamic>?> invokeMap(String method,
      [Map<String, dynamic>? args]) async {
    return await invoke<Map<dynamic, dynamic>>(method, args);
  }

  /// Register a handler on this channel. Used by [VodEventDispatcher] during init.
  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    _channel.setMethodCallHandler(handler);
  }
}

/// Event dispatcher.
///
/// The native side emits unified events such as `onPlayerEvent` / `onPlayerNetEvent`
/// on a single channel. This dispatcher routes them by `playerId` to the right
/// `TXVodPlayerController`, download events to `TXVodDownloadController`, and
/// global events to `SuperPlayerPlugin`.
///
/// Usage:
/// - Controllers call [registerPlayer] on construction and [unregisterPlayer]
///   on `dispose`.
/// - Download / global listeners register via [registerDownloadListener] /
///   [registerPluginListener].
///
/// Note:
/// Dart's `MethodChannel.setMethodCallHandler` is a single-slot setter, so all
/// handlers must be centralised here to avoid multiple controllers overwriting
/// each other.
class VodEventDispatcher {
  VodEventDispatcher._();

  static final VodEventDispatcher instance = VodEventDispatcher._();

  bool _installed = false;

  /// playerId -> handler(event, isNetEvent)
  final Map<int, void Function(Map event, bool isNetEvent)> _playerHandlers =
      {};

  /// Download event handler(event, isPreDownload).
  void Function(Map<String, Object> event, bool isPreDownload)?
      _downloadHandler;

  /// Picture-in-picture event handler.
  void Function(Map event)? _pipHandler;

  /// Plugin-level event handler (SDK / native events).
  void Function(String method, Map event)? _pluginHandler;

  /// Install MethodCallHandlers on every channel. Runs once.
  void _ensureInstalled() {
    if (_installed) return;
    _installed = true;

    VodMethodChannel._channel.setMethodCallHandler(_onPlayerChannelCall);
    VodGlobalChannel.download.setMethodCallHandler(_onDownloadChannelCall);
    VodGlobalChannel.plugin.setMethodCallHandler(_onPluginChannelCall);
  }

  /// Register event callback for a player instance.
  void registerPlayer(
      int playerId, void Function(Map event, bool isNetEvent) handler) {
    _ensureInstalled();
    _playerHandlers[playerId] = handler;
  }

  void unregisterPlayer(int playerId) {
    _playerHandlers.remove(playerId);
  }

  /// Register the process-wide download event listener.
  void registerDownloadListener(
      void Function(Map<String, Object> event, bool isPreDownload) handler) {
    _ensureInstalled();
    _downloadHandler = handler;
  }

  /// Register the process-wide picture-in-picture event listener.
  void registerPipListener(void Function(Map event) handler) {
    _ensureInstalled();
    _pipHandler = handler;
  }

  /// Register the process-wide plugin-level event listener.
  void registerPluginListener(void Function(String method, Map event) handler) {
    _ensureInstalled();
    _pluginHandler = handler;
  }

  // -------- Per-channel handlers --------

  Future<dynamic> _onPlayerChannelCall(MethodCall call) async {
    final String method = call.method;
    final dynamic args = call.arguments;
    if (args is! Map) return;

    // Player instance events: route by playerId.
    if (method == VodChannelMethods.onPlayerEvent ||
        method == VodChannelMethods.onPlayerNetEvent) {
      final int? playerId = args['playerId'] as int?;
      final Map event = (args['event'] is Map ? args['event'] as Map : args);
      if (playerId != null) {
        final h = _playerHandlers[playerId];
        if (h != null) {
          h(event, method == VodChannelMethods.onPlayerNetEvent);
        }
      }
      return;
    }

    // Picture-in-picture events (process-wide).
    if (method == VodChannelMethods.onPipEvent) {
      _pipHandler?.call(args);
      return;
    }
  }

  Future<dynamic> _onDownloadChannelCall(MethodCall call) async {
    final String method = call.method;
    final dynamic args = call.arguments;
    if (args is! Map) return;
    if (_downloadHandler == null) return;

    final Map<String, Object> eventMap = <String, Object>{};
    args.forEach((k, v) {
      if (k is String && v != null) {
        eventMap[k] = v as Object;
      }
    });

    if (method == VodChannelMethods.onDownloadEvent) {
      _downloadHandler!(eventMap, false);
    } else if (method == VodChannelMethods.onPreDownloadEvent) {
      _downloadHandler!(eventMap, true);
    }
  }

  Future<dynamic> _onPluginChannelCall(MethodCall call) async {
    final dynamic args = call.arguments;
    if (args is! Map) return;
    _pluginHandler?.call(call.method, args);
  }
}
