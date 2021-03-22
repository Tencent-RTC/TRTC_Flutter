import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:toast/toast.dart';
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

const iosAppGroup = 'group.com.tencent.comm.trtc.demo';
const iosExtensionName = 'TRTC Demo Screen';

/// 视频页面
class MeetingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeetingPageState();
}

class MeetingPageState extends State<MeetingPage> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var meetModel;
  var userInfo = {}; //多人视频用户列表

  bool isOpenMic = true; //是否开启麦克风
  bool isOpenCamera = true; //是否开启摄像头
  bool isFrontCamera = true; //是否是前置摄像头
  bool isSpeak = true; //是否是扬声器
  bool isDoubleTap = false; //是否是双击放大
  bool isShowingWindow = false; //是否展示悬浮窗
  int localViewId;
  bool isShowBeauty = true; //是否开启美颜设置
  String curBeauty = 'pitu'; //默认为P图
  double curBeautyValue = 6; // 美颜值默认为6

  TRTCCloud trtcCloud;
  TXDeviceManager txDeviceManager;
  TXBeautyManager txBeautyManager;
  TXAudioEffectManager txAudioManager;

  List userList = [];
  List screenUserList = [];
  int meetId;
  String us;
  int quality;

  ScrollController scrollControl;
  List viewArr = [];
  @override
  initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Map arguments =
          ModalRoute.of(_scaffoldKey.currentContext).settings.arguments;
      meetId = arguments["meetId"];
      userInfo['userId'] = arguments["userId"];
      isOpenCamera = arguments["enabledCamera"];
      isOpenMic = arguments["enabledMicrophone"];
      quality = arguments["quality"];
    });
    meetModel = context.read<MeetingModel>();
    iniRoom();
    initScrollListener();
  }

  iniRoom() async {
    // 创建 TRTCCloud 单例
    trtcCloud = await TRTCCloud.sharedInstance();
    // 获取设备管理模块
    txDeviceManager = trtcCloud.getDeviceManager();
    // 获取美颜管理对象
    txBeautyManager = trtcCloud.getBeautyManager();
    // 获取音效管理类 TXAudioEffectManager
    txAudioManager = trtcCloud.getAudioEffectManager();
    // 注册事件回调
    trtcCloud.registerListener(onRtcListener);

    // 进房
    enterRoom();

    initData();

    //设置美颜效果
    txBeautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
    txBeautyManager.setBeautyLevel(6);
  }

  // 进入房间
  enterRoom() async {
    userInfo['userSig'] =
        await GenerateTestUserSig.genTestSig(userInfo['userId']);
    meetModel.setUserInfo(userInfo);
    trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: GenerateTestUserSig.sdkAppId, //应用Id
            userId: userInfo['userId'], // 用户Id
            userSig: userInfo['userSig'], // 用户签名
            role: TRTCCloudDef.TRTCRoleAnchor,
            roomId: meetId), //房间Id
        TRTCCloudDef.TRTC_APP_SCENE_LIVE);
  }

  initData() async {
    if (isOpenCamera) {
      //打开摄像头
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
      //开启麦克风
      await trtcCloud.startLocalAudio(quality);
    }

    screenUserList = MeetingTool.getScreenList(userList);
    meetModel.setList(userList);
    this.setState(() {});
  }

  // 销毁房间的一些信息
  destoryRoom() {
    trtcCloud.unRegisterListener(onRtcListener);
    trtcCloud.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    destoryRoom();
    scrollControl.dispose();
    super.dispose();
  }

  // 提示浮层
  showToast(text) {
    Toast.show(
      text,
      context,
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.CENTER,
    );
  }

  /// 事件回调
  onRtcListener(type, param) async {
    if (type == TRTCCloudListener.onSwitchRoom) {
      showToast(param['errCode'].toString() + param['errMsg']);
    }
    if (type == TRTCCloudListener.onError) {
      if (param['errCode'] == -1308) {
        showToast('启动录屏失败');
        await trtcCloud.stopScreenCapture();
        userList[0]['visible'] = true;
        isShowingWindow = false;
        this.setState(() {});
        trtcCloud.startLocalPreview(true, localViewId);
      } else {
        showErrordDialog(param['errMsg']);
      }
    }
    if (type == TRTCCloudListener.onScreenCaptureStarted) {
      showToast('屏幕分享开始');
    }
    if (type == TRTCCloudListener.onScreenCapturePaused) {
      showToast('屏幕分享暂停');
    }
    if (type == TRTCCloudListener.onScreenCaptureResumed) {
      showToast('屏幕分享恢复');
    }
    if (type == TRTCCloudListener.onScreenCaptureStoped) {
      showToast('屏幕分享停止');
    }
    if (type == TRTCCloudListener.onEnterRoom) {
      if (param > 0) {
        showToast('进房成功');
      }
    }
    if (type == TRTCCloudListener.onExitRoom) {
      if (param > 0) {
        showToast('退房成功');
      }
    }
    // 远端用户进房
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      print("==onRemoteUserEnterRoom=" + param.toString());
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
    // 远端用户离开房间
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      String userId = param['userId'];
      for (var i = 0; i < userList.length; i++) {
        if (userList[i]['userId'] == userId) {
          userList.removeAt(i);
        }
      }
      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
    //远端用户是否存在可播放的主路画面（一般用于摄像头）
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      print("==onUserVideoAvailable=" + param.toString());
      String userId = param['userId'];

      // 根据状态对视频进行开启和关闭
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
            trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
            userList[i]['visible'] = false;
          }
        }
      }

      screenUserList = MeetingTool.getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }

    //辅流监听
    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      //视频可用
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

  // 屏幕左右滚动事件监听
  initScrollListener() {
    scrollControl = ScrollController();
    scrollControl.addListener(() {
      var firstScreen = screenUserList[0];
      if (scrollControl.offset >= scrollControl.position.maxScrollExtent &&
          !scrollControl.position.outOfRange) {
        for (var i = 1; i < firstScreen.length; i++) {
          if (i != 0) {
            trtcCloud.stopRemoteView(firstScreen[i]['userId'],
                TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL);
          }
        }
      } else if (scrollControl.offset <=
              scrollControl.position.minScrollExtent &&
          !scrollControl.position.outOfRange) {
        for (var i = 1; i < firstScreen.length; i++) {
          if (i != 0) {
            trtcCloud.startRemoteView(firstScreen[i]['userId'],
                TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, viewArr[i]);
          }
        }
      } else {
        // 滑动中
      }
    });
  }

  // sdk出错信查看
  Future<bool> showErrordDialog(errorMsg) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text(errorMsg),
          actions: <Widget>[
            FlatButton(
              child: Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
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

  // 弹出退房确认对话框
  Future<bool> showExitMeetingConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确定退出会议?"),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // 双击放大缩小功能
  doubleTap(item) async {
    Size screenSize = MediaQuery.of(context).size;
    if (isDoubleTap) {
      userList.remove(item);
      isDoubleTap = false;
      item['size'] = {'width': 0, 'height': 0};
    } else {
      userList.remove(item);
      isDoubleTap = true;
      item['size'] = {'width': screenSize.width, 'height': screenSize.height};
    }
    // 用户自己
    if (item['userId'] == userInfo['userId']) {
      userList.insert(0, item);
      await trtcCloud.stopLocalPreview();
    } else {
      userList.add(item);
      if (item['type'] == 'video') {
        await trtcCloud.stopRemoteView(
            item['userId'], TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
      } else {
        await trtcCloud.stopRemoteView(
            item['userId'], TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
      }
    }
    this.setState(() {});
  }

  startShare() async {
    await trtcCloud.stopLocalPreview();
    trtcCloud.startScreenCapture(
      TRTCVideoEncParam(
        videoFps: 10,
        videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720,
        videoBitrate: 1600,
        videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT,
      ),
      iosAppGroup,
    );
  }

  onShareClick() async {
    if (Platform.isAndroid) {
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
        trtcCloud.startLocalPreview(true, localViewId);
        this.setState(() {
          isShowingWindow = false;
          isOpenCamera = true;
        });
      }
    } else {
      await startShare();
      //屏幕分享功能只能在真机测试
      ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
      this.setState(() {
        isOpenCamera = false;
      });
    }
  }

  Widget renderView(item, valueKey) {
    if (item['visible']) {
      return GestureDetector(
          key: valueKey,
          onDoubleTap: () {
            doubleTap(item);
          },
          child: TRTCCloudVideoView(
              key: valueKey,
              viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
              onViewCreated: (viewId) {
                if (item['userId'] == userInfo['userId']) {
                  trtcCloud.startLocalPreview(true, viewId);
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
                viewArr.add(viewId);
              }));
    } else {
      return Container(
        alignment: Alignment.center,
        child: ClipOval(
          child: Image.network(
              'https://imgcache.qq.com/qcloud/public/static//avatar3_100.20191230.png',
              scale: 3.5),
        ),
      );
    }
  }

  /// 用户名、声音显示在视频层上面
  Widget videoVoice(item) {
    return Positioned(
      // red box
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

  /// 顶部设置浮层
  Widget topSetting() {
    return new Align(
        child: new Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          // grey box
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
                      txDeviceManager.switchCamera(false);
                    } else {
                      txDeviceManager.switchCamera(true);
                    }
                    setState(() {
                      isFrontCamera = !isFrontCamera;
                    });
                  }),
              Text(meetId.toString(),
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () async {
                  //弹出对话框并等待其关闭
                  bool delete = await showExitMeetingConfirmDialog();
                  if (delete != null) {
                    trtcCloud.exitRoom();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "退出会议",
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

  ///美颜设置浮层
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
                          '美颜(光滑)',
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
                          '美颜(自然)',
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
                          '美颜(P图)',
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
                          '美白',
                          style: TextStyle(
                              color: curBeauty == 'whitening'
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        txBeautyManager.setWhitenessLevel(0);
                        curBeauty = 'whitening';
                        curBeautyValue = 0;
                      }),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 50.0,
                        child: Text(
                          '红润',
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

  /// 底部设置浮层
  Widget bottomSetting() {
    return new Align(
        child: new Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          // grey box
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
                scrollDirection: Axis.horizontal,
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
                            ValueKey valueKey = ValueKey(item[index]['userId'] +
                                item[index]['type'] +
                                item[index]['size']['width'].toString());
                            if (item[index]['size']['width'] > 0) {
                              width = double.parse(
                                  item[index]['size']['width'].toString());
                              height = double.parse(
                                  item[index]['size']['height'].toString());
                            }
                            //双击放到后
                            if (isDoubleTap) {
                              //其他视频渲染宽高设置为1，否则视频不推流
                              if (item[index]['size']['width'] == 0) {
                                width = 1;
                                height = 1;
                              }
                            }
                            return Container(
                              key: valueKey,
                              height: height,
                              width: width,
                              child: Stack(
                                key: valueKey,
                                children: <Widget>[
                                  renderView(item[index], valueKey),
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
