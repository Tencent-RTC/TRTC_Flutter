import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Debug/Config.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';

///  SpeedTestPage.dart
///  TRTC-API-Example-Dart
///  Created by gavinwjwang on 2022/2/28.
class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({Key? key}) : super(key: key);

  @override
  _SpeedTestPageState createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  String userId = TXHelper.generateRandomUserId();
  late TRTCCloud trtcCloud;
  String btnTitle = "开始测试";
  List<String> printResultList = [];
  @override
  void initState() {
    initTRTCCloud();
    super.initState();
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  destroyRoom() async {
    trtcCloud.unRegisterListener(onTrtcListener);
    await trtcCloud.stopSpeedTest();
    await TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    destroyRoom();
    super.dispose();
  }

  final userIdFocusNode = FocusNode();
  // 隐藏底部输入框
  unFocus() {
    if (userIdFocusNode.hasFocus) {
      userIdFocusNode.unfocus();
    }
  }

  onTrtcListener(type, params) async {
    switch (type) {
      case TRTCCloudListener.onError:
        break;
      case TRTCCloudListener.onWarning:
        break;
      case TRTCCloudListener.onEnterRoom:
        break;
      case TRTCCloudListener.onExitRoom:
        break;
      case TRTCCloudListener.onSwitchRole:
        break;
      case TRTCCloudListener.onRemoteUserEnterRoom:
        break;
      case TRTCCloudListener.onRemoteUserLeaveRoom:
        break;
      case TRTCCloudListener.onConnectOtherRoom:
        break;
      case TRTCCloudListener.onDisConnectOtherRoom:
        break;
      case TRTCCloudListener.onSwitchRoom:
        break;
      case TRTCCloudListener.onUserVideoAvailable:
        break;
      case TRTCCloudListener.onUserSubStreamAvailable:
        break;
      case TRTCCloudListener.onUserAudioAvailable:
        break;
      case TRTCCloudListener.onFirstVideoFrame:
        break;
      case TRTCCloudListener.onFirstAudioFrame:
        break;
      case TRTCCloudListener.onSendFirstLocalVideoFrame:
        break;
      case TRTCCloudListener.onSendFirstLocalAudioFrame:
        break;
      case TRTCCloudListener.onNetworkQuality:
        break;
      case TRTCCloudListener.onStatistics:
        break;
      case TRTCCloudListener.onConnectionLost:
        break;
      case TRTCCloudListener.onTryToReconnect:
        break;
      case TRTCCloudListener.onConnectionRecovery:
        break;
      case TRTCCloudListener.onSpeedTest:
        onSpeedTest(params);
        break;
      case TRTCCloudListener.onCameraDidReady:
        break;
      case TRTCCloudListener.onMicDidReady:
        break;
      case TRTCCloudListener.onUserVoiceVolume:
        break;
      case TRTCCloudListener.onRecvCustomCmdMsg:
        break;
      case TRTCCloudListener.onMissCustomCmdMsg:
        break;
      case TRTCCloudListener.onRecvSEIMsg:
        break;
      case TRTCCloudListener.onStartPublishing:
        break;
      case TRTCCloudListener.onStopPublishing:
        break;
      case TRTCCloudListener.onStartPublishCDNStream:
        break;
      case TRTCCloudListener.onStopPublishCDNStream:
        break;
      case TRTCCloudListener.onSetMixTranscodingConfig:
        break;
      case TRTCCloudListener.onMusicObserverStart:
        break;
      case TRTCCloudListener.onMusicObserverPlayProgress:
        break;
      case TRTCCloudListener.onMusicObserverComplete:
        break;
      case TRTCCloudListener.onSnapshotComplete:
        break;
      case TRTCCloudListener.onScreenCaptureStarted:
        break;
      case TRTCCloudListener.onScreenCapturePaused:
        break;
      case TRTCCloudListener.onScreenCaptureResumed:
        break;
      case TRTCCloudListener.onScreenCaptureStoped:
        break;
      case TRTCCloudListener.onDeviceChange:
        break;
      case TRTCCloudListener.onTestMicVolume:
        break;
      case TRTCCloudListener.onTestSpeakerVolume:
        break;
    }
  }

  onSpeedTest(params) {
    dynamic result = params['currentResult'];
    int finishedCount = params['finishedCount'];
    int totalCount = params['totalCount'];
    String printResult =
        'current server：$finishedCount, total server: $totalCount' +
            '\n' +
            'current ip: ${result['ip']}, quality: ${result['quality']}' +
            '\n' +
            'upLostRate: ${result["upLostRate"] * 100}%' +
            '\n' +
            'downLostRate:${result["downLostRate"] * 100}%, rtt: ${result['rtt']}';
    List<String> tmpList = printResultList;
    tmpList.add(printResult);
    double percent = (finishedCount / totalCount) * 100;

    setState(() {
      printResultList = tmpList;
      btnTitle = '${percent.toStringAsPrecision(4)}%';
    });
    if (finishedCount == totalCount) {
      setState(() {
        btnTitle = "完成测试";
      });
      return;
    }
  }

  beginSpeedTest() async {
    btnTitle = "0%";
    int sdkAppId = Config.sdkAppId;
    String userSig = await GenerateTestUserSig.genTestSig(userId);
    trtcCloud.startSpeedTest(sdkAppId, userId, userSig);
    trtcCloud.registerListener(onTrtcListener);
  }

  onStartButtonClick() {
    printResultList.clear();
    if (btnTitle == "开始测试") {
      beginSpeedTest();
    } else if (btnTitle == "完成测试") {
      btnTitle = "开始测试";
      trtcCloud.unRegisterListener(onTrtcListener);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        unFocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 30, left: 45, right: 45),
              child: TextField(
                style: TextStyle(color: Colors.white),
                autofocus: false,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: this.userId,
                    selection: TextSelection.fromPosition(
                      TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: '${this.userId}'.length),
                    ),
                  ),
                ),
                focusNode: userIdFocusNode,
                decoration: InputDecoration(
                  labelText: "请输入用户ID（必填项）",
                  hintText: "请输入用户ID",
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle:
                      TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  this.userId = value;
                },
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 30, left: 45, right: 45),
              child: Text('测试结果'),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                left: 45,
                right: 45,
                bottom: 10,
              ),
              child: Container(
                height: 380,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: printResultList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.only(left: 5, top: 5, bottom: 20),
                      height: 70,
                      child: Text(
                        printResultList[index],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      onStartButtonClick();
                    },
                    child: Text(btnTitle),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
