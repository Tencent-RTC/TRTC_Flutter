import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:trtc_demo/models/user_model.dart';
import 'package:trtc_demo/utils/tool.dart';

/// Video page
class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  late UserModel userInfo;
  late MeetingModel meetModel;

  late TRTCCloud trtcCloud;
  late TXDeviceManager txDeviceManager;
  late TXBeautyManager txBeautyManager;
  late TXAudioEffectManager txAudioManager;

  TRTCAudioFrameListener? _audioFrameListener;

  @override
  initState() {
    super.initState();
    initRoom();
    meetModel = context.read<MeetingModel>();
    userInfo = meetModel.getUserInfo();
  }

  initRoom() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    txDeviceManager = trtcCloud.getDeviceManager();
    txBeautyManager = trtcCloud.getBeautyManager();
    txAudioManager = trtcCloud.getAudioEffectManager();
    trtcCloud.registerListener((type, params) {
      if (type == TRTCCloudListener.onSpeedTest) {
        print("=====onSpeedTest=====");
        print(params);
      }
    });
  }

  String getStreamId() {
    String streamId = GenerateTestUserSig.sdkAppId.toString() + '_122_345_main';
    return streamId;
  }

  // Set up a mixed flow
  setMixConfig() {
    /// Set up mixed stream pre-row-left and right mode
    TRTCTranscodingConfig config = TRTCTranscodingConfig();
    config.videoWidth = 720;
    config.videoHeight = 640;
    config.videoBitrate = 1500;
    config.videoFramerate = 20;
    config.videoGOP = 2;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 2;

    config.streamId = getStreamId();

    config.mode = TRTCCloudDef.TRTC_TranscodingConfigMode_Template_PresetLayout;
    config.mixUsers = [];

    TRTCMixUser mixUser = TRTCMixUser();
    mixUser.userId = "\$PLACE_HOLDER_LOCAL_MAIN\$";
    mixUser.zOrder = 0;
    mixUser.x = 0;
    mixUser.y = 0;
    mixUser.width = 360;
    mixUser.height = 640;
    mixUser.roomId = '122';
    config.mixUsers?.add(mixUser);

    //Lianmai people screen location
    TRTCMixUser remote = TRTCMixUser();
    remote.userId = "\$PLACE_HOLDER_REMOTE\$";
    remote.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;
    remote.zOrder = 1;
    remote.x = 360;
    remote.y = 0;
    remote.width = 360;
    remote.height = 640;
    remote.roomId = '122';
    config.mixUsers?.add(remote);

    trtcCloud.setMixTranscodingConfig(config);
  }

  setMixConfigManual() {
    TRTCTranscodingConfig config = new TRTCTranscodingConfig();
    config.videoWidth = 720;
    config.videoHeight = 1280;
    config.videoBitrate = 1500;
    config.videoFramerate = 20;
    config.videoGOP = 2;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 2;
    config.streamId = getStreamId();
    config.appId = 1256635546;
    config.bizId = 93434;
    config.backgroundColor = 0x000000;
    config.backgroundImage = null;

    config.mode = TRTCCloudDef.TRTC_TranscodingConfigMode_Manual;
    config.mixUsers = [];

    //  Anchor itself
    TRTCMixUser mixUser = new TRTCMixUser();
    mixUser.userId = '345';
    mixUser.zOrder = 0;
    mixUser.x = 0;
    mixUser.y = 0;
    mixUser.width = 720;
    mixUser.height = 1280;
    mixUser.roomId = '122';
    config.mixUsers?.add(mixUser);

    TRTCMixUser remote = TRTCMixUser();
    remote.userId = '388546';
    remote.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;
    remote.zOrder = 1;
    remote.x = 180;
    remote.y = 400;
    remote.width = 135;
    remote.height = 240;
    remote.roomId = '122';
    config.mixUsers!.add(remote);
    trtcCloud.setMixTranscodingConfig(config);
  }

  /// Pre-Edition-Painting Chinese Painting
  setMixConfigInPicture() {
    TRTCTranscodingConfig config = TRTCTranscodingConfig();
    config.videoWidth = 720;
    config.videoHeight = 1280;
    config.videoBitrate = 1500;
    config.videoFramerate = 20;
    config.videoGOP = 2;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 2;
    config.streamId = getStreamId();

    config.mode = TRTCCloudDef.TRTC_TranscodingConfigMode_Template_PresetLayout;
    config.mixUsers = [];

    // Anchor itself
    TRTCMixUser mixUser = TRTCMixUser();
    mixUser.userId = "\$PLACE_HOLDER_LOCAL_MAIN\$";
    mixUser.zOrder = 0;
    mixUser.x = 0;
    mixUser.y = 0;
    mixUser.width = 720;
    mixUser.height = 1280;
    mixUser.roomId = '122';
    config.mixUsers?.add(mixUser);

    //Lianmai people screen location
    TRTCMixUser remote = TRTCMixUser();
    remote.userId = "\$PLACE_HOLDER_REMOTE\$";
    remote.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;

    remote.zOrder = 1;
    remote.x = 500;
    remote.y = 150;
    remote.width = 135;
    remote.height = 240;
    remote.roomId = '122';
    config.mixUsers?.add(remote);

    trtcCloud.setMixTranscodingConfig(config);
  }

  setMixConfigNull() {
    trtcCloud.setMixTranscodingConfig(null);
  }

  TRTCPublishTarget _getTRTCPublishTarget() {
    TRTCPublishCdnUrl url = TRTCPublishCdnUrl();
    url.isInternalLine = true;
    url.rtmpUrl = 'www.***.com';

    TRTCUser mixStreamIdentity = TRTCUser();
    mixStreamIdentity.strRoomId = 'roomid';
    mixStreamIdentity.intRoomId = 666;
    mixStreamIdentity.userId = '999';

    TRTCPublishTarget target = TRTCPublishTarget();
    target.mode = TRTCPublishMode.TRTCPublishMixStreamToRoom;
    target.cdnUrlList = [url, url];
    target.mixStreamIdentity = mixStreamIdentity;
    return target;
  }

  TRTCStreamEncoderParam _getTRTCStreamEncoderParam() {
    TRTCStreamEncoderParam param = TRTCStreamEncoderParam();
    param.videoEncodedWidth = 368;
    param.videoEncodedHeight = 640;
    param.videoEncodedFPS = 30;
    param.videoEncodedGOP = 3;
    param.videoEncodedKbps = 0;
    param.audioEncodedSampleRate = 48000;
    param.audioEncodedChannelNum = 1;
    param.audioEncodedKbps = 50;
    param.audioEncodedCodecType = 2;
    return param;
  }

  TRTCStreamMixingConfig _getTRTCStreamMixingConfig() {
    TRTCUser mixStreamIdentity = TRTCUser();
    mixStreamIdentity.strRoomId = 'roomid';
    mixStreamIdentity.intRoomId = 666;
    mixStreamIdentity.userId = '999';

    TRTCVideoLayout layout = TRTCVideoLayout();
    layout.rect =
        Rect(originX: 1111, originY: 2222, sizeWidth: 3333, sizeHeight: 4444);
    layout.zOrder = 5555;
    layout.fillMode = TRTCVideoFillMode.TRTCVideoFillMode_Fit;
    layout.backgroundColor = 6666;
    layout.placeHolderImage = 'image';
    layout.fixedVideoUser = mixStreamIdentity;
    layout.fixedVideoStreamType = TRTCVideoStreamType.TRTCVideoStreamTypeSub;

    TRTCWatermark watermark = TRTCWatermark();
    watermark.watermarkUrl = 'www.11111.com';
    watermark.rect = Rect(originX: 9, originY: 8, sizeWidth: 7, sizeHeight: 6);
    watermark.zOrder = 8888;

    TRTCStreamMixingConfig config = TRTCStreamMixingConfig();
    config.backgroundColor = 111111;
    config.backgroundImage = 'Image';
    config.videoLayoutList = [layout, layout];
    config.audioMixUserList = [mixStreamIdentity, mixStreamIdentity];
    config.watermarkList = [watermark, watermark];
    return config;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Test API'),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(tabs: [
            Tab(text: 'Main interface'),
            Tab(text: 'Music interface'),
            Tab(text: 'Video interface'),
            Tab(text: 'Beauty & equipment'),
            Tab(text: 'CDN'),
            Tab(text: 'Audio callback')
          ]),
        ),
        body: TabBarView(children: [
          ListView(
            children: [
              TextButton(
                onPressed: () async {
                  trtcCloud.updateRemoteView('345', 0, 0);
                  trtcCloud.updateLocalView(1);
                },
                child: Text('changView1'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.updateLocalView(0);
                  trtcCloud.updateRemoteView('345', 0, 1);
                },
                child: Text('changeview2'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.startSpeedTest(
                      GenerateTestUserSig.sdkAppId,
                      userInfo.userId,
                      await GenerateTestUserSig.genTestSig(
                          userInfo.userId));
                },
                child: Text('startSpeedTest'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.stopSpeedTest();
                },
                child: Text('stopSpeedTest'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
                },
                child: Text('switchRole-audience'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
                },
                child: Text('switchRole-anchor'),
              ),
              TextButton(
                onPressed: () async {
                  var object = new Map();
                  object['roomId'] = 155;
                  object['userId'] = '345';
                  trtcCloud.connectOtherRoom(jsonEncode(object));
                },
                child: Text('connectOtherRoom-room-155-user-345'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.disconnectOtherRoom();
                },
                child: Text('disconnectOtherRoom'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.switchRoom(TRTCSwitchRoomConfig(
                      roomId: 1546,
                      userSig: await GenerateTestUserSig.genTestSig(
                          userInfo.userId)));
                },
                child: Text('switchRoom-1546'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.muteLocalAudio(true);
                },
                child: Text('muteLocalAudio-true'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.muteLocalAudio(false);
                },
                child: Text('muteLocalAudio-false'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.startPublishCDNStream(TRTCPublishCDNParam(
                      appId: 112,
                      bizId: 233,
                      url: 'https://www.baidu.com'));
                },
                child: Text('startPublishCDNStream'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.stopPublishCDNStream();
                },
                child: Text('stopPublishCDNStream'),
              ),
              TextButton(
                onPressed: () async {
                  bool? value = await trtcCloud.sendCustomCmdMsg(
                      1, 'hello', true, true);
                  MeetingTool.toast(value.toString(), context);
                },
                child: Text('sendCustomCmdMsg'),
              ),

              // TextButton(
              //   onPressed: () async {
              //     trtcCloud.setLogCompressEnabled(false);
              //   },
              //   child: Text('setLogCompressEnabled-false'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     trtcCloud.setLogCompressEnabled(true);
              //   },
              //   child: Text('setLogCompressEnabled-true'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     trtcCloud.setLogDirPath(
              //         '/sdcard/Android/data/com.tencent.trtc_demo/files/log/tencent/clavietest');
              //   },
              //   child: Text('setLogDirPath-android-clavietest'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     Directory appDocDir =
              //         await getApplicationDocumentsDirectory();
              //     trtcCloud.setLogDirPath(appDocDir.path + '/clavietest');
              //   },
              //   child: Text('setLogDirPath-ios-clavietest'),
              // ),
              TextButton(
                onPressed: () async {
                  trtcCloud.startPublishing('clavie_stream_001',
                      TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
                },
                child: Text('startPublishing-clavie_stream_001'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.stopPublishing();
                },
                child: Text('stopPublishing'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setRemoteAudioVolume('345', 100);
                },
                child: Text('setRemoteAudioVolume-100'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setRemoteAudioVolume('345', 0);
                },
                child: Text('setRemoteAudioVolume-0'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setAudioCaptureVolume(70);
                },
                child: Text('setAudioCaptureVolume-70'),
              ),
              TextButton(
                onPressed: () async {
                  int? volume = await trtcCloud.getAudioCaptureVolume();
                  MeetingTool.toast(volume.toString(), context);
                },
                child: Text('getAudioCaptureVolume'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setAudioPlayoutVolume(80);
                },
                child: Text('setAudioPlayoutVolume-80'),
              ),
              TextButton(
                onPressed: () async {
                  int? volume = await trtcCloud.getAudioPlayoutVolume();
                  MeetingTool.toast(volume.toString(), context);
                },
                child: Text('getAudioPlayoutVolume'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setNetworkQosParam(
                      TRTCNetworkQosParam(preference: 1));
                },
                child: Text('setNetworkQosParam-Keep a clear'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setNetworkQosParam(
                      TRTCNetworkQosParam(preference: 2));
                },
                child: Text('setNetworkQosParam-Sustainable'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.enableAudioVolumeEvaluation(2000);
                },
                child: Text('enableAudioVolumeEvaluation-Volume every 2S prompt'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.enableAudioVolumeEvaluation(0);
                },
                child: Text('enableAudioVolumeEvaluation-0'),
              ),
              !kIsWeb && Platform.isAndroid
                  ? TextButton(
                onPressed: () async {
                  int? result = await trtcCloud.startAudioRecording(
                      TRTCAudioRecordingParams(
                          filePath:
                          '/sdcard/Android/data/com.tencent.trtc_demo/files/audio.wav'));
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('startAudioRecording-Android'),
              )
                  : TextButton(
                onPressed: () async {
                  Directory appDocDir =
                  await getApplicationDocumentsDirectory();
                  int? result = await trtcCloud.startAudioRecording(
                      TRTCAudioRecordingParams(
                          filePath: appDocDir.path + '/audio.aac'));
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('startAudioRecording-ios'),
              ),
              TextButton(
                onPressed: () async {
                  int? result = await trtcCloud.startAudioRecording(
                      TRTCAudioRecordingParams(
                          filePath: 'E:\\audio.aac'));
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('startAudioRecording-windows(E drive)'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.stopAudioRecording();
                },
                child: Text('stopAudioRecording'),
              ),
              TextButton(
                onPressed: () async {
                  Directory appDocDir =
                  await getApplicationDocumentsDirectory();
                  await trtcCloud.startLocalRecording(
                      TRTCLocalRecordingParams(
                          recordType: TRTCCloudDef.TRTCRecordTypeBoth,
                          interval: 2000,
                          maxDurationPerFile: 20000,
                          filePath:
                          appDocDir.path + '/isolocalVideo.mp4'));
                },
                child: Text('startLocalRecording-Android&ios'),
              ),
              TextButton(
                onPressed: () async {
                  await trtcCloud.startLocalRecording(
                      TRTCLocalRecordingParams(
                          recordType: TRTCCloudDef.TRTCRecordTypeAudio,
                          interval: -1,
                          filePath: 'E:\\videoTest.mp4'));
                },
                child: Text('startLocalRecording-windows(E drive)'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.stopLocalRecording();
                },
                child: Text('stopLocalRecording'),
              ),
              TextButton(
                onPressed: () async {
                  String? version = await trtcCloud.getSDKVersion();
                  MeetingTool.toast(version, context);
                },
                child: Text('getSDKVersion'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.startSystemAudioLoopback();
                },
                child: Text('startSystemAudioLoopback'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.stopSystemAudioLoopback();
                },
                child: Text('stopSystemAudioLoopback'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setSystemAudioLoopbackVolume(50);
                },
                child: Text('setSystemAudioLoopbackVolume 50'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.setSystemAudioLoopbackVolume(100);
                },
                child: Text('setSystemAudioLoopbackVolume 100'),
              ),
              TextButton(
                onPressed: () async {
                  // await trtcCloud.callExperimentalAPI(
                  // jsonEncode({"name": "clavie"}));
                  trtcCloud.callExperimentalAPI(jsonEncode({
                    "api": "setViewBackgroundColor",
                    "params": {"backgroundColor": "0x00000000"}
                  }));
                },
                child: Text('callExperimentalAPI'),
              ),
            ],
          ),
          ListView(
            children: [
              // TextButton(
              //   onPressed: () async {
              //     txAudioManager.enableVoiceEarMonitor(true);
              //   },
              //   child: Text('enableVoiceEarMonitor-true'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txAudioManager.enableVoiceEarMonitor(false);
              //   },
              //   child: Text('enableVoiceEarMonitor-flase'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txAudioManager.setVoiceEarMonitorVolume(0);
              //   },
              //   child: Text('setVoiceEarMonitorVolume-0'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txAudioManager.setVoiceEarMonitorVolume(100);
              //   },
              //   child: Text('setVoiceEarMonitorVolume-100'),
              // ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setVoiceReverbType(
                      TXVoiceReverbType.TXLiveVoiceReverbType_4);
                },
                child: Text('setVoiceReverbType-Low'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setVoiceReverbType(
                      TXVoiceReverbType.TXLiveVoiceReverbType_1);
                },
                child: Text('setVoiceReverbType-KTV'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setVoiceReverbType(
                      TXVoiceReverbType.TXLiveVoiceReverbType_5);
                },
                child: Text('setVoiceReverbType-Brilliant'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setVoiceReverbType(
                      TXVoiceReverbType.TXLiveVoiceReverbType_7);
                },
                child: Text('setVoiceReverbType-magnetic'),
              ),
              // TextButton(
              //   onPressed: () async {
              //     txAudioManager.setVoiceChangerType(
              //         TXVoiceChangerType.TXLiveVoiceChangerType_2);
              //   },
              //   child: Text('setVoiceChangerType-Loli'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txAudioManager.setVoiceChangerType(
              //         TXVoiceChangerType.TXLiveVoiceChangerType_4);
              //   },
              //   child: Text('setVoiceChangerType-Heavy metal'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txAudioManager.setVoiceChangerType(
              //         TXVoiceChangerType.TXLiveVoiceChangerType_0);
              //   },
              //   child: Text('setVoiceChangerType-Turn off'),
              // ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setVoiceCaptureVolume(0);
                },
                child: Text('setVoiceCaptureVolume-0'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setVoiceCaptureVolume(100);
                },
                child: Text('setVoiceCaptureVolume-100'),
              ),
              TextButton(
                onPressed: () async {
                  bool? musidTrue = await txAudioManager.startPlayMusic(
                      AudioMusicParam(
                          id: 223,
                          publish: true,
                          path: kIsWeb
                              ? './media/daoxiang.mp3'
                              : await MeetingTool.copyAssetToLocal(
                              'media/daoxiang.mp3')));
                  MeetingTool.toast(musidTrue.toString(), context);
                },
                child: Text('startPlayMusic'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.pausePlayMusic(223);
                },
                child: Text('pausePlayMusic'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.resumePlayMusic(223);
                },
                child: Text('resumePlayMusic'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.stopPlayMusic(223);
                },
                child: Text('stopPlayMusic'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicPlayoutVolume(223, 0);
                },
                child: Text('setMusicPlayoutVolume-0'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicPlayoutVolume(223, 100);
                },
                child: Text('setMusicPlayoutVolume-100'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicPublishVolume(223, 0);
                },
                child: Text('setMusicPublishVolume-0'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicPublishVolume(223, 100);
                },
                child: Text('setMusicPublishVolume-100'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setAllMusicVolume(0);
                },
                child: Text('setAllMusicVolume-0'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setAllMusicVolume(100);
                },
                child: Text('setAllMusicVolume-100'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicPitch(223, -1);
                },
                child: Text('setMusicPitch- (-1)'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicPitch(223, 1);
                },
                child: Text('setMusicPitch- 1'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicSpeedRate(223, 0.5);
                },
                child: Text('setMusicSpeedRate- 0.5'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.setMusicSpeedRate(223, 2);
                },
                child: Text('setMusicSpeedRate- 2'),
              ),
              TextButton(
                onPressed: () async {
                  int? time =
                  await txAudioManager.getMusicCurrentPosInMS(223);
                  MeetingTool.toast(time.toString(), context);
                },
                child: Text('getMusicCurrentPosInMS'),
              ),
              TextButton(
                onPressed: () async {
                  txAudioManager.seekMusicToPosInMS(223, 220000);
                },
                child: Text('seekMusicToPosInMS-220000'),
              ),
              TextButton(
                onPressed: () async {
                  int? time = await txAudioManager.getMusicDurationInMS(
                      'https://imgcache.qq.com/operation/dianshi/other/daoxiang.72c46ee085f15dc72603b0ba154409879cbeb15e.mp3');
                  print('==time=' + time.toString());
                  MeetingTool.toast(time.toString(), context);
                },
                child: Text('getMusicDurationInMS-Get time for a long time'),
              ),
            ],
          ),
          ListView(children: [
            TextButton(
              onPressed: () async {
                bool? value = await trtcCloud.sendSEIMsg('clavie', 2);
                MeetingTool.toast(value.toString(), context);
              },
              child: Text('sendSEIMsg'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.stopLocalPreview();
              },
              child: Text('stopLocalPreview-Stop local video'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.stopRemoteView(
                    '345', TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
              },
              child: Text('stopRemoteView-Video of remote ID = 345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.stopRemoteView(
                    '345', TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
              },
              child: Text('stopRemoteView-The auxiliary flow of the remote ID = 345'),
            ),
            TextButton(
              onPressed: () async {
                setMixConfig();
              },
              child: Text('setMixTranscodingConfig-leftright'),
            ),
            TextButton(
              onPressed: () async {
                setMixConfigInPicture();
              },
              child: Text('setMixTranscodingConfig-picture'),
            ),
            TextButton(
              onPressed: () async {
                setMixConfigManual();
              },
              child: Text('setMixTranscodingConfig-manual'),
            ),
            TextButton(
              onPressed: () async {
                setMixConfigNull();
              },
              child: Text('setMixTranscodingConfig-null'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.muteLocalVideo(true);
              },
              child: Text('muteLocalVideo-true'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.muteLocalVideo(false);
              },
              child: Text('muteLocalVideo-false'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setVideoMuteImage(
                    'images/watermark_img.png', 10);
              },
              child: Text('setVideoMuteImage-watermark_img'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setVideoMuteImage(null, 10);
              },
              child: Text('setVideoMuteImage-null'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.muteRemoteVideoStream('345', true);
              },
              child: Text('muteRemoteVideoStream-true-Distant user ID345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.muteRemoteVideoStream('345', false);
              },
              child: Text('muteRemoteVideoStream-false-Distant user ID345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.muteAllRemoteVideoStreams(true);
              },
              child: Text('muteAllRemoteVideoStreams-true'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.muteAllRemoteVideoStreams(false);
              },
              child: Text('muteAllRemoteVideoStreams-false'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setLocalRenderParams(TRTCRenderParams(
                    rotation: TRTCCloudDef.TRTC_VIDEO_ROTATION_90,
                    fillMode: TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT,
                    mirrorType:
                    TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
              },
              child: Text('setLocalRenderParams-90 degrees spin'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setLocalRenderParams(TRTCRenderParams(
                    rotation: TRTCCloudDef.TRTC_VIDEO_ROTATION_0,
                    fillMode: TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL,
                    mirrorType:
                    TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO));
              },
              child: Text('setLocalRenderParams-recover'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setRemoteRenderParams(
                    '345',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
                    TRTCRenderParams(
                        rotation: TRTCCloudDef.TRTC_VIDEO_ROTATION_90,
                        fillMode: TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT,
                        mirrorType:
                        TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
              },
              child: Text('setRemoteRenderParams-Small picture 90 degrees-Distant user ID345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setRemoteRenderParams(
                    '345',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
                    TRTCRenderParams(
                        rotation: TRTCCloudDef.TRTC_VIDEO_ROTATION_180,
                        fillMode: TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT,
                        mirrorType:
                        TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
              },
              child: Text('setRemoteRenderParams-Small picture 180 degrees-Distant user ID345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setRemoteRenderParams(
                    '345',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
                    TRTCRenderParams(
                        rotation: TRTCCloudDef.TRTC_VIDEO_ROTATION_270,
                        fillMode: TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT,
                        mirrorType:
                        TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
              },
              child: Text('setRemoteRenderParams-Small picture 270 degrees-Distant user ID345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setRemoteRenderParams(
                    '345',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
                    TRTCRenderParams(
                        rotation: TRTCCloudDef.TRTC_VIDEO_ROTATION_0,
                        fillMode: TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT,
                        mirrorType:
                        TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
              },
              child: Text('setRemoteRenderParams-Small picture recovery-Distant user ID345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setRemoteRenderParams(
                    '345',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                    TRTCRenderParams(
                        rotation: TRTCCloudDef.TRTC_VIDEO_ROTATION_90,
                        fillMode:
                        TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL,
                        mirrorType:
                        TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO));
              },
              child: Text('setRemoteRenderParams-Auxiliary 90 degrees-Distant user ID345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setVideoEncoderRotation(
                    TRTCCloudDef.TRTC_VIDEO_ROTATION_180);
              },
              child: Text('setVideoEncoderRotation-180'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setVideoEncoderRotation(
                    TRTCCloudDef.TRTC_VIDEO_ROTATION_0);
              },
              child: Text('setVideoEncoderRotation-0'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setVideoEncoderMirror(true);
              },
              child: Text('setVideoEncoderMirror-true'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setVideoEncoderMirror(false);
              },
              child: Text('setVideoEncoderMirror-false'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setGSensorMode(
                    TRTCCloudDef.TRTC_GSENSOR_MODE_UIAUTOLAYOUT);
              },
              child: Text('setGSensorMode-Open the gravity induction'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setGSensorMode(
                    TRTCCloudDef.TRTC_GSENSOR_MODE_DISABLE);
              },
              child: Text('setGSensorMode-Turn off gravity sensing'),
            ),
            TextButton(
              onPressed: () async {
                int? value = await trtcCloud.enableEncSmallVideoStream(
                    true, TRTCVideoEncParam(videoFps: 5));
                print('==trtc value' + value.toString());
                MeetingTool.toast(value.toString(), context);
              },
              child: Text('enableEncSmallVideoStream-Turn on dual -way coding'),
            ),
            TextButton(
              onPressed: () async {
                int? value = await trtcCloud.enableEncSmallVideoStream(
                    false, TRTCVideoEncParam(videoFps: 5));
                print('==trtc value' + value.toString());
                MeetingTool.toast(value.toString(), context);
              },
              child: Text('enableEncSmallVideoStream-Turn off dual -way coding'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setRemoteVideoStreamType(
                    '345', TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
              },
              child: Text('setRemoteVideoStreamType-Watch the small picture of 345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setRemoteVideoStreamType(
                    '345', TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
              },
              child: Text('setRemoteVideoStreamType-Watch the big picture of 345'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.snapshotVideo(
                    null,
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
                    0,
                    '/sdcard/Android/data/com.tencent.trtc_demo/files/asw.jpg');
              },
              child: Text('snapshotVideo-Android'),
            ),
            TextButton(
              onPressed: () async {
                Directory appDocDir =
                await getApplicationDocumentsDirectory();
                trtcCloud.snapshotVideo(
                    null,
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
                    0,
                    appDocDir.path + '/test8.jpg');
              },
              child: Text('snapshotVideo-ios-self'),
            ),
            TextButton(
              onPressed: () async {
                Directory appDocDir =
                await getApplicationDocumentsDirectory();
                trtcCloud.snapshotVideo(
                    '2536',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
                    0,
                    appDocDir.path + '/test7.jpg');
              },
              child: Text('snapshotVideo-ios'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setWatermark(
                    'images/watermark_img.png',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
                    0.1,
                    0.3,
                    0.2);
              },
              child: Text('setWatermark-Local picture'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setWatermark(
                    '/sdcard/Android/data/com.tencent.trtc_demo/files/asw.jpg',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
                    0.1,
                    0.3,
                    0.2);
              },
              child: Text('setWatermark-Absolute path'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.setWatermark(
                    'https://main.qcloudimg.com/raw/3f9146cacab4a019b0cc44b8b22b6a38.png',
                    TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
                    0.1,
                    0.3,
                    0.2);
              },
              child: Text('setWatermark-Web image'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.showDebugView(2);
              },
              child: Text('showDebugView-show'),
            ),
            TextButton(
              onPressed: () async {
                trtcCloud.showDebugView(0);
              },
              child: Text('showDebugView-close'),
            ),
          ]),
          ListView(
            children: [
              TextButton(
                onPressed: () async {
                  Map? data = await txDeviceManager
                      .getDevicesList(TRTCCloudDef.TXMediaDeviceTypeMic);
                  MeetingTool.toast(
                      "Number of equipment:" + data!['count'].toString(), context);
                  print(data);
                },
                child: Text('getDevicesList'),
              ),
              TextButton(
                onPressed: () async {
                  Map? data = await txDeviceManager
                      .getDevicesList(TRTCCloudDef.TXMediaDeviceTypeMic);
                  int? result = await txDeviceManager.setCurrentDevice(
                      TRTCCloudDef.TXMediaDeviceTypeMic,
                      data!['deviceList'][0]['deviceId']);
                  MeetingTool.toast("error code:" + result.toString(), context);
                },
                child: Text('setCurrentDevice'),
              ),
              TextButton(
                onPressed: () async {
                  Map? data = await txDeviceManager.getCurrentDevice(
                      TRTCCloudDef.TXMediaDeviceTypeMic);
                  MeetingTool.toast(
                      "Equipment ID:" + data!['deviceId'].toString(), context);
                  print(data);
                },
                child: Text('getCurrentDevice'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.setCurrentDeviceVolume(
                      TRTCCloudDef.TXMediaDeviceTypeMic, 80);
                  MeetingTool.toast("error code" + result.toString(), context);
                },
                child: Text('setCurrentDeviceVolume'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.getCurrentDeviceVolume(
                      TRTCCloudDef.TXMediaDeviceTypeMic);
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('getCurrentDeviceVolume'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.setCurrentDeviceMute(
                      TRTCCloudDef.TXMediaDeviceTypeMic, true);
                  MeetingTool.toast("error code" + result.toString(), context);
                },
                child: Text('setCurrentDeviceMute-true'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.setCurrentDeviceMute(
                      TRTCCloudDef.TXMediaDeviceTypeMic, false);
                  MeetingTool.toast("error code" + result.toString(), context);
                },
                child: Text('setCurrentDeviceMute-false'),
              ),
              TextButton(
                onPressed: () async {
                  bool? result =
                  await txDeviceManager.getCurrentDeviceMute(
                      TRTCCloudDef.TXMediaDeviceTypeMic);
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('getCurrentDeviceMute'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.startMicDeviceTest(2000);
                  MeetingTool.toast(
                      "error code=: " + result.toString(), context);
                },
                child: Text('startMicDeviceTest'),
              ),
              TextButton(
                onPressed: () async {
                  int? result = await txDeviceManager.stopMicDeviceTest();
                  MeetingTool.toast(
                      "error code=: " + result.toString(), context);
                },
                child: Text('stopMicDeviceTest'),
              ),
              TextButton(
                onPressed: () async {
                  int? result = await txDeviceManager
                      .startSpeakerDeviceTest("/test.aac");
                  MeetingTool.toast(
                      "error code=: " + result.toString(), context);
                },
                child: Text('startSpeakerDeviceTest'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.stopSpeakerDeviceTest();
                  MeetingTool.toast(
                      "error code=: " + result.toString(), context);
                },
                child: Text('stopSpeakerDeviceTest'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.setApplicationPlayVolume(70);
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('setApplicationPlayVolume-70 - Windows'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.setApplicationPlayVolume(80);
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('setApplicationPlayVolume-80 - Windows'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.getApplicationPlayVolume();
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('getApplicationPlayVolume - Windows'),
              ),
              TextButton(
                onPressed: () async {
                  int? result =
                  await txDeviceManager.setApplicationMuteState(true);
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('setApplicationMuteState-true Windows'),
              ),
              TextButton(
                onPressed: () async {
                  int? result = await txDeviceManager
                      .setApplicationMuteState(false);
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('setApplicationMuteState-false Windows'),
              ),
              TextButton(
                onPressed: () async {
                  bool? result =
                  await txDeviceManager.getApplicationMuteState();
                  MeetingTool.toast(result.toString(), context);
                },
                child: Text('getApplicationMuteState Windows'),
              ),
              // TextButton(
              //   onPressed: () async {
              //     txBeautyManager.setFilter('images/watermark_img.png');
              //   },
              //   child: Text('setFilter-Local picture'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txBeautyManager.setFilter(
              //         'https://main.qcloudimg.com/raw/3f9146cacab4a019b0cc44b8b22b6a38.png');
              //   },
              //   child: Text('setFilter-Web image'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txBeautyManager.setFilterStrength(0);
              //   },
              //   child: Text('setFilterStrength - 0'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txBeautyManager.setFilterStrength(1);
              //   },
              //   child: Text('setFilterStrength - 1'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txBeautyManager.enableSharpnessEnhancement(true);
              //   },
              //   child: Text('enableSharpnessEnhancement - true'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txBeautyManager.enableSharpnessEnhancement(false);
              //   },
              //   child: Text('enableSharpnessEnhancement - false'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     bool? isFront = await txDeviceManager.isFrontCamera();
              //     MeetingTool.toast(isFront.toString(), context);
              //   },
              //   child: Text('isFrontCamera'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txDeviceManager.switchCamera(false);
              //   },
              //   child: Text('switchCamera-false'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txDeviceManager.switchCamera(true);
              //   },
              //   child: Text('switchCamera-true'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     double? isFront =
              //         await txDeviceManager.getCameraZoomMaxRatio();
              //     MeetingTool.toast(isFront.toString(), context);
              //   },
              //   child: Text('getCameraZoomMaxRatio'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     int? value =
              //         await txDeviceManager.setCameraZoomRatio(1.1);
              //     MeetingTool.toast(value.toString(), context);
              //   },
              //   child: Text('setCameraZoomRatio-1'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     int? value =
              //         await txDeviceManager.setCameraZoomRatio(5.1);
              //     MeetingTool.toast(value.toString(), context);
              //   },
              //   child: Text('setCameraZoomRatio-5'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     bool? isFront =
              //         await txDeviceManager.enableCameraTorch(true);
              //     MeetingTool.toast(isFront.toString(), context);
              //   },
              //   child: Text('enableCameraTorch-true'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     bool? isFront =
              //         await txDeviceManager.enableCameraTorch(false);
              //     MeetingTool.toast(isFront.toString(), context);
              //   },
              //   child: Text('enableCameraTorch-false'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txDeviceManager.setCameraFocusPosition(0, 0);
              //   },
              //   child: Text('setCameraFocusPosition-0,0'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     txDeviceManager.setCameraFocusPosition(100, 100);
              //   },
              //   child: Text('setCameraFocusPosition-100,100'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     int? value =
              //         await txDeviceManager.enableCameraAutoFocus(true);
              //     MeetingTool.toast(value.toString(), context);
              //   },
              //   child: Text('enableCameraAutoFocus-true'),
              // ),
              // TextButton(
              //   onPressed: () async {
              //     bool? value =
              //         await txDeviceManager.isAutoFocusEnabled();
              //     MeetingTool.toast(value.toString(), context);
              //   },
              //   child: Text('isAutoFocusEnabled'),
              // ),
            ],
          ),
          ListView(
            children: [
              TextButton(
                onPressed: () async {
                  trtcCloud.startPublishMediaStream(
                      target: _getTRTCPublishTarget(),
                      params: _getTRTCStreamEncoderParam(),
                      config: _getTRTCStreamMixingConfig());
                },
                child: Text('startPublishMediaStream'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.updatePublishMediaStream(
                      taskId: '888',
                      target: _getTRTCPublishTarget(),
                      encoderParam: _getTRTCStreamEncoderParam(),
                      mixingConfig: _getTRTCStreamMixingConfig());
                },
                child: Text('updatePublishMediaStream'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.stopPublishMediaStream('888');
                },
                child: Text('stopPublishMediaStream'),
              ),
            ],
          ),
          ListView(
            children: [
              TextButton(
                onPressed: () async {
                  if (_audioFrameListener == null) {
                    _audioFrameListener = TRTCAudioFrameListener(
                        onCapturedAudioFrame: (audioFrame) {
                          print(
                              'channels: ${audioFrame.channels}, sampleRate:${audioFrame.sampleRate}, timestamp:${audioFrame.timestamp}, data:${audioFrame.data}, extraData:${audioFrame.extraData}');
                        });
                    trtcCloud.setAudioFrameListener(_audioFrameListener);
                  } else {
                    _audioFrameListener = null;
                    trtcCloud.setAudioFrameListener(_audioFrameListener);
                  }
                  setState(() {});
                },
                child: _audioFrameListener == null
                    ? Text('setAudioFrameListener')
                    : Text('removeAudioFrameListener'),
              )
            ],
          ),
        ]),
      ),
    );
  }
}
