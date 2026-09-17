import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:api_example/pages/advance_media/audio_quality/audio_quality_prepare_page.dart';
import 'package:api_example/pages/advance_media/local_record/local_record_prepare_page.dart';
import 'package:api_example/pages/advance_media/render_params/render_params_prepare_page.dart';
import 'package:api_example/pages/advance_media/screenshot/screenshot_prepare_page.dart';
import 'package:api_example/pages/advance_media/small_video_stream/small_video_stream_prepare_page.dart';
import 'package:api_example/pages/advance_media/video_quality/video_quality_prepare_page.dart';
import 'package:api_example/pages/advance_more/ai_transcriber/ai_transcriber_prepare_page.dart';
import 'package:api_example/pages/advance_more/camera_device_test/camera_device_test_page.dart';
import 'package:api_example/pages/advance_more/device_manager/device_manager_page.dart';
import 'package:api_example/pages/advance_more/publish_media_stream/publish_media_stream_prepare_page.dart';
import 'package:api_example/pages/basic_rooms/audio_call/audio_call_prepare_page.dart';
import 'package:api_example/pages/basic_rooms/live_room/live_room_prepare_page.dart';
import 'package:api_example/pages/basic_rooms/video_call/video_call_prepare_page.dart';
import 'package:api_example/pages/basic_rooms/voice_chat_room/voice_room_prepare_page.dart';
import 'package:flutter/material.dart';
import 'package:api_example/pages/advance_more/connect_other_room/connect_other_room_prepare_page.dart';
import 'package:api_example/pages/advance_more/custom_message/custom_message_prepare_page.dart';
import 'package:api_example/pages/advance_more/switch_room/switch_room_prepare_page.dart';
import 'package:api_example/pages/advance_media/video_mute_image/video_mute_image_prepare_page.dart';
import 'package:api_example/pages/advance_more/network_speed_test/network_speed_test_prepare_page.dart';
import 'package:api_example/pages/advance_more/set_beauty_style/set_beauty_style_prepare_page.dart';
import 'package:api_example/pages/advance_more/set_watermark/set_watermark_prepare_page.dart';
import 'package:api_example/pages/advance_more/audio_effect_manager/music_effect/music_effect_prepare_page.dart';
import 'package:api_example/pages/advance_more/audio_effect_manager/voice_effect/voice_effect_prepare_page.dart';
import 'package:api_example/pages/advance_more/screen_share/screen_share_prepare_page.dart';
import 'package:api_example/pages/advance_more/custom_audio_capture/custom_audio_capture_prepare_page.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class RouterInfo {
  Icon icon;
  final String Function(AppLocalizations l10n) titleBuilder;
  final String Function(AppLocalizations l10n) descriptionBuilder;
  Widget page;

  /// Whether this scene is supported on the current platform.
  /// Defaults to always supported.
  final bool Function() isSupported;

  /// Hint shown (e.g. as a badge/tooltip) when [isSupported] is false.
  /// Only required when the scene has platform restrictions.
  final String Function(AppLocalizations l10n)? unsupportedHintBuilder;

  RouterInfo({
    required this.icon,
    required this.titleBuilder,
    required this.descriptionBuilder,
    required this.page,
    bool Function()? isSupported,
    this.unsupportedHintBuilder,
  }) : isSupported = isSupported ?? (() => true);
}

List<RouterInfo> basicRoomList = [
  RouterInfo(
    icon: const Icon(Icons.call),
    titleBuilder: (l10n) => l10n.sceneAudioCall,
    descriptionBuilder: (l10n) => l10n.descAudioCall,
    page: const AudioCallPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.live_tv),
    titleBuilder: (l10n) => l10n.sceneLiveRoom,
    descriptionBuilder: (l10n) => l10n.descLiveRoom,
    page: const LiveRoomPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.videocam),
    titleBuilder: (l10n) => l10n.sceneVideoCall,
    descriptionBuilder: (l10n) => l10n.descVideoCall,
    page: const VideoCallPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.voice_chat),
    titleBuilder: (l10n) => l10n.sceneVoiceChatRoom,
    descriptionBuilder: (l10n) => l10n.descVoiceChatRoom,
    page: const VoiceRoomPreparePage(),
  ),
];

