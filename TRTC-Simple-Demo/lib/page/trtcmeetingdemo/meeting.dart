import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/tool.dart';
import './setting.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/index.dart';
import 'package:trtc_demo/models/meeting.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:provider/provider.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';

import 'tool.dart';

const iosAppGroup = 'group.com.tencent.comm.trtc.demo';
const iosExtensionName = 'TRTC Demo Screen';

/// Meeting Page
class MeetingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeetingPageState();
}

class MeetingPageState extends State<MeetingPage> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var meetModel;
  var userInfo = {}; //Multiplayer video user list

  bool isOpenMic = true; //whether turn on the microphone
  bool isOpenCamera = true; //whether turn on the video
  bool isFrontCamera = true; //front camera
  bool isSpeak = true;
  bool isDoubleTap = false;
  bool isShowingWindow = false;
  int? localViewId;
  bool isShowBeauty = true; //whether enable beauty settings
  String curBeauty = 'pitu';
  double curBeautyValue = 6; //The default beauty value is 6
  String doubleUserId = "";
  String doubleUserIdType = "";

  late TRTCCloud trtcCloud;
  late TXDeviceManager txDeviceManager;
  late TXBeautyManager txBeautyManager;
  late TXAudioEffectManager txAudioManager;

  List userList = [];
  List userListLast = [];
  List screenUserList = [];
  int? meetId;
  int quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;

  late ScrollController scrollControl;
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    meetModel = context.read<MeetingModel>();
    var userSetting = meetModel.getUserSetting();
    meetId = userSetting["meetId"];
    userInfo['userId'] = userSetting["userId"];
    isOpenCamera = userSetting["enabledCamera"];
    isOpenMic = userSetting["enabledMicrophone"];
    iniRoom();
    initScrollListener();
  }

  iniRoom() async {
    // Create TRTCCloud singleton
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    // Tencent Cloud Audio Effect Management Module
    txDeviceManager = trtcCloud.getDeviceManager();
    // Beauty filter and animated effect parameter management
    txBeautyManager = trtcCloud.getBeautyManager();
    // Tencent Cloud Audio Effect Management Module
    txAudioManager = trtcCloud.getAudioEffectManager();
    // Register event callback
    trtcCloud.registerListener(onRtcListener);
    // trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
    //   videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480,
    //   videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT));

    // Enter the room
    enterRoom();

    initData();

    //Set beauty effect
    txBeautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE);
    txBeautyManager.setBeautyLevel(6);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState
          .resumed: //Switch from the background to the foreground, and the interface is visible
        if (!kIsWeb && Platform.isAndroid) {
          userListLast = jsonDecode(jsonEncode(userList));
          userList = [];
          screenUserList = MeetingTool.getScreenList(userList);
          this.setState(() {});

          const timeout = const Duration(milliseconds: 100); //10ms
          Timer(timeout, () {
            userList = userListLast;
            screenUserList = MeetingTool.getScreenList(userList);
            this.setState(() {});
          });
        }
        break;
      case AppLifecycleState.paused: // Interface invisible, background
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // Enter the trtc room
  enterRoom() async {
    try {
      userInfo['userSig'] =
          await GenerateTestUserSig.genTestSig(userInfo['userId']);
      meetModel.setUserInfo(userInfo);
    } catch (err) {
      userInfo['userSig'] = '';
      print(err);
    }
    await trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: GenerateTestUserSig.sdkAppId,
            userId: userInfo['userId'],
            userSig: userInfo['userSig'],
            role: TRTCCloudDef.TRTCRoleAnchor,
            roomId: meetId!),
        TRTCCloudDef.TRTC_APP_SCENE_LIVE);
  }

  initData() async {
    if (isOpenCamera) {
      userList.add({
        'userId': userInfo['userId'],
        'type': 'video',
        'visible': true,
        'size': {'width': 0, 'height': 0}
      });
    } else {
      userList.add({
        'userId': userInfo['userId'],
        'type': 'video',
        'visible': false,
        'size': {'width': 0, 'height': 0}
      });
    }
    if (isOpenMic) {
      if (kIsWeb) {
        Future.delayed(Duration(seconds: 3), () {
          trtcCloud.startLocalAudio(quality);
        });
      } else {
        await trtcCloud.startLocalAudio(quality);
      }
    }

    screenUserList = MeetingTool.getScreenList(userList);
    meetModel.setList(userList);
    this.setState(() {});
  }

  destoryRoom() {
    trtcCloud.unRegisterListener(onRtcListener);
    trtcCloud.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    destoryRoom();
    scrollControl.dispose();
    super.dispose();
  }

  /// Event callbacks
  onRtcListener(type, param) async {
    if (type == TRTCCloudListener.onError) {
      if (param['errCode'] == -1308) {
        MeetingTool.toast('Failed to start screen recording', context);
        await trtcCloud.stopScreenCapture();
        userList[0]['visible'] = true;
        isShowingWindow = false;
        this.setState(() {});
        trtcCloud.startLocalPreview(isFrontCamera, localViewId);
      } else {
        showErrordDialog(param['errMsg']);
      }
    }
    if (type == TRTCCloudListener.onEnterRoom) {
      if (param > 0) {
        MeetingTool.toast('Enter room success', context);
      }
    }
    if (type == TRTCCloudListener.onExitRoom) {
      if (param > 0) {
        MeetingTool.toast('Exit room success', context);
      }
    }
    // Remote user entry
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      userList.add({
        'userId': param,
        'type': 'video',
        'visible': false,
        'size': {'width': 0, 'height': 0}
      });
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
    // Remote user leaves room
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      String userId = param['userId'];
      for (var i = 0; i < userList.length; i++) {
        if (userList[i]['userId'] == userId) {
          userList.removeAt(i);
        }
      }
      //The user who is amplifying the video exit room
      if (doubleUserId == userId) {
        isDoubleTap = false;
      }
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      String userId = param['userId'];

      if (param['available']) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'video') {
            userList[i]['visible'] = true;
          }
        }
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'video') {
            if (isDoubleTap &&
                doubleUserId == userList[i]['userId'] &&
                doubleUserIdType == userList[i]['type']) {
              doubleTap(userList[i]);
            }
            trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            userList[i]['visible'] = false;
          }
        }
      }

      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }

    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      if (param["available"]) {
        userList.add({
          'userId': userId,
          'type': 'subStream',
          'visible': true,
          'size': {'width': 0, 'height': 0}
        });
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'subStream') {
            if (isDoubleTap &&
                doubleUserId == userList[i]['userId'] &&
                doubleUserIdType == userList[i]['type']) {
              doubleTap(userList[i]);
            }
            trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
            userList.removeAt(i);
          }
        }
      }
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
  }

  // Screen scrolling left and right event
  initScrollListener() {
    scrollControl = ScrollController();
    double lastOffset = 0;
    scrollControl.addListener(() async {
      double screenWidth = MediaQuery.of(context).size.width;
      int pageSize = (scrollControl.offset / screenWidth).ceil();

      if (lastOffset < scrollControl.offset) {
        scrollControl.animateTo(pageSize * screenWidth,
            duration: Duration(milliseconds: 100), curve: Curves.ease);
        if (scrollControl.offset == pageSize * screenWidth) {
          //Slide from left to right
          for (var i = 1; i < pageSize * MeetingTool.screenLen; i++) {
            await trtcCloud.stopRemoteView(
                userList[i]['userId'],
                userList[i]['type'] == "video"
                    ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
                    : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
          }
        }
      } else {
        scrollControl.animateTo((pageSize - 1) * screenWidth,
            duration: Duration(milliseconds: 100), curve: Curves.ease);
        if (scrollControl.offset == pageSize * screenWidth) {
          var pageScreen = screenUserList[pageSize];
          int initI = 0;
          if (pageSize == 0) {
            initI = 1;
          }
          for (var i = initI; i < pageScreen.length; i++) {
            await trtcCloud.startRemoteView(
                pageScreen[i]['userId'],
                pageScreen[i]['type'] == "video"
                    ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
                    : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                pageScreen[i]['viewId']);
          }
        }
      }
      lastOffset = scrollControl.offset;
    });
  }

  Future<bool?> showErrordDialog(errorMsg) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Tips"),
          content: Text(errorMsg),
          actions: <Widget>[
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndexPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showExitMeetingConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tips"),
          content: Text("Are you sure to exit the meeting?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // Double click zoom in and zoom out
  doubleTap(item) async {
    Size screenSize = MediaQuery.of(context).size;
    if (isDoubleTap) {
      userList.remove(item);
      isDoubleTap = false;
      doubleUserId = "";
      doubleUserIdType = "";
      item['size'] = {'width': 0, 'height': 0};
    } else {
      userList.remove(item);
      isDoubleTap = true;
      doubleUserId = item['userId'];
      doubleUserIdType = item['type'];
      item['size'] = {'width': screenSize.width, 'height': screenSize.height};
    }
    // userself
    if (item['userId'] == userInfo['userId']) {
      userList.insert(0, item);
      if (!kIsWeb && Platform.isIOS) {
        await trtcCloud.stopLocalPreview();
      }
    } else {
      userList.add(item);
      if (item['type'] == 'video') {
        await trtcCloud.stopRemoteView(
            item['userId'], TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
      } else {
        await trtcCloud.stopRemoteView(
            item['userId'], TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
      }
      if (isDoubleTap) {
        userList[0]['visible'] = false;
      } else {
        if (!kIsWeb && Platform.isIOS) {
          await trtcCloud.stopLocalPreview();
        }
        if (isOpenCamera) {
          userList[0]['visible'] = true;
        }
      }
    }

    this.setState(() {});
  }

  startShare({String shareUserId = '', String shareUserSig = ''}) async {
    if (shareUserId == '') await trtcCloud.stopLocalPreview();
    trtcCloud.startScreenCapture(
      TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
      TRTCVideoEncParam(
        videoFps: 10,
        videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720,
        videoBitrate: 1600,
        videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT,
      ),
      appGroup: iosAppGroup,
      shareUserId: shareUserId,
      shareUserSig: shareUserSig,
    );
  }

  onShareClick() async {
    if (kIsWeb) {
      String shareUserId = 'share-' + userInfo['userId'];
      String shareUserSig = await GenerateTestUserSig.genTestSig(shareUserId);
      await startShare(shareUserId: shareUserId, shareUserSig: shareUserSig);
    } else if (!kIsWeb && Platform.isAndroid) {
      if (!isShowingWindow) {
        await startShare();
        userList[0]['visible'] = false;
        this.setState(() {
          isShowingWindow = true;
          isOpenCamera = false;
        });
      } else {
        await trtcCloud.stopScreenCapture();
        userList[0]['visible'] = true;
        trtcCloud.startLocalPreview(isFrontCamera, localViewId);
        this.setState(() {
          isShowingWindow = false;
          isOpenCamera = true;
        });
      }
    } else {
      await startShare();
      //The screen sharing function can only be tested on the real machine
      ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
      this.setState(() {
        isOpenCamera = false;
      });
    }
  }

  Widget renderView(item, valueKey, width, height) {
    if (item['visible']) {
      return GestureDetector(
          key: valueKey,
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () {
            doubleTap(item);
          },
          child: TRTCCloudVideoView(
              key: valueKey,
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
              // viewMode: TRTCCloudDef.TRTC_VideoView_Model_Hybrid,
              // textureParam: CustomRender(
              //   userId: item['userId'],
              //   isLocal: item['userId'] == userInfo['userId'] ? true : false,
              //   streamType: item['type'] == 'video'
              //       ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
              //       : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
              //   width: width.round(),
              //   height: height.round(),
              // ),
              onViewCreated: (viewId) async {
                if (item['userId'] == userInfo['userId']) {
                  await trtcCloud.startLocalPreview(isFrontCamera, viewId);
                  setState(() {
                    localViewId = viewId;
                  });
                } else {
                  trtcCloud.startRemoteView(
                      item['userId'],
                      item['type'] == 'video'
                          ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
                          : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                      viewId);
                }
                item['viewId'] = viewId;
              }));
    } else {
      return Container(
        alignment: Alignment.center,
        child: ClipOval(
          child: Image.asset('images/avatar3_100.20191230.png', scale: 3.5),
        ),
      );
    }
  }

  /// The user name and sound are displayed on the video layer
  Widget videoVoice(item) {
    return Positioned(
      child: new Container(
          child: Row(children: <Widget>[
        Text(
          item['userId'] == userInfo['userId']
              ? item['userId'] + "(me)"
              : item['userId'],
          style: TextStyle(color: Colors.white),
        ),
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Icon(
            Icons.signal_cellular_alt,
            color: Colors.white,
            size: 20,
          ),
        ),
      ])),
      left: 24.0,
      bottom: 80.0,
    );
  }

  Widget topSetting() {
    return new Align(
        child: new Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    isSpeak ? Icons.volume_up : Icons.hearing,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    if (isSpeak) {
                      txDeviceManager.setAudioRoute(
                          TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
                    } else {
                      txDeviceManager
                          .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
                    }
                    setState(() {
                      isSpeak = !isSpeak;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    if (isFrontCamera) {
                      // txDeviceManager.switchCamera(false);
                      trtcCloud.enableCustomVideoProcess(true);
                    } else {
                      // txDeviceManager.switchCamera(true);
                      trtcCloud.enableCustomVideoProcess(false);
                    }
                    setState(() {
                      isFrontCamera = !isFrontCamera;
                    });
                  }),
              Text(meetId.toString(),
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(color: Colors.white)),
                onPressed: () async {
                  bool? delete = await showExitMeetingConfirmDialog();
                  if (delete != null) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Exit Meeting",
                  style: TextStyle(fontSize: 16.0),
                ),
              )
            ],
          ),
          height: 50.0,
          color: Color.fromRGBO(200, 200, 200, 0.4),
        ),
        alignment: Alignment.topCenter);
  }

  ///Beauty setting floating layer
  Widget beautySetting() {
    return Positioned(
      bottom: 80,
      child: Offstage(
        offstage: isShowBeauty,
        child: Container(
          padding: EdgeInsets.all(10),
          color: Color.fromRGBO(0, 0, 0, 0.8),
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  flex: 2,
                  child: Slider(
                    value: curBeautyValue,
                    min: 0,
                    max: 9,
                    divisions: 9,
                    onChanged: (double value) {
                      if (curBeauty == 'smooth' ||
                          curBeauty == 'nature' ||
                          curBeauty == 'pitu') {
                        txBeautyManager.setBeautyLevel(value.round());
                      } else if (curBeauty == 'whitening') {
                        txBeautyManager.setWhitenessLevel(value.round());
                      } else if (curBeauty == 'ruddy') {
                        txBeautyManager.setRuddyLevel(value.round());
                      }
                      this.setState(() {
                        curBeautyValue = value;
                      });
                    },
                  ),
                ),
                Text(curBeautyValue.round().toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
              ]),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 80.0,
                        child: Text(
                          'Smooth',
                          style: TextStyle(
                              color: curBeauty == 'smooth'
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        txBeautyManager.setBeautyStyle(
                            TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH);
                        curBeauty = 'smooth';
                        curBeautyValue = 6;
                      }),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 80.0,
                        child: Text(
                          'Nature',
                          style: TextStyle(
                              color: curBeauty == 'nature'
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        txBeautyManager.setBeautyStyle(
                            TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE);
                        curBeauty = 'nature';
                        curBeautyValue = 6;
                      }),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 80.0,
                        child: Text(
                          'Pitu',
                          style: TextStyle(
                              color: curBeauty == 'pitu'
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        txBeautyManager.setBeautyStyle(
                            TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
                        curBeauty = 'pitu';
                        curBeautyValue = 6;
                      }),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 50.0,
                        child: Text(
                          'Ruddy',
                          style: TextStyle(
                              color: curBeauty == 'ruddy'
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        txBeautyManager.setRuddyLevel(0);
                        curBeauty = 'ruddy';
                        curBeautyValue = 0;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSetting() {
    return new Align(
        child: new Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    isOpenMic ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    if (isOpenMic) {
                      trtcCloud.stopLocalAudio();
                    } else {
                      trtcCloud.startLocalAudio(quality);
                    }

                    setState(() {
                      isOpenMic = !isOpenMic;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    isOpenCamera ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    if (isOpenCamera) {
                      userList[0]['visible'] = false;
                      trtcCloud.stopLocalPreview();
                      if (isDoubleTap &&
                          doubleUserId == userList[0]['userId']) {
                        doubleTap(userList[0]);
                      }
                    } else {
                      userList[0]['visible'] = true;
                    }
                    setState(() {
                      isOpenCamera = !isOpenCamera;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.face,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    this.setState(() {
                      if (isShowBeauty) {
                        isShowBeauty = false;
                      } else {
                        isShowBeauty = true;
                      }
                    });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/memberList');
                  }),
              IconButton(
                icon: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 36.0,
                ),
                onPressed: () {
                  this.onShareClick();
                },
              ),
              SettingPage(),
              IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/test');
                  }),
            ],
          ),
          height: 70.0,
          color: Color.fromRGBO(200, 200, 200, 0.4),
        ),
        alignment: Alignment.bottomCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () async {
          trtcCloud.exitRoom();
          return true;
        },
        child: Stack(
          children: <Widget>[
            ListView.builder(
                scrollDirection: Axis.vertical,
                physics: new ClampingScrollPhysics(),
                itemCount: screenUserList.length,
                cacheExtent: 0,
                controller: scrollControl,
                itemBuilder: (BuildContext context, index) {
                  var item = screenUserList[index];
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Color.fromRGBO(19, 41, 75, 1),
                    child: Wrap(
                      children: List.generate(
                        item.length,
                        (index) => LayoutBuilder(
                          key: ValueKey(item[index]['userId'] +
                              item[index]['type'] +
                              item[index]['size']['width'].toString()),
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            Size size = MeetingTool.getViewSize(
                                MediaQuery.of(context).size,
                                userList.length,
                                index,
                                item.length);
                            double width = size.width;
                            double height = size.height;

                            if (isDoubleTap) {
                              //Set the width and height of other video rendering to 1, otherwise the video will not be streamed
                              if (item[index]['size']['width'] == 0) {
                                width = 1;
                                height = 1;
                              }
                            }
                            ValueKey valueKey = ValueKey(item[index]['userId'] +
                                item[index]['type'] +
                                (isDoubleTap ? "1" : "0"));
                            if (item[index]['size']['width'] > 0) {
                              width = double.parse(
                                  item[index]['size']['width'].toString());
                              height = double.parse(
                                  item[index]['size']['height'].toString());
                            }

                            return Container(
                              key: valueKey,
                              height: height,
                              width: width,
                              child: Stack(
                                key: valueKey,
                                children: <Widget>[
                                  renderView(
                                      item[index], valueKey, width, height),
                                  videoVoice(item[index])
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
            topSetting(),
            beautySetting(),
            bottomSetting()
          ],
        ),
      ),
    );
  }
}
