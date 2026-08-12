// ignore_for_file: avoid_print
// ignore_for_file: empty_statements
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/manager/manager_struct.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'ffi_bindings.dart' as native;
import 'trtc_cloud_struct.dart';

class TRTCCloudNative {
  static TRTCCloudNative instance = TRTCCloudNative._();
  TRTCCloudNative._();
  static final _trtcFFIBindings =
      native.FFIBindings(LoadDynamicLib().loadTRTCSDK());
  static final _trtcFFIBindingsBackup =
      native.FFIBindings(LoadDynamicLib().loadTRTCSDK());
  static late trtc_cloud _trtcsharedInstanceNativePointer;
  static late trtc_cloud_callback _trtcCloudCallback;

  static void sharedInstance() {
    try {
      _trtcsharedInstanceNativePointer =
          _trtcFFIBindings.get_instance(ffi.nullptr);
      _trtcCloudCallback = _trtcFFIBindings
          .create_cloud_callback(_trtcsharedInstanceNativePointer);
    } catch (e) {
      print(e);
    }
  }

  static void destroySharedInstance() {
    _trtcFFIBindings.destroy_cloud_callback(_trtcCloudCallback);
    _trtcFFIBindings.destroy_instance(_trtcsharedInstanceNativePointer);
  }

  static get sharedInstanceNativePointer => _trtcsharedInstanceNativePointer;

  tx_device_manager getDeviceManager() {
    return _trtcFFIBindings
        .get_device_manager(_trtcsharedInstanceNativePointer);
  }

  ffi.Pointer<void> getBeautyManager() {
    return _trtcFFIBindings
        .get_beauty_manager(_trtcsharedInstanceNativePointer);
  }

  void enterRoom(TRTCParams param, int scene) {
    ffi.Pointer<trtc_params_t> paramsPoint = trtc_params_t.fromParams(param);

    _trtcFFIBindings.enter_room(
        _trtcsharedInstanceNativePointer, paramsPoint.ref, scene);

    trtc_params_t.freeStruct(paramsPoint);
  }

  void switchRoom(TRTCSwitchRoomConfig config) {
    ffi.Pointer<trtc_switch_room_config_t> configPtr =
        trtc_switch_room_config_t.fromParams(config);

    _trtcFFIBindings.switch_room(
        _trtcsharedInstanceNativePointer, configPtr.ref);

    trtc_switch_room_config_t.freeStruct(configPtr);
  }

  void switchRole(int role) {
    _trtcFFIBindings.switch_role(_trtcsharedInstanceNativePointer, role);
  }

  void enableAudioVolumeEvaluation(
      bool enable, TRTCAudioVolumeEvaluateParams params) {
    ffi.Pointer<trtc_audio_volume_evaluate_params_t> paramsPoint =
        trtc_audio_volume_evaluate_params_t.fromParams(params);

    _trtcFFIBindings.enable_audio_volume_evaluation(
        _trtcsharedInstanceNativePointer, enable, paramsPoint.ref);

    trtc_audio_volume_evaluate_params_t.freeStruct(paramsPoint);
  }

  void exitRoom() {
    _trtcFFIBindings.exit_room(_trtcsharedInstanceNativePointer);
  }

  void muteLocalVideo(int streamType, bool mute) {
    _trtcFFIBindings.mute_local_video(
        _trtcsharedInstanceNativePointer, streamType, mute);
  }

  void muteLocalAudio(bool mute) {
    _trtcFFIBindings.mute_local_audio(_trtcsharedInstanceNativePointer, mute);
  }

  void setLocalRenderParams(int rotation, int fillMode, int mirrorType) {
    _trtcFFIBindings.set_local_render_params(
        _trtcsharedInstanceNativePointer, rotation, fillMode, mirrorType);
  }

  void setNetworkQosParam(TRTCNetworkQosParam params) {
    ffi.Pointer<trtc_network_qos_param_t> paramsPoint =
        trtc_network_qos_param_t.fromParams(params);

    _trtcFFIBindingsBackup.set_network_qos_param(
        _trtcsharedInstanceNativePointer, paramsPoint.ref);

    trtc_network_qos_param_t.freeStruct(paramsPoint);
  }

