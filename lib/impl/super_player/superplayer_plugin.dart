// Copyright (c) 2022 Tencent. All rights reserved.
// ignore_for_file: constant_identifier_names
// ignore_for_file: unintended_html_in_doc_comment
part of 'super_player.dart';

/// SuperPlayer global capability wrapper (corresponds to the native `TencentVodPlugin` MethodChannel).
///
/// Migration notes:
/// - Previously implemented via Pigeon-generated bindings. Now unified to
///   [VodGlobalChannel.plugin] using MethodChannel, aligned with the v3 plugin.
/// - Event callbacks (SDK Listener / native events / PiP events) are routed
///   through [VodEventDispatcher], dispatched by the native side via
///   `onSDKListener` / `onNativeEvent` / `onPipEvent` MethodCalls.
/// - Public API signatures and semantics remain 100% compatible with the
///   original SuperPlayer version; business callers require no changes.
class SuperPlayerPlugin {
  static const TAG = "SuperPlayerPlugin";

  static SuperPlayerPlugin? _instance;

  static SuperPlayerPlugin get instance => _sharedInstance();

  /// SuperPlayerPlugin instance
  static SuperPlayerPlugin _sharedInstance() {
    _instance ??= SuperPlayerPlugin._internal();
    return _instance!;
  }

  /// Global plugin channel, handles license / cache / log related method calls.
  static final VodGlobalChannel _pluginChannel = VodGlobalChannel.plugin;

  final StreamController<Map<dynamic, dynamic>> _eventStreamController =
      StreamController.broadcast();
  final StreamController<Map<dynamic, dynamic>> _eventPipStreamController =
      StreamController.broadcast();

  /// Native interaction, common event listener, events from the plugin, such as sound change events.
  Stream<Map<dynamic, dynamic>> get onEventBroadcast =>
      _eventStreamController.stream;

  /// Native interaction, common event listener, events from the native container,
  /// such as PIP events, activity/controller lifecycle changes.
  Stream<Map<dynamic, dynamic>> get onExtraEventBroadcast =>
      _eventPipStreamController.stream;

  FTXLicenceLoadedListener? _licenseLoadedListener;

  SuperPlayerPlugin._internal() {
    // Mount event callbacks: SDK / native events go through the plugin channel, PiP events go through the player channel.
    VodEventDispatcher.instance.registerPluginListener(_handlePluginCall);
    VodEventDispatcher.instance.registerPipListener(_handlePipEvent);
  }

  /// Handles events coming from the plugin channel.
  /// - `onSDKListener`: SDK events such as license loading.
  /// - `onNativeEvent`: native broadcast events such as volume change / SDK auth.
  void _handlePluginCall(String method, Map event) {
    switch (method) {
      case VodChannelMethods.onSDKListener:
        _onSDKListener(event);
        break;
      case VodChannelMethods.onNativeEvent:
        _eventStreamController.add(event);
        break;
      default:
        break;
    }
  }

  void _handlePipEvent(Map event) {
    LogUtils.d(TAG, "[pipEventHandler], receive event = $event");
    _eventPipStreamController.add(event);
  }

  void _onSDKListener(Map event) {
    final int? evtCode = event["event"] as int?;
    if (evtCode == TXVodPlayEvent.EVENT_ON_LICENCE_LOADED) {
      _licenseLoadedListener?.call(
        event[TXVodPlayEvent.EVENT_RESULT],
        event[TXVodPlayEvent.EVENT_REASON],
      );
    }
  }

  static Future<String?> get platformVersion async {
    return await _pluginChannel.invoke<String>('getLiteAVSDKVersion');
  }

  /// Creating a VOD player
  static Future<int?> createVodPlayer({bool? onlyAudio}) async {
    return await _pluginChannel.invoke<int>('createVodPlayer', {
      'onlyAudio': onlyAudio ?? false,
    });
  }

  /// Turning on/off log output
  static Future<void> setConsoleEnabled(bool enabled) async {
    await _pluginChannel.invoke<void>('setConsoleEnabled', {'value': enabled});
  }

  /// Releasing player resources
  static Future<void> releasePlayer(int? playerId) async {
    await _pluginChannel.invoke<void>('releasePlayer', {'playerId': playerId});
  }

  /// Setting the maximum cache size for the playback engine. After setting,
  /// files in the Cache directory will be automatically cleaned up based on the set value.
  /// @param size Maximum cache size (unit: MB).
  static Future<void> setGlobalMaxCacheSize(int size) async {
    await _pluginChannel.invoke<void>('setGlobalMaxCacheSize', {'value': size});
  }

