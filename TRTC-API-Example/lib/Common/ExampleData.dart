import 'package:flutter/cupertino.dart';
import 'package:trtc_api_example/Advanced/TextureRendering/TextureEnterPage.dart';
import 'package:trtc_api_example/Advanced/JoinMultipleRoom/JoinMultipleRoomPage.dart';
import 'package:trtc_api_example/Advanced/LocalRecord/LocalRecordPage.dart';
import 'package:trtc_api_example/Advanced/LocalVideoShare/LocalVideoSharePage.dart';
import 'package:trtc_api_example/Advanced/PushCDN/PushCDNSelectRolePage.dart';
import 'package:trtc_api_example/Advanced/RoomPk/RoomPkPage.dart';
import 'package:trtc_api_example/Advanced/SEIMessage/SendAndReceiveSEIMessagePage.dart';
import 'package:trtc_api_example/Advanced/SetAudioEffect/SetAudioEffectPage.dart';
import 'package:trtc_api_example/Advanced/SetAudioQuality/SetAudioQualityPage.dart';
import 'package:trtc_api_example/Advanced/SetBackgroudMusic/SetBGMPage.dart';
import 'package:trtc_api_example/Advanced/SetRenderParams/SetRenderParamsPage.dart';
import 'package:trtc_api_example/Advanced/SetVideoQuality/SetVideoQualityPage.dart';
import 'package:trtc_api_example/Advanced/SpeedTest/SpeedTestPage.dart';
import 'package:trtc_api_example/Advanced/StringRoomId/StringRoomIdPage.dart';
import 'package:trtc_api_example/Advanced/SwitchRoom/SwitchRoomPage.dart';
import 'package:trtc_api_example/Basic/AudioCall/AudioCallingEnterPage.dart';
import 'package:trtc_api_example/Basic/Live/LiveEnterPage.dart';
import 'package:trtc_api_example/Basic/ScreenShare/ScreenShareEnterPage.dart';
import 'package:trtc_api_example/Basic/VideoCall/VideoCallingEnterPage.dart';
import 'package:trtc_api_example/Basic/VoiceChatRoom/VoiceChatRoomEnterPage.dart';

class ExampleData {
  static final Map<String, List<ExamplePageItem>> exampleDataList = {
    "基础功能": [
      ExamplePageItem(
        title: "语音通话",
        subTitle: "双人/多人语音通话、包含静音/免提等功能",
        detailPage: AudioCallingEnterPage(),
      ),
      ExamplePageItem(
        title: "视频通话",
        subTitle: "双人/多人视频通话、包含静音/免提等功能",
        detailPage: VideoCallingEnterPage(),
      ),
      ExamplePageItem(
        title: "视频互动直播",
        detailPage: LiveEnterPage(),
      ),
      ExamplePageItem(
        title: "语音互动直播",
        detailPage: VoiceChatRoomEnterPage(),
      ),
      ExamplePageItem(
        title: "录屏直播",
        subTitle: "直播过程中分享屏幕，适用于在线教育，游戏直播等场景",
        detailPage: ScreenShareEnterPage(),
      ),
    ],
    "进阶功能": [
      ExamplePageItem(
        title: "字符串房间号",
        detailPage: StringRoomIdPage(),
      ),
      ExamplePageItem(
        title: "画质设定",
        detailPage: SetVideoQualityPage(),
      ),
      ExamplePageItem(
        title: "音质设定",
        detailPage: SetAudioQualityPage(),
      ),
      ExamplePageItem(
        title: "渲染控制",
        detailPage: SetRenderParamsPage(),
      ),
      ExamplePageItem(
        title: "网络测速",
        detailPage: SpeedTestPage(),
      ),
      ExamplePageItem(
        title: "CDN发布",
        detailPage: PushCDNSelectRolePage(),
      ),
      ExamplePageItem(
        title: "纹理渲染",
        detailPage: TextureEnterPage(),
      ),
      ExamplePageItem(
        title: "设置音效",
        detailPage: SetAudioEffectPage(),
      ),
      ExamplePageItem(
        title: "设置背景音乐",
        detailPage: SetBGMPage(),
      ),
      // ExamplePageItem(
      //   title: "本地视频分享(no support)",
      //   detailPage: LocalVideoSharePage(),
      // ),
      ExamplePageItem(
        title: "本地媒体录制",
        detailPage: LocalRecordPage(),
      ),
      // ExamplePageItem(
      //   title: "加入多个房间(no support)",
      //   subTitle: "专业版才有该功能",
      //   detailPage: JoinMultipleRoomPage(),
      // ),
      ExamplePageItem(
        title: "收发SEI消息",
        detailPage: SendAndReceiveSEIMessagePage(),
      ),
      ExamplePageItem(
        title: "快速切换房间",
        detailPage: SwitchRoomPage(),
      ),
      ExamplePageItem(
        title: "跨房PK",
        detailPage: RoomPkPage(),
      ),
      // ExampleItem(
      //   title: "第三方美颜",
      //   detailPage: ,
      // ),
    ],
  };
}

class ExamplePageItem {
  late String title;
  late String? subTitle;
  late Widget? detailPage;
  ExamplePageItem({required this.title, this.detailPage, this.subTitle});
}