  void setVideoEncoderParam(TRTCVideoEncParam params) {
    ffi.Pointer<trtc_video_enc_param_t> paramsPoint =
        trtc_video_enc_param_t.fromParams(params);

    _trtcFFIBindings.set_video_encoder_param(
        _trtcsharedInstanceNativePointer, paramsPoint.ref);

    trtc_video_enc_param_t.freeStruct(paramsPoint);
  }

  void setVideoEncoderMirror(bool enable) {
    _trtcFFIBindings.set_video_encoder_mirror(
        _trtcsharedInstanceNativePointer, enable);
  }

  void startLocalAudio(int quality) {
    _trtcFFIBindings.start_local_audio(
        _trtcsharedInstanceNativePointer, quality);
  }

  void startRemoteView(String userId, int streamType, int? viewId) {
    ffi.Pointer<ffi.Char> userIdN = userId.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Void> viewPointer = ViewPointerFactory.create(viewId);

    _trtcFFIBindings.start_remote_view(
        _trtcsharedInstanceNativePointer, userIdN, streamType, viewPointer);

    calloc.free(userIdN);
    ViewPointerFactory.free(viewPointer);
  }

  void startLocalPreview(bool frontCamera, int? viewId) {
    ffi.Pointer<ffi.Void> viewPointer = ViewPointerFactory.create(viewId);

    _trtcFFIBindings.start_local_preview(
        _trtcsharedInstanceNativePointer, frontCamera, viewPointer);

    ViewPointerFactory.free(viewPointer);
  }

  void stopAllRemoteView() {
    _trtcFFIBindings.stop_all_remote_view(_trtcsharedInstanceNativePointer);
  }

  void stopLocalAudio() {
    _trtcFFIBindings.stop_local_audio(_trtcsharedInstanceNativePointer);
  }

  void stopLocalPreview() {
    _trtcFFIBindings.stop_local_preview(_trtcsharedInstanceNativePointer);
  }

  void stopRemoteView(String userId, int streamType) {
    ffi.Pointer<ffi.Char> userIdN = userId.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.stop_remote_view(
        _trtcsharedInstanceNativePointer, userIdN, streamType);

    calloc.free(userIdN);
  }

  void setGravitySensorAdaptiveMode(int mode) {
    _trtcFFIBindings.set_gravity_sensor_adaptive_mode(
        _trtcsharedInstanceNativePointer, mode);
  }

  void muteRemoteVideoStream(String userId, int streamType, bool mute) {
    ffi.Pointer<ffi.Char> userIdN = userId.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.mute_remote_video_stream(
        _trtcsharedInstanceNativePointer, userIdN, streamType, mute);

    calloc.free(userIdN);
  }

  void startLocalPreviewTexture(bool frontCamera, int viewId) {
    _trtcFFIBindingsBackup.startLocalPreviewTexture(
        _trtcsharedInstanceNativePointer, frontCamera ? 1 : 0, viewId);
  }

  void updateLocalViewTexture(int viewId) {
    _trtcFFIBindingsBackup.startLocalPreviewTexture(
        _trtcsharedInstanceNativePointer, 1, viewId);
  }

  void startRemoteViewTexture(String userId, int streamType, int viewId) {
    ffi.Pointer<ffi.Int8> userIdN = userId.toNativeUtf8().cast<ffi.Int8>();

    _trtcFFIBindingsBackup.startRemoteViewTexture(
        _trtcsharedInstanceNativePointer, userIdN, streamType, viewId);

    calloc.free(userIdN);
  }

  void updateRemoteViewTexture(String userId, int streamType, int viewId) {
    ffi.Pointer<ffi.Int8> userIdN = userId.toNativeUtf8().cast<ffi.Int8>();

    _trtcFFIBindingsBackup.startRemoteViewTexture(
        _trtcsharedInstanceNativePointer, userIdN, streamType, viewId);

    calloc.free(userIdN);
  }

