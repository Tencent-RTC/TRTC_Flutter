import 'package:flutter/cupertino.dart';
import 'package:trtc_api_example/Advanced/AudioFrameCustomProcess/AudioFrameCustomProcess.dart';
import 'package:trtc_api_example/Advanced/PublishMediaStream/PublishMediaStreamSelectRolePage.dart';
import 'package:trtc_api_example/Advanced/LocalRecord/LocalRecordPage.dart';
import 'package:trtc_api_example/Advanced/RoomPk/RoomPkPage.dart';
import 'package:trtc_api_example/Advanced/SEIMessage/SendAndReceiveSEIMessagePage.dart';
import 'package:trtc_api_example/Advanced/SetAudioEffect/SetAudioEffectPage.dart';
import 'package:trtc_api_example/Advanced/SetAudioQuality/SetAudioQualityPage.dart';
import 'package:trtc_api_example/Advanced/SetBackgroudMusic/SetBGMPage.dart';
import 'package:trtc_api_example/Advanced/SetRenderParams/SetRenderParamsPage.dart';
import 'package:trtc_api_example/Advanced/SetVideoQuality/SetVideoQualityPage.dart';
import 'package:trtc_api_example/Advanced/SpeedTest/SpeedTestPage.dart';
import 'package:trtc_api_example/Advanced/BeautyProcess/BeautyProcessEnterPage.dart';
import 'package:trtc_api_example/Advanced/StringRoomId/StringRoomIdPage.dart';
import 'package:trtc_api_example/Advanced/SwitchRoom/SwitchRoomPage.dart';
import 'package:trtc_api_example/Basic/AudioCall/AudioCallingEnterPage.dart';
import 'package:trtc_api_example/Basic/Live/LiveEnterPage.dart';
import 'package:trtc_api_example/Basic/ScreenShare/ScreenShareEnterPage.dart';
import 'package:trtc_api_example/Basic/VideoCall/VideoCallingEnterPage.dart';
import 'package:trtc_api_example/Basic/VoiceChatRoom/VoiceChatRoomEnterPage.dart';
import 'package:trtc_api_example/generated/l10n.dart';


class ExampleData {
  static late BuildContext context;
  static final Map<String, List<ExamplePageItem>> exampleDataList = {
    TRTCAPIExampleLocalizations.current.main_trtc_base_funciton: [
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_aduio_call,
        subTitle: TRTCAPIExampleLocalizations.current.main_item_aduio_call_desc,
        detailPage: AudioCallingEnterPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_video_call,
        subTitle: TRTCAPIExampleLocalizations.current.main_item_video_call_desc,
        detailPage: VideoCallingEnterPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_live,
        detailPage: LiveEnterPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_voice_chat_room,
        detailPage: VoiceChatRoomEnterPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_screen_share,
        subTitle: TRTCAPIExampleLocalizations.current.main_item_screen_share_desc,
        detailPage: ScreenShareEnterPage(),
      ),
    ],
    TRTCAPIExampleLocalizations.current.main_trtc_advanced: [
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_string_room_id,
        detailPage: StringRoomIdPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_rtrc_set_video_quality,
        detailPage: SetVideoQualityPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_rtrc_set_audio_quality,
        detailPage: SetAudioQualityPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_rerc_render_params,
        detailPage: SetRenderParamsPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_speed_test,
        detailPage: SpeedTestPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_rtrc_set_audio_effect,
        detailPage: SetAudioEffectPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_trtc_set_bgm,
        detailPage: SetBGMPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_local_record,
        detailPage: LocalRecordPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_sei_message,
        detailPage: SendAndReceiveSEIMessagePage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_switch_room,
        detailPage: SwitchRoomPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_trtc_connect_other_room_pk,
        detailPage: RoomPkPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.beauty_process,
        detailPage: BeautyProcessEnterPage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_pushcdn_new,
        detailPage: PublishMediaStreamSelectRolePage(),
      ),
      ExamplePageItem(
        title: TRTCAPIExampleLocalizations.current.main_item_audio_frame_process,
        detailPage: AudioFrameCustomProcessPage(),
      ),
    ],
  };
}

class ExamplePageItem {
  late String title;
  late String? subTitle;
  late Widget? detailPage;
  ExamplePageItem({required this.title, this.detailPage, this.subTitle});
}
