import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';

/// 设置视频分辨率底部浮层
class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  TRTCCloud trtcCloud;

  double currentCaptureValue = 100; //默认采集音量
  double currentPlayValue = 100; //默认播放音量
  bool enabledMirror = true;
  String currentResolution = "360 * 640"; // 默认分辨率
  int currentResValue = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
  List resolutionList = [
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_160,
      "text": "160 * 160",
      "minBitrate": 40,
      "maxBitrate": 300,
      "curBitrate": 300
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180,
      "text": "180 * 320",
      "minBitrate": 80,
      "maxBitrate": 350,
      "curBitrate": 350
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_240,
      "text": "240 * 320",
      "minBitrate": 100,
      "maxBitrate": 400,
      "curBitrate": 400
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_480,
      "text": "480 * 480",
      "minBitrate": 200,
      "maxBitrate": 1000,
      "curBitrate": 750
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360,
      "text": "360 * 640",
      "minBitrate": 200,
      "maxBitrate": 1000,
      "curBitrate": 900
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480,
      "text": "480 * 640",
      "minBitrate": 250,
      "maxBitrate": 1000,
      "curBitrate": 1000
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540,
      "text": "540 * 960",
      "minBitrate": 400,
      "maxBitrate": 1600,
      "curBitrate": 1350
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720,
      "text": "720 * 1280",
      "minBitrate": 500,
      "maxBitrate": 2000,
      "curBitrate": 1850
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080,
      "text": "1080 * 1920",
      "minBitrate": 800,
      "maxBitrate": 3000,
      "curBitrate": 1900
    },
  ];
  int currentVideoFps = 15; //默认视频采集帧率
  List videoFpsList = [15, 20];
  double minBitrate = 200;
  double maxBitrate = 1000;
  double currentBitrate = 900; //默认码率

  @override
  initState() {
    super.initState();
    initRoom();
  }

  initRoom() async {
    trtcCloud = await TRTCCloud.sharedInstance();
  }

  dealMirror(state, value) {
    state(() {
      enabledMirror = value;
    });
    if (value) {
      trtcCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
    } else {
      trtcCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE));
    }
  }

  // 显示分辨率选择控件
  showResolution(morePageState) {
    showModalBottomSheet(
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, state) {
            return Container(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 20,
                onSelectedItemChanged: (position) {
                  trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
                      videoFps: currentVideoFps,
                      videoResolution: resolutionList[position]['value'],
                      videoBitrate: resolutionList[position]['curBitrate'],
                      videoResolutionMode:
                          TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT));

                  morePageState(() {
                    currentResValue = resolutionList[position]['value'];
                    currentResolution = resolutionList[position]['text'];
                    minBitrate = double.parse(
                        resolutionList[position]['minBitrate'].toString());
                    maxBitrate = double.parse(
                        resolutionList[position]['maxBitrate'].toString());
                    currentBitrate = double.parse(
                        resolutionList[position]['curBitrate'].toString());
                  });
                },
                children:
                    resolutionList.map((item) => Text(item['text'])).toList(),
              ),
            );
          });
        },
        context: context);
  }

  // 显示帧率选择控件
  showVideoFps(fpsState) {
    showModalBottomSheet(
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, state) {
            return Container(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 20,
                onSelectedItemChanged: (position) {
                  trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
                    videoResolution: currentResValue,
                    videoFps: videoFpsList[position],
                    videoBitrate: currentBitrate.round(),
                  ));
                  fpsState(() {
                    currentVideoFps = videoFpsList[position];
                  });
                },
                children:
                    videoFpsList.map((item) => Text(item.toString())).toList(),
              ),
            );
          });
        },
        context: context);
  }

  /// 用户列表点击事件
  showSetDialog() {
    showModalBottomSheet(
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, state) {
            return Container(
              color: Color.fromRGBO(19, 41, 75, 1),
              child: MaterialApp(
                home: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    backgroundColor: Color.fromRGBO(19, 41, 75, 1),
                    appBar: AppBar(
                        backgroundColor: Color.fromRGBO(19, 41, 75, 1),
                        bottom: TabBar(
                          tabs: [
                            Tab(text: '视频'),
                            Tab(text: '音频'),
                          ],
                        ),
                        title: Text('设置', textAlign: TextAlign.center)),
                    body: TabBarView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(children: [
                            Row(
                              children: <Widget>[
                                Container(
                                    width: 110,
                                    alignment: Alignment.centerLeft,
                                    child: Text('分辨率',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white))),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    width: 100.0,
                                    height: 50.0,
                                    child: Text(
                                      currentResolution,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  onTap: () => showResolution(state),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    width: 110,
                                    alignment: Alignment.centerLeft,
                                    child: Text('帧率',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white))),
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    width: 100.0,
                                    height: 50.0,
                                    child: Text(
                                      currentVideoFps.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  onTap: () => showVideoFps(state), //点击
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    width: 85,
                                    alignment: Alignment.centerLeft,
                                    child: Text('码率',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white))),
                                Expanded(
                                  flex: 2,
                                  child: Slider(
                                    value: currentBitrate,
                                    min: minBitrate,
                                    max: maxBitrate,
                                    divisions:
                                        (maxBitrate - minBitrate).round(),
                                    label: currentBitrate.round().toString(),
                                    onChanged: (double value) {
                                      trtcCloud.setVideoEncoderParam(
                                          TRTCVideoEncParam(
                                              videoBitrate: value.round(),
                                              videoFps: currentVideoFps,
                                              videoResolution:
                                                  currentResValue));
                                      state(() {
                                        currentBitrate = value;
                                      });
                                    },
                                  ),
                                ),
                                Text(currentBitrate.round().toString() + 'kbps',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    width: 95,
                                    alignment: Alignment.centerLeft,
                                    child: Text('本地镜像',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white))),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    width: 100.0,
                                    height: 50.0,
                                    child: Switch(
                                        value: enabledMirror,
                                        onChanged: (value) =>
                                            dealMirror(state, value)))
                              ],
                            ),
                          ]),
                        ),
                        Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(children: [
                              Row(
                                children: <Widget>[
                                  Text('采集音量',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                  Slider(
                                    value: currentCaptureValue,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    label:
                                        currentCaptureValue.round().toString(),
                                    onChanged: (double value) {
                                      trtcCloud
                                          .setAudioCaptureVolume(value.round());
                                      state(() {
                                        currentCaptureValue = value;
                                      });
                                    },
                                  ),
                                  Text(currentCaptureValue.round().toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('播放音量',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                  Slider(
                                    value: currentPlayValue,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    label: currentPlayValue.round().toString(),
                                    onChanged: (double value) {
                                      trtcCloud
                                          .setAudioPlayoutVolume(value.round());
                                      state(() {
                                        currentPlayValue = value;
                                      });
                                    },
                                  ),
                                  Text(currentPlayValue.round().toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ]))
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.more_horiz,
          color: Colors.white,
          size: 36.0,
        ),
        onPressed: () {
          showSetDialog();
        });
  }
}