  String callExperimentalAPI(String jsonStr) {
    ffi.Pointer<ffi.Char> jsonStrN = jsonStr.toNativeUtf8().cast<ffi.Char>();

    ffi.Pointer<ffi.Char> resultN = _trtcFFIBindings.call_experimental_api(
        _trtcsharedInstanceNativePointer, jsonStrN);

    calloc.free(jsonStrN);
    if (resultN == ffi.nullptr) {
      return '';
    }
    return resultN.cast<Utf8>().toDartString();
  }

  void connectOtherRoom(String param) {
    ffi.Pointer<ffi.Char> paramN = param.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.connect_other_room(
        _trtcsharedInstanceNativePointer, paramN);

    calloc.free(paramN);
  }

  trtc_cloud createSubCloud() {
    return _trtcFFIBindings.create_sub_cloud(_trtcsharedInstanceNativePointer);
  }

  void destroySubCloud(trtc_cloud subCloud) {
    _trtcFFIBindings.destroy_sub_cloud(
        _trtcsharedInstanceNativePointer, subCloud);
  }

  void disconnectOtherRoom() {
    _trtcFFIBindings.disconnect_other_room(_trtcsharedInstanceNativePointer);
  }

  void enableCustomAudioCapture(bool enable) {
    _trtcFFIBindings.enable_custom_audio_capture(
        _trtcsharedInstanceNativePointer, enable);
  }

  void enableLocalVideoCustomProcess(bool enable, int format, int type) {
    _trtcFFIBindings.enable_local_video_custom_process(
        _trtcsharedInstanceNativePointer, enable, format, type);
  }

  void enableMixExternalAudioFrame(bool enablePublish, bool enablePlayout) {
    _trtcFFIBindings.enable_mix_external_audio_frame(
        _trtcsharedInstanceNativePointer, enablePublish, enablePlayout);
  }

  int enableSmallVideoStream(
      bool enable, TRTCVideoEncParam smallVideoEncParam) {
    ffi.Pointer<trtc_video_enc_param_t> paramPointer =
        trtc_video_enc_param_t.fromParams(smallVideoEncParam);

    int result = _trtcFFIBindings.enable_small_video_stream(
        _trtcsharedInstanceNativePointer, enable, paramPointer.ref);

    trtc_video_enc_param_t.freeStruct(paramPointer);
    return result;
  }

  int getAudioCaptureVolume() {
    return _trtcFFIBindings
        .get_audio_capture_volume(_trtcsharedInstanceNativePointer);
  }

  tx_audio_effect_manager getAudioEffectManager() {
    return _trtcFFIBindings
        .get_audio_effect_manager(_trtcsharedInstanceNativePointer);
  }

  int getAudioPlayoutVolume() {
    return _trtcFFIBindings
        .get_audio_playout_volume(_trtcsharedInstanceNativePointer);
  }

  String getSDKVersion() {
    final ffi.Pointer<ffi.Char> s =
        _trtcFFIBindings.get_sdk_version(_trtcsharedInstanceNativePointer);

    return FFIConverter.getStringFromChar(s);
  }

