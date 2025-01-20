import 'dart:async';
import 'package:flutter/services.dart';

/// Beauty filter and animation parameter management
class TXBeautyManager {
  static late MethodChannel _channel;
  TXBeautyManager(channel) {
    _channel = channel;
  }

  /// Set beauty filter type
  ///
  /// **Parameters:**
  ///
  /// `beautyStyle` Beauty filter style. `0`: smooth, `1`: natural, `2`: misty
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setBeautyStyle(int beautyStyle) {
    return _channel
        .invokeMethod('setBeautyStyle', {"beautyStyle": beautyStyle});
  }

  /// Specify material filter effect
  ///
  /// **Parameters:**
  ///
  /// `assetUrl` can be an asset resource address defined in Flutter such as 'images/watermark_img.png' or an online image address
  ///
  /// **Note:** PNG format must be used
  ///
  /// **Platform not supported:**
  /// - web
  /// - Windows
  Future<int?> setFilter(String assetUrl // Resource address in `assets`
      ) async {
    String imageUrl = assetUrl;
    String type = 'network'; // Online image by default
    if (assetUrl.indexOf('http') != 0) {
      type = 'local';
    }
    return _channel
        .invokeMethod('setFilter', {"imageUrl": imageUrl, "type": type});
  }

  /// Set the strength of filter
  ///
  /// In application scenarios such as shows, a high strength is required to highlight the characteristics of anchors. The default strength is `0.5`, and if it is not sufficient, it can be adjusted with the following APIs.
  ///
  /// **Parameters:**
  ///
  /// `strength` Value range: `0`–`1`. The greater the value, the more obvious the effect. Default value: `0.5`.
  ///
  /// **Platform not supported:**
  /// - web
  /// - Windows
  Future<void> setFilterStrength(double strength) {
    return _channel
        .invokeMethod('setFilterStrength', {"strength": strength.toString()});
  }

  /// Set the strength of the beauty filter
  ///
  /// **Parameters:**
  ///
  /// `beautyLevel` Strength of the beauty filter. Value range: `0`–`9`; `0` indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setBeautyLevel(int beautyLevel) {
    return _channel
        .invokeMethod('setBeautyLevel', {"beautyLevel": beautyLevel});
  }

  /// Set the strength of the brightening filter
  ///
  /// **Parameters:**
  ///
  /// whitenessLevel Strength of the brightening filter. Value range: `0`–`9`; `0` indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setWhitenessLevel(int whitenessLevel) {
    return _channel
        .invokeMethod('setWhitenessLevel', {"whitenessLevel": whitenessLevel});
  }

  /// Enable definition enhancement
  ///
  /// **Parameters:**
  ///
  /// `enable` `true`: enables definition enhancement; `false`: disables definition enhancement. Default value: `true`
  ///
  /// **Platform not supported:**
  /// - web
  /// - Windows
  Future<void> enableSharpnessEnhancement(bool enable) {
    return _channel
        .invokeMethod('enableSharpnessEnhancement', {"enable": enable});
  }

  /// Set the strength of the rosy skin filter
  ///
  /// **Parameters:**
  ///
  /// `ruddyLevel` Strength of the rosy skin filter. Value range: `0`–`9`; `0` indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setRuddyLevel(int ruddyLevel) {
    return _channel.invokeMethod('setRuddyLevel', {"ruddyLevel": ruddyLevel});
  }
}
