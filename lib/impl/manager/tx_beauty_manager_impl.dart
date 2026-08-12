import 'package:tencent_rtc_sdk/bindings/manager/tx_beauty_manager_native.dart';

class TXBeautyManagerImpl {
  late final TXBeautyManagerNative _beautyManagerNative;
  static TXBeautyManagerImpl? _instance;

  TXBeautyManagerImpl._internal(dynamic beautyManagerPointer) {
    _beautyManagerNative = TXBeautyManagerNative(beautyManagerPointer);
  }

  factory TXBeautyManagerImpl(dynamic deviceManagerPointer) {
    return _instance ??= TXBeautyManagerImpl._internal(deviceManagerPointer);
  }

  static destroyBeautyManager() {
    _instance = null;
  }

  void enableSharpnessEnhancement(bool enable) {
    _beautyManagerNative.enableSharpnessEnhancement(enable);
  }

  void setBeautyLevel(int beautyLevel) {
    _beautyManagerNative.setBeautyLevel(beautyLevel);
  }

  void setBeautyStyle(int beautyStyle) {
    _beautyManagerNative.setBeautyStyle(beautyStyle);
  }

  int setFilter(String assetUrl) {
    return _beautyManagerNative.setFilter(assetUrl);
  }

  void setFilterStrength(double strength) {
    _beautyManagerNative.setFilterStrength(strength);
  }

  void setRuddyLevel(int ruddyLevel) {
    _beautyManagerNative.setRuddyLevel(ruddyLevel);
  }

  void setWhitenessLevel(int whitenessLevel) {
    _beautyManagerNative.setWhitenessLevel(whitenessLevel);
  }
}