  TRTCScreenCaptureSourceList getScreenCaptureSources(
      TRTCSize thumbnail, TRTCSize icon) {
    TRTCScreenCaptureSourceList list = TRTCScreenCaptureSourceList();

    ffi.Pointer<trtc_size_t> thumbnailPointer =
        trtc_size_t.fromParams(thumbnail);
    ffi.Pointer<trtc_size_t> iconPointer = trtc_size_t.fromParams(icon);
    ffi.Pointer<trtc_screen_capture_source_list> sourceListPtr =
        calloc<trtc_screen_capture_source_list>();
    ffi.Pointer<ffi.Int> count = calloc<ffi.Int>();

    _trtcFFIBindings.get_screen_capture_source_list(
        _trtcsharedInstanceNativePointer,
        thumbnailPointer.ref,
        iconPointer.ref,
        sourceListPtr,
        count);

    list.count = count.value;

    for (int index = 0; index < list.count; index++) {
      TRTCScreenCaptureSourceInfo info = TRTCScreenCaptureSourceInfo();
      ffi.Pointer<trtc_screen_capture_source_info_t> sourceInfo =
          trtc_screen_capture_source_info_t.create(
              thumbnail.height * thumbnail.width * 4,
              icon.height * icon.width * 4);

      _trtcFFIBindings.get_screen_capture_sources_info(
          sourceListPtr.value, index, sourceInfo);

      if (sourceInfo != ffi.nullptr) {
        info.type =
            TRTCScreenCaptureSourceTypeExt.fromValue(sourceInfo.ref.type);
        info.viewId = sourceInfo.ref.source_id.address;
        info.sourceName =
            FFIConverter.getStringFromChar(sourceInfo.ref.source_name);
        info.thumbBGRA = getImageBuffer(sourceInfo.ref.thumb_bgra);
        info.iconBGRA = getImageBuffer(sourceInfo.ref.icon_bgra);
        info.isMinimizeWindow = (sourceInfo.ref.is_minimize_window == 0);
        info.isMainScreen = (sourceInfo.ref.is_main_screen == 0);
        info.x = sourceInfo.ref.x;
        info.y = sourceInfo.ref.y;
        info.width = sourceInfo.ref.width;
        info.height = sourceInfo.ref.height;

        list.sourceList.add(info);
      }
    }

    trtc_size_t.freeStruct(thumbnailPointer);
    trtc_size_t.freeStruct(iconPointer);

    return list;
  }

  void muteAllRemoteAudio(bool mute) {
    _trtcFFIBindings.mute_all_remote_audio(
        _trtcsharedInstanceNativePointer, mute);
  }

  void muteRemoteAudio(String userId, bool mute) {
    final ffi.Pointer<ffi.Char> userIdPointer =
        userId.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.mute_remote_audio(
        _trtcsharedInstanceNativePointer, userIdPointer, mute);

    calloc.free(userIdPointer);
  }

  void pauseScreenCapture() {
    _trtcFFIBindings.pause_screen_capture(_trtcsharedInstanceNativePointer);
  }

  void resumeScreenCapture() {
    _trtcFFIBindings.resume_screen_capture(_trtcsharedInstanceNativePointer);
  }

  void selectScreenCaptureTarget(TRTCScreenCaptureSourceInfo source,
      TRTCRect rect, TRTCScreenCaptureProperty property) {
    ffi.Pointer<trtc_screen_capture_source_info_t> sourcePointer =
        trtc_screen_capture_source_info_t.fromParams(source);
    ffi.Pointer<trtc_rect_t> rectPointer = trtc_rect_t.fromParams(rect);
    ffi.Pointer<trtc_screen_capture_property_t> propertyPointer =
        trtc_screen_capture_property_t.fromParams(property);

    _trtcFFIBindings.select_screen_capture_target(
        _trtcsharedInstanceNativePointer,
        sourcePointer.ref,
        rectPointer.ref,
        propertyPointer.ref);

    trtc_screen_capture_source_info_t.freeStruct(sourcePointer);
    trtc_rect_t.freeStruct(rectPointer);
    trtc_screen_capture_property_t.freeStruct(propertyPointer);
  }

  void addExcludedShareWindow(int windowId) {
    ffi.Pointer<ffi.Void> windowIdPtr = ViewPointerFactory.create(windowId);
    _trtcFFIBindings.add_excluded_share_window(
        _trtcsharedInstanceNativePointer, windowIdPtr);
    ViewPointerFactory.free(windowIdPtr);
  }

  void removeExcludedShareWindow(int windowId) {
    ffi.Pointer<ffi.Void> windowIdPtr = ViewPointerFactory.create(windowId);
    _trtcFFIBindings.remove_excluded_share_window(
        _trtcsharedInstanceNativePointer, windowIdPtr);
    ViewPointerFactory.free(windowIdPtr);
  }

