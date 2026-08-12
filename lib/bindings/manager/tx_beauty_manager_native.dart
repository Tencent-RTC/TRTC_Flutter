import 'package:tencent_rtc_sdk/bindings/trtc/ffi_bindings.dart' as native;
import 'package:tencent_rtc_sdk/bindings/trtc/load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/manager/manager_struct.dart';

class TXBeautyManagerNative {
  late final native.FFIBindings _beautyManagerFFIBindings;
  late final tx_beauty_manager _beautyManagerNativePointer;

  TXBeautyManagerNative(tx_beauty_manager beautyManagerNativePointer) {
    _beautyManagerNativePointer = beautyManagerNativePointer;
    _beautyManagerFFIBindings =
        native.FFIBindings(LoadDynamicLib().loadTRTCSDK());
  }

  tx_beauty_manager getNativePointer() {
    return _beautyManagerNativePointer;
  }

  void enableSharpnessEnhancement(bool enable) {
    _beautyManagerFFIBindings.tx_beauty_manager_enable_sharpness_enhancement(
        _beautyManagerNativePointer, enable);
  }

  void setBeautyLevel(int beautyLevel) {
    _beautyManagerFFIBindings.tx_beauty_manager_set_beauty_level(
        _beautyManagerNativePointer, beautyLevel);
  }

  void setBeautyStyle(int beautyStyle) {
    _beautyManagerFFIBindings.tx_beauty_manager_set_beauty_style(
        _beautyManagerNativePointer, beautyStyle);
  }

  int setFilter(String assetUrl) {
    /// TODO: vincepzhang 需要增加新c/C++接口
    return -1;
  }

  void setFilterStrength(double strength) {
    /// TODO: vincepzhang 需要增加新c/C++接口
  }

  void setRuddyLevel(int ruddyLevel) {
    _beautyManagerFFIBindings.tx_beauty_manager_set_ruddy_level(
        _beautyManagerNativePointer, ruddyLevel);
  }

  void setWhitenessLevel(int whitenessLevel) {
    _beautyManagerFFIBindings.tx_beauty_manager_set_whiteness_level(
        _beautyManagerNativePointer, whitenessLevel);
  }
}
