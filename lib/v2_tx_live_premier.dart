import 'package:tencent_rtc_sdk/v2_tx_live_code.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_def.dart';
import 'package:tencent_rtc_sdk/impl/live/v2_tx_live_premier_impl.dart';

enum V2TXLivePremierObserverType {
  /// Customize the log output callback interface
  ///
  /// **Parameter:**
  ///
  /// `level` Log level
  ///
  /// `log` Log content
  onLog,

  /// setLicence interface callback
  ///
  /// **Parameter:**
  ///
  /// `reason` Set the licence failure reason
  ///
  /// `result` Set licence result 0 succeeds and negative fails
  onLicenceLoaded,
}

typedef V2TXLivePremierObserver<P> = void Function(
    V2TXLivePremierObserverType type, P? params);

class V2TXLivePremier {
  /// Set the authorization license for the SDK
  /// Document address: https://cloud.tencent.com/document/product/454/34750
  ///
  /// **Parameter:**
  ///
  /// `url` licence url
  ///
  /// `key` licence key
  static Future<void> setLicence(String url, String key) async {
    return V2TXLivePremierImpl.setLicence(url, key);
  }

  /// Obtain the SDK version
  static Future<String> getSDKVersionStr() async {
    return V2TXLivePremierImpl.getSDKVersionStr();
  }

  /// Set the V2TXLivePremier callback API
  static Future<void> setObserver(V2TXLivePremierObserver? observer) async {
    return V2TXLivePremierImpl.setObserver(observer);
  }

  /// Set the configuration information for the log
  static Future<V2TXLiveCode> setLogConfig(V2TXLiveLogConfig config) async {
    return V2TXLivePremierImpl.setLogConfig(config);
  }

  /// Set up the SDK access environment
  ///
  /// Note: If your application does not have special requirements, please do not call this API to set up.
  ///
  /// **Parameter:**
  ///
  /// `env` Currently, two parameters are supported: "default" and "GDPR".
  /// - default: The default environment, the SDK will find the best access point around the world for access.
  /// - GDPR: All audio and video data and quality statistics will not pass through servers in Chinese mainland.
  static Future<V2TXLiveCode> setEnvironment(String env) async {
    return V2TXLivePremierImpl.setEnvironment(env);
  }

  /// Set up the SDK socks5 proxy configuration
  ///
  /// **Parameter:**
  ///
  /// `host` The address of the SOCKS5 proxy server
  ///
  /// `port` The port of the SOCKS5 proxy server
  ///
  /// `username` The username of the SOCKS5 proxy server
  ///
  /// `password` The password of the SOCKS5 proxy server
  ///
  /// `config` For details, please refer to  [V2TXLiveSocks5ProxyConfig]
  static Future<V2TXLiveCode> setSocks5Proxy(
      String host,
      int port,
      String username,
      String password,
      V2TXLiveSocks5ProxyConfig config) async {
    return V2TXLivePremierImpl.setSocks5Proxy(
        host, port, username, password, config);
  }

  /// Set the user ID
  ///
  /// **Parameter:**
  ///
  /// `userId` The ID of the user/device maintained by the service side.
  static Future<V2TXLiveCode> setUserId(String userId) async {
    return V2TXLivePremierImpl.setUserId(userId);
  }

  static Future<V2TXLiveCode> callExperimentalAPI(String jsonStr) async {
    return V2TXLivePremierImpl.callExperimentalAPI(jsonStr);
  }
}