  void removeAllExcludedShareWindows() {
    _trtcFFIBindings
        .remove_all_excluded_share_windows(_trtcsharedInstanceNativePointer);
  }

  void addIncludedShareWindow(int windowId) {
    ffi.Pointer<ffi.Void> windowIdPtr = ViewPointerFactory.create(windowId);
    _trtcFFIBindings.add_included_share_window(
        _trtcsharedInstanceNativePointer, windowIdPtr);
    ViewPointerFactory.free(windowIdPtr);
  }

  void removeIncludedShareWindow(int windowId) {
    ffi.Pointer<ffi.Void> windowIdPtr = ViewPointerFactory.create(windowId);
    _trtcFFIBindings.remove_included_share_window(
        _trtcsharedInstanceNativePointer, windowIdPtr);
    ViewPointerFactory.free(windowIdPtr);
  }

  void removeAllIncludedShareWindows() {
    _trtcFFIBindings
        .remove_all_included_share_windows(_trtcsharedInstanceNativePointer);
  }

  void sendCustomAudioData(TRTCAudioFrame frame) {
    ffi.Pointer<trtc_audio_frame_t> framePointer =
        trtc_audio_frame_t.fromParams(frame);

    _trtcFFIBindings.send_custom_audio_data(
        _trtcsharedInstanceNativePointer, framePointer.ref);

    trtc_audio_frame_t.freeStruct(framePointer);
  }

  bool sendCustomCmdMsg(int cmdID, String data, bool reliable, bool ordered) {
    ffi.Pointer<ffi.Uint8> dataPointer = data.toNativeUtf8().cast<ffi.Uint8>();

    int result = _trtcFFIBindings.send_sustom_cmd_msg(
        _trtcsharedInstanceNativePointer,
        cmdID,
        dataPointer,
        utf8.encode(data).length,
        reliable,
        ordered);

    calloc.free(dataPointer);
    return result != 0;
  }

  void sendCustomVideoData(
      TRTCVideoStreamType streamType, TRTCVideoFrame frame) {
    ffi.Pointer<trtc_video_frame_t> framePointer =
        trtc_video_frame_t.fromParams(frame);

    _trtcFFIBindings.send_custom_video_data(
        _trtcsharedInstanceNativePointer, streamType.value(), framePointer.ref);

    trtc_video_frame_t.freeStruct(framePointer);
  }

  bool sendSEIMsg(String data, int repeatCount) {
    ffi.Pointer<ffi.Uint8> dataPointer = data.toNativeUtf8().cast<ffi.Uint8>();

    int result = _trtcFFIBindings.send_sei_msg(_trtcsharedInstanceNativePointer,
        dataPointer, utf8.encode(data).length, repeatCount);

    calloc.free(dataPointer);
    return result != 0;
  }

  void setAudioCaptureVolume(int volume) {
    _trtcFFIBindings.set_audio_capture_volume(
        _trtcsharedInstanceNativePointer, volume);
  }

  void setAudioPlayoutVolume(int volume) {
    _trtcFFIBindings.set_audio_playout_volume(
        _trtcsharedInstanceNativePointer, volume);
  }

  void setDefaultStreamRecvMode(bool autoRecvAudio, bool autoRecvVideo) {
    _trtcFFIBindings.set_default_stream_recv_mode(
        _trtcsharedInstanceNativePointer, autoRecvAudio, autoRecvVideo);
  }

  void setLogParams(TRTCLogParams params) {
    ffi.Pointer<trtc_log_param_t> paramsPointer =
        trtc_log_param_t.fromParams(params);

    _trtcFFIBindings.set_log_param(
        _trtcsharedInstanceNativePointer, paramsPointer.ref);

    trtc_log_param_t.freeStruct(paramsPointer);
  }