List<RouterInfo> advanceAvList = [
  RouterInfo(
    icon: const Icon(Icons.spatial_audio_off),
    titleBuilder: (l10n) => l10n.sceneAudioQuality,
    descriptionBuilder: (l10n) => l10n.descAudioQuality,
    page: const AudioQualityPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.video_settings),
    titleBuilder: (l10n) => l10n.sceneVideoQuality,
    descriptionBuilder: (l10n) => l10n.descVideoQuality,
    page: const VideoQualityPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.video_stable_outlined),
    titleBuilder: (l10n) => l10n.sceneRenderParams,
    descriptionBuilder: (l10n) => l10n.descRenderParams,
    page: const RenderParamsPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.record_voice_over),
    titleBuilder: (l10n) => l10n.sceneLocalRecord,
    descriptionBuilder: (l10n) => l10n.descLocalRecord,
    page: const LocalRecordPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.image),
    titleBuilder: (l10n) => l10n.sceneVideoMuteImage,
    descriptionBuilder: (l10n) => l10n.descVideoMuteImage,
    page: const VideoMuteImagePreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.not_started_outlined),
    titleBuilder: (l10n) => l10n.sceneSnapshot,
    descriptionBuilder: (l10n) => l10n.descSnapshot,
    page: const ScreenshotPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.video_collection_outlined),
    titleBuilder: (l10n) => l10n.sceneSmallVideoStream,
    descriptionBuilder: (l10n) => l10n.descSmallVideoStream,
    page: const SmallVideoStreamPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.share),
    titleBuilder: (l10n) => l10n.sceneScreenShare,
    descriptionBuilder: (l10n) => l10n.descScreenShare,
    page: const ScreenSharePreparePage(),
  ),
];

List<RouterInfo> advanceOtherList = [
  RouterInfo(
    icon: const Icon(Icons.account_balance),
    titleBuilder: (l10n) => l10n.sceneSwitchRoom,
    descriptionBuilder: (l10n) => l10n.descSwitchRoom,
    page: const SwitchRoomPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.accessibility_sharp),
    titleBuilder: (l10n) => l10n.scenePk,
    descriptionBuilder: (l10n) => l10n.descPk,
    page: const ConnectOtherRoomPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.abc),
    titleBuilder: (l10n) => l10n.sceneCustomMessage,
    descriptionBuilder: (l10n) => l10n.descCustomMessage,
    page: const CustomMessagePreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.network_check),
    titleBuilder: (l10n) => l10n.sceneNetworkSpeedTest,
    descriptionBuilder: (l10n) => l10n.descNetworkSpeedTest,
    page: const NetworkSpeedTestPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.face),
    titleBuilder: (l10n) => l10n.sceneBeautyStyle,
    descriptionBuilder: (l10n) => l10n.descBeautyStyle,
    page: const SetBeautyStylePreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.branding_watermark),
    titleBuilder: (l10n) => l10n.sceneWatermark,
    descriptionBuilder: (l10n) => l10n.descWatermark,
    page: const SetWatermarkPreparePage(),
    isSupported: () => TRTCPlatform.isIOS || TRTCPlatform.isAndroid,
    unsupportedHintBuilder: (l10n) => l10n.mobileOnlyHint,
  ),
  RouterInfo(
    icon: const Icon(Icons.devices),
    titleBuilder: (l10n) => l10n.sceneDeviceManager,
    descriptionBuilder: (l10n) => l10n.descDeviceManager,
    page: const DeviceManagerPage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.camera_alt),
    titleBuilder: (l10n) => l10n.sceneCameraDeviceTest,
    descriptionBuilder: (l10n) => l10n.descCameraDeviceTest,
    page: const CameraDeviceTestPage(),
    isSupported: () => TRTCPlatform.isMacOS || TRTCPlatform.isWindows,
    unsupportedHintBuilder: (l10n) => l10n.desktopOnlyHint,
  ),
  RouterInfo(
    icon: const Icon(Icons.music_note_outlined),
    titleBuilder: (l10n) => l10n.sceneMusicEffect,
    descriptionBuilder: (l10n) => l10n.descMusicEffect,
    page: const MusicEffectPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.settings_voice_outlined),
    titleBuilder: (l10n) => l10n.sceneVoiceEffect,
    descriptionBuilder: (l10n) => l10n.descVoiceEffect,
    page: const VoiceEffectPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.branding_watermark),
    titleBuilder: (l10n) => l10n.scenePublishMediaStream,
    descriptionBuilder: (l10n) => l10n.descPublishMediaStream,
    page: const PublishMediaStreamPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.mic_external_on),
    titleBuilder: (l10n) => l10n.sceneCustomAudioCapture,
    descriptionBuilder: (l10n) => l10n.descCustomAudioCapture,
    page: const CustomAudioCapturePreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.transcribe),
    titleBuilder: (l10n) => l10n.sceneAiTranscriber,
    descriptionBuilder: (l10n) => l10n.descAiTranscriber,
    page: const AITranscriberPreparePage(),
  ),
];
