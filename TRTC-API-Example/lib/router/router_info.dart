import 'package:api_example/pages/advance_media/audio_quality/audio_quality_prepare_page.dart';
import 'package:api_example/pages/advance_media/local_record/local_record_page.dart';
import 'package:api_example/pages/advance_media/render_params/render_params_page.dart';
import 'package:api_example/pages/advance_media/screenshot/screenshot_page.dart';
import 'package:api_example/pages/advance_media/small_video_stream/small_video_stream_page.dart';
import 'package:api_example/pages/advance_media/video_quality/video_quality_page.dart';
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
import 'package:api_example/pages/advance_media/video_mute_image/video_mute_image_page.dart';
import 'package:api_example/pages/advance_more/network_speed_test/network_speed_test_prepare_page.dart';
import 'package:api_example/pages/advance_more/set_beauty_style/set_beauty_style_prepare_page.dart';
import 'package:api_example/pages/advance_more/set_watermark/set_watermark_prepare_page.dart';
import 'package:api_example/pages/advance_more/audio_effect_manager/music_effect/music_effect_prepare_page.dart';
import 'package:api_example/pages/advance_more/audio_effect_manager/voice_effect/voice_effect_prepare_page.dart';
import 'package:api_example/pages/advance_more/screen_share/screen_share_prepare_page.dart';
import 'package:api_example/pages/advance_media/screenshot/screenshot_page.dart';
import 'package:api_example/pages/advance_media/small_video_stream/small_video_stream_page.dart';

class RouterInfo {
  Icon icon;
  String title;
  Widget page;

  RouterInfo({
    required this.icon,
    required this.title,
    required this.page
  });
}

List<RouterInfo> basicRoomList = [
  RouterInfo(
    icon: const Icon(Icons.call),
    title: 'Audio Call',
    page: const AudioCallPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.live_tv),
    title: 'Live Room',
    page: const LiveRoomPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.videocam),
    title: 'Video Call',
    page: const VideoCallPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.voice_chat),
    title: 'Voice Chat Room',
    page: const VoiceRoomPreparePage(),
  ),
];

List<RouterInfo> advanceAvList = [
  RouterInfo(
    icon: const Icon(Icons.spatial_audio_off),
    title: 'Audio Quality',
    page: const AudioQualityPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.video_settings),
    title: 'Video Quality',
    page: const VideoQualityPage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.video_stable_outlined),
    title: 'Render Params',
    page: const RenderParamsPage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.record_voice_over),
    title: 'Local Record',
    page: const LocalRecordPage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.image),
    title: 'Video Mute Image',
    page: const VideoMuteImagePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.not_started_outlined),
    title: 'Snapshot',
    page: const ScreenshotPage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.video_collection_outlined),
    title: 'Small Video Stream',
    page: const SmallVideoStreamPage(),
  ),
];

List<RouterInfo> advanceOtherList = [
  RouterInfo(
    icon: const Icon(Icons.account_balance),
    title: 'Switch Room',
    page: const SwitchRoomPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.accessibility_sharp),
    title: 'PK',
    page: const ConnectOtherRoomPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.abc),
    title: 'Custom Message',
    page: const CustomMessagePreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.network_check),
    title: 'Network Speed Test',
    page: const NetworkSpeedTestPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.face),
    title: 'Beauty Style',
    page: const SetBeautyStylePreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.branding_watermark),
    title: 'Watermark',
    page: const SetWatermarkPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.devices),
    title: 'Device Manager',
    page: const DeviceManagerPage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.music_note_outlined),
    title: 'Music Effect',
    page: const MusicEffectPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.settings_voice_outlined),
    title: 'Voice Effect',
    page: const VoiceEffectPreparePage(),
  ),
  RouterInfo(
    icon: const Icon(Icons.branding_watermark),
    title: 'Publish Media Stream',
    page: const PublishMediaStreamPreparePage(),
  ),
];