  void setRemoteAudioVolume(String userId, int volume) {
    ffi.Pointer<ffi.Char> userIdPointer =
        userId.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.set_remote_audio_volume(
        _trtcsharedInstanceNativePointer, userIdPointer, volume);

    calloc.free(userIdPointer);
  }

  void setRemoteRenderParams(
      String userId, TRTCVideoStreamType streamType, TRTCRenderParams params) {
    ffi.Pointer<ffi.Char> userIdPointer =
        userId.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<trtc_render_params_t> paramsPointer =
        trtc_render_params_t.fromParams(params);

    _trtcFFIBindings.set_remote_render_params(_trtcsharedInstanceNativePointer,
        userIdPointer, streamType.value(), paramsPointer.ref);

    calloc.free(userIdPointer);
    trtc_render_params_t.freeStruct(paramsPointer);
  }

  // int setRemoteVideoRenderCallback(String userId, TRTCVideoPixelFormat format, TRTCVideoBufferType type, TRTCVideoRenderCallback callback) {
  //   ffi.Pointer<ffi.Char> userIdPointer = userId.toNativeUtf8().cast<ffi.Char>();
  //
  //   _trtcFFIBindings.set_remote_video_render_callback(_trtcsharedInstanceNativePointer, userIdPointer, format.value(), type.value(), callback);
  //
  //   calloc.free(userIdPointer);
  //   return 0;
  // }

  void setRemoteVideoStreamType(String userId, TRTCVideoStreamType streamType) {
    ffi.Pointer<ffi.Char> userIdPointer =
        userId.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.set_remote_video_stream_type(
        _trtcsharedInstanceNativePointer, userIdPointer, streamType.value());

    calloc.free(userIdPointer);
  }

  void setSubStreamEncoderParam(TRTCVideoEncParam param) {
    _trtcFFIBindings.set_sub_stream_encoder_param(
      _trtcsharedInstanceNativePointer,
      param.videoResolution.value(),
      param.videoResolutionMode.value(),
      param.videoFps,
      param.videoBitrate,
      param.minVideoBitrate,
      param.enableAdjustRes,
    );
  }

  void setWatermark(
      TRTCVideoStreamType streamType,
      String srcData,
      TRTCWaterMarkSrcType srcType,
      int width,
      int height,
      double xOffset,
      double yOffset,
      double fWidthRatio,
      {bool isVisibleOnLocalPreview = false}) {
    ffi.Pointer<ffi.Char> srcDataPointer =
        srcData.toNativeUtf8().cast<ffi.Char>();
    ;

    _trtcFFIBindings.set_water_mark(
        _trtcsharedInstanceNativePointer,
        streamType.value(),
        srcDataPointer,
        srcType.value(),
        width,
        height,
        xOffset,
        yOffset,
        fWidthRatio,
        isVisibleOnLocalPreview);

    calloc.free(srcDataPointer);
  }

  int startLocalRecording(TRTCLocalRecordingParams param) {
    ffi.Pointer<trtc_local_recording_params_t> paramsPointer =
        trtc_local_recording_params_t.fromParams(param);

    _trtcFFIBindings.start_local_recording(
        _trtcsharedInstanceNativePointer, paramsPointer.ref);

    trtc_local_recording_params_t.freeStruct(paramsPointer);
    return 0;
  }

  void startPublishMediaStream(TRTCPublishTarget target,
      TRTCStreamEncoderParam param, TRTCStreamMixingConfig config) {
    ffi.Pointer<trtc_publish_target_t> targetPointer =
        trtc_publish_target_t.fromParams(target);
    ffi.Pointer<trtc_stream_encoder_param_t> paramPointer =
        trtc_stream_encoder_param_t.fromParams(param);
    ffi.Pointer<trtc_stream_mixing_config_t> configPointer =
        trtc_stream_mixing_config_t.fromParams(config);

    _trtcFFIBindings.start_publish_media_stream(
        _trtcsharedInstanceNativePointer,
        targetPointer,
        paramPointer,
        configPointer);

    trtc_publish_target_t.freeStruct(targetPointer);
    trtc_stream_encoder_param_t.freeStruct(paramPointer);
    trtc_stream_mixing_config_t.freeStruct(configPointer);
  }