  /// Local caching of video files is a highly demanded feature in short video playback scenarios. For ordinary users,
  /// when watching a video that has already been viewed, it should not consume data traffic again.
  ///  @Format support: The SDK supports caching for two common VOD formats: HLS(m3u8) and MP4.
  ///  @Timing of enabling: The SDK does not enable caching by default, and it is not recommended to
  ///   enable this feature for scenarios with low user review rates.
  ///  @Method of enabling: Global effect, enabled with the player. To enable this feature, two parameters need to be configured:
  ///   the local cache directory and the cache size.
  ///
  /// The cache path is set by default to the app sandbox directory, and postfixPath only needs to pass the relative cache directory,
  /// without passing the entire absolute path.
  /// e.g. postfixPath = 'testCache'
  /// On Android platform: the video will be cached to the sdcard/Android/data/your-pkg-name/files/testCache directory.
  /// On iOS platform: the video will be cached to the Documents/testCache directory in the sandbox.
  /// @param postfixPath Cache directory
  /// @return true if the setting is successful, false if the setting fails.
  static Future<bool?> setGlobalCacheFolderPath(String postfixPath) async {
    return await _pluginChannel.invoke<bool>('setGlobalCacheFolderPath', {
      'value': postfixPath,
    });
  }

  ///
  /// Set the absolute path of the player resource cache directory. This method will override each other with
  /// setGlobalCacheFolderPath(String postfixPath), and you only need to call one of them.
  ///
  /// @param androidAbsolutePath Android side absolute path
  ///        iOSAbsolutePath iOS side absolute path
  /// @return true if the setting is successful, false otherwise
  static Future<bool?> setGlobalCacheFolderCustomPath(
      {String? androidAbsolutePath, String? iOSAbsolutePath}) async {
    return await _pluginChannel.invoke<bool>('setGlobalCacheFolderCustomPath', {
      'androidAbsolutePath': androidAbsolutePath,
      'iOSAbsolutePath': iOSAbsolutePath,
    });
  }

  /// Setting the global license
  static Future<void> setGlobalLicense(
      String licenceUrl, String licenceKey) async {
    await _pluginChannel.invoke<void>('setGlobalLicense', {
      'licenseUrl': licenceUrl,
      'licenseKey': licenceKey,
    });
  }

  /// Setting the log output level [TXLogLevel]
  static Future<void> setLogLevel(int logLevel) async {
    await _pluginChannel.invoke<void>('setLogLevel', {'value': logLevel});
  }

  /// Whether the current device supports picture-in-picture mode.
  /// @return [TXVodPlayEvent]
  /// 0 Picture-in-picture mode can be enabled.
  /// -101 The Android version is too low.
  /// -102 Picture-in-picture permission is disabled or the device does not support picture-in-picture mode.
  /// -103 The current interface has been destroyed.
  static Future<int?> isDeviceSupportPip() async {
    return await _pluginChannel.invoke<int>('isDeviceSupportPip');
  }

  /// Getting the version of LiteAVSDK that depends on the native side
  static Future<String?> getLiteAVSDKVersion() async {
    return await _pluginChannel.invoke<String>('getLiteAVSDKVersion');
  }

  /// Setting the environment for accessing the LiteAV SDK.
  /// Tencent Cloud has deployed environments in various regions around the world, and different access points need to be accessed
  /// according to local policies and regulations.
  ///
  /// @param envConfig The environment to be accessed. The SDK defaults to the official environment.
  ///  @return 0: success; others: error
  ///  @note Customers targeting the Chinese mainland market should not call this interface.
  ///   If the target market is overseas users, please contact us through technical support to learn about the configuration
  ///   method of `env_config` to ensure that the App complies with GDPR standards.
  static Future<int?> setGlobalEnv(String envConfig) async {
    return await _pluginChannel
        .invoke<int>('setGlobalEnv', {'value': envConfig});
  }

  /// Starts listening for device rotation direction. After it is turned on, if the device's auto-rotation is turned on,
  /// the player will automatically rotate the video direction based on the current device orientation.
  /// <h1>This interface is currently only applicable to the Android side, and the iOS side will automatically enable this feature</h1>
  /// Before calling this interface, please be sure to inform the user of the privacy risks.
  /// If necessary, confirm whether you have permission to access the rotation sensor.
  /// @return true: success
  /// false: failure, due to premature enabling, waiting for context initialization, failure to obtain sensor, etc.
  static Future<bool?> startVideoOrientationService() async {
    return await _pluginChannel.invoke<bool>('startVideoOrientationService');
  }

  /// Set up SDK listeners, currently there is a license loading listener, and other types of listeners
  /// will be gradually opened in the future.
  void setSDKListener({FTXLicenceLoadedListener? licenceLoadedListener}) {
    _licenseLoadedListener = licenceLoadedListener;
  }

  /// Set the userId to facilitate problem localization.
  static Future<void> setUserId(String userId) async {
    await _pluginChannel.invoke<void>('setUserId', {'value': userId});
  }

  /// Enable flexible verification of player License; once enabled, the verification will pass by default for the
  /// first two times after the player is launched for the first time.
  static Future<void> setLicenseFlexibleValid(bool enabled) async {
    await _pluginChannel
        .invoke<void>('setLicenseFlexibleValid', {'value': enabled});
  }

  /// Set the DRM certificate provider environment. See [TXDrmProvisionEnv].
  static Future<void> setDrmProvisionEnv(TXDrmProvisionEnv env) async {
    await _pluginChannel
        .invoke<void>('setDrmProvisionEnv', {'value': env.index});
  }
}