  void startScreenCapture(
      int? viewId, TRTCVideoStreamType streamType, TRTCVideoEncParam encParam) {
    ffi.Pointer<ffi.Void> txView = ViewPointerFactory.create(viewId);
    ffi.Pointer<trtc_video_enc_param_t> encParamPointer =
        trtc_video_enc_param_t.fromParams(encParam);

    _trtcFFIBindings.start_screen_capture(_trtcsharedInstanceNativePointer,
        txView, streamType.value(), encParamPointer);

    trtc_video_enc_param_t.freeStruct(encParamPointer);
    ViewPointerFactory.free(txView);
  }

  int startSpeedTest(TRTCSpeedTestParams params) {
    ffi.Pointer<trtc_speed_test_params_t> paramsPointer =
        trtc_speed_test_params_t.fromParams(params);

    _trtcFFIBindings.start_speed_test(
        _trtcsharedInstanceNativePointer, paramsPointer.ref);

    trtc_speed_test_params_t.freeStruct(paramsPointer);
    return 0;
  }

  void startSystemAudioLoopback({String? deviceName}) {
    ffi.Pointer<ffi.Char> deviceNamePointer =
        deviceName?.toNativeUtf8().cast<ffi.Char>() ?? ffi.nullptr;

    _trtcFFIBindings.start_system_audio_loopback(
        _trtcsharedInstanceNativePointer, deviceNamePointer);

    if (deviceNamePointer != ffi.nullptr) {
      calloc.free(deviceNamePointer);
    }
  }

  void stopLocalRecording() {
    _trtcFFIBindings.stop_local_recording(_trtcsharedInstanceNativePointer);
  }

  void stopPublishMediaStream(String taskId) {
    ffi.Pointer<ffi.Char> taskIdPointer =
        taskId.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.stop_publish_media_stream(
        _trtcsharedInstanceNativePointer, taskIdPointer);

    calloc.free(taskIdPointer);
  }

  void stopScreenCapture() {
    _trtcFFIBindings.stop_screen_capture(_trtcsharedInstanceNativePointer);
  }

  void stopSpeedTest() {
    _trtcFFIBindings.stop_speed_test(_trtcsharedInstanceNativePointer);
  }

  void stopSystemAudioLoopback() {
    _trtcFFIBindings
        .stop_system_audio_loopback(_trtcsharedInstanceNativePointer);
  }

  void updatePublishMediaStream(String taskId, TRTCPublishTarget target,
      TRTCStreamEncoderParam param, TRTCStreamMixingConfig config) {
    ffi.Pointer<ffi.Char> taskIdPointer =
        taskId.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<trtc_publish_target_t> targetPointer =
        trtc_publish_target_t.fromParams(target);
    ffi.Pointer<trtc_stream_encoder_param_t> paramPointer =
        trtc_stream_encoder_param_t.fromParams(param);
    ffi.Pointer<trtc_stream_mixing_config_t> configPointer =
        trtc_stream_mixing_config_t.fromParams(config);

    _trtcFFIBindings.update_publish_media_stream(
        _trtcsharedInstanceNativePointer,
        taskIdPointer,
        targetPointer,
        paramPointer,
        configPointer);

    calloc.free(taskIdPointer);
    trtc_publish_target_t.freeStruct(targetPointer);
    trtc_stream_encoder_param_t.freeStruct(paramPointer);
    trtc_stream_mixing_config_t.freeStruct(configPointer);
  }

  void enableCustomVideoCapture(TRTCVideoStreamType streamType, bool enable) {
    _trtcFFIBindings.enable_custom_video_capture(
        _trtcsharedInstanceNativePointer, streamType.value(), enable);
  }

  void muteAllRemoteVideoStreams(bool mute) {
    _trtcFFIBindings.mute_all_remote_video_streams(
        _trtcsharedInstanceNativePointer, mute);
  }

  void setSystemAudioLoopbackVolume(int volume) {
    _trtcFFIBindings.set_system_audio_loopback_volume(
        _trtcsharedInstanceNativePointer, volume);
  }

  void setVideoMuteImage(TRTCImageBuffer image, int fps) {
    ffi.Pointer<trtc_image_buffer_t> imagePointer =
        trtc_image_buffer_t.fromParams(image);

    _trtcFFIBindings.set_video_mute_image(
        _trtcsharedInstanceNativePointer, imagePointer, fps);

    trtc_image_buffer_t.freeStruct(imagePointer);
  }

  void showDebugView(int showType) {
    _trtcFFIBindings.show_debug_view(
        _trtcsharedInstanceNativePointer, showType);
  }

  void snapshotVideo(String userId, TRTCVideoStreamType streamType,
      TRTCSnapshotSourceType sourceType) {
    ffi.Pointer<ffi.Char> userIdPointer =
        userId.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.snapshot_video(_trtcsharedInstanceNativePointer,
        userIdPointer, streamType.value(), sourceType.value());

    calloc.free(userIdPointer);
  }

  void updateLocalView(int? viewId) {
    ffi.Pointer<ffi.Void> viewPointer = ViewPointerFactory.create(viewId);

    _trtcFFIBindings.update_local_view(
        _trtcsharedInstanceNativePointer, viewPointer);

    ViewPointerFactory.free(viewPointer);
  }

  void updateRemoteView(
      String userId, TRTCVideoStreamType streamType, int? viewId) {
    ffi.Pointer<ffi.Char> userIdPointer =
        userId.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Void> viewPointer = ViewPointerFactory.create(viewId);

    _trtcFFIBindings.update_remote_view(_trtcsharedInstanceNativePointer,
        userIdPointer, streamType.value(), viewPointer);

    calloc.free(userIdPointer);
    ViewPointerFactory.free(viewPointer);
  }

  void writeLog(int level, String location, String tag, String message) {
    ffi.Pointer<ffi.Char> locationPointer =
        location.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Char> tagPointer = tag.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Char> messagePointer =
        message.toNativeUtf8().cast<ffi.Char>();

    _trtcFFIBindings.write_log(
        level, locationPointer, tagPointer, messagePointer);

    calloc.free(locationPointer);
    calloc.free(tagPointer);
    calloc.free(messagePointer);
  }

  TRTCImageBuffer getImageBuffer(trtc_image_buffer_t bufferN) {
    TRTCImageBuffer buffer = TRTCImageBuffer();

    ffi.Pointer<ffi.Uint8> imageData = bufferN.buffer.cast<ffi.Uint8>();
    List<int> bytes = imageData.asTypedList(bufferN.length);
    buffer.buffer = Uint8List.fromList(bytes);
    buffer.length = bufferN.length;
    buffer.width = bufferN.width;
    buffer.height = bufferN.height;

    return buffer;
  }

  void setBeautyStyle(TRTCBeautyStyle style, int beautyLevel,
      int whitenessLevel, int ruddinessLevel) {
    _trtcFFIBindings.set_beauty_style(_trtcsharedInstanceNativePointer,
        style.value(), beautyLevel, whitenessLevel, ruddinessLevel);
  }
}

class ViewPointerFactory {
  static ffi.Pointer<ffi.Void> create(int? viewId) {
    if (viewId == null) {
      return ffi.nullptr;
    }
    if (TRTCPlatform.isOhos) {
      String ohosViewId = 'liteav_surface_$viewId';
      return ohosViewId.toNativeUtf8().cast<ffi.Void>();
    } else {
      if (viewId == 0) {
        return ffi.nullptr;
      }
      return ffi.Pointer<ffi.Void>.fromAddress(viewId);
    }
  }

  static void free(ffi.Pointer<ffi.Void> viewPointer) {
    if (TRTCPlatform.isOhos && viewPointer != ffi.nullptr) {
      calloc.free(viewPointer);
    }
  }
}
