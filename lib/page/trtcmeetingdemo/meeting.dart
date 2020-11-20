import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:toast/toast.dart';
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

    if (isOpenCamera) {
      //打开摄像头
      userList.add(
          {'userId': userInfo['userId'], 'type': 'video', 'visible': true});
    } else {
      userList.add(
          {'userId': userInfo['userId'], 'type': 'video', 'visible': false});
    }
    if (isOpenMic) {
      //开启麦克风
      await trtcCloud.startLocalAudio(quality);
    }

    screenUserList = getScreenList(userList);
    meetModel.setList(userList);
    this.setState(() {});
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
            roomId: meetId), //房间Id
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
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
  onRtcListener(type, param) {
    if (type == TRTCCloudListenerEnum.onError) {
      showErrordDialog(param['errMsg']);
    }
    if (type == TRTCCloudListenerEnum.onEnterRoom) {
      if (param > 0) {
        showToast('进房成功');
      }
    }
    if (type == TRTCCloudListenerEnum.onExitRoom) {
      if (param > 0) {
        showToast('退房成功');
      }
    }
    // 远端用户进房
    if (type == TRTCCloudListenerEnum.onRemoteUserEnterRoom) {
      userList.add({'userId': param, 'type': 'video', 'visible': false});
      screenUserList = getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
    // 远端用户离开房间
    if (type == TRTCCloudListenerEnum.onRemoteUserLeaveRoom) {
      String userId = param['userId'];
      for (var i = 0; i < userList.length; i++) {
        if (userList[i]['userId'] == userId) {
          userList.removeAt(i);
        }
      }
      screenUserList = getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
    //远端用户是否存在可播放的主路画面（一般用于摄像头）
    if (type == TRTCCloudListenerEnum.onUserVideoAvailable) {
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
      screenUserList = getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }

    //辅流监听
    if (type == TRTCCloudListenerEnum.onUserSubStreamAvailable) {
      String userId = param["userId"];
      //视频可用
      if (param["available"]) {
        userList.add({'userId': userId, 'type': 'subStream', 'visible': true});
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
      screenUserList = getScreenList(userList);
      this.setState(() {});
      meetModel.setList(userList);
    }
  }

  // 每4个一屏，得到一个二维数组
  getScreenList(list) {
    int len = 4; //4个一屏
    List<List> result = List();
    int index = 1;
    while (true) {
      if (index * len < list.length) {
        List temp = list.skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      List temp = list.skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }

  /// 获得视图宽高
  Size getViewSize(int listLength, int index, int total) {
    Size screenSize = MediaQuery.of(context).size;

    if (listLength < 5) {
      // 只有一个显示全屏
      if (total == 1) {
        return screenSize;
      }
      // 两个显示半屏
      if (total == 2) {
        return Size(screenSize.width, screenSize.height / 2);
      }
    }
    return Size(screenSize.width / 2, screenSize.height / 2);
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

  Widget renderView(item, valueKey) {
    if (item['visible']) {
      if (item['userId'] == userInfo['userId']) {
        return TRTCCloudVideoView(
            key: valueKey,
            onViewCreated: (viewId) {
              trtcCloud.startLocalPreview(true, viewId);
            });
      } else {
        return TRTCCloudVideoView(
            key: valueKey,
            onViewCreated: (viewId) {
              trtcCloud.startRemoteView(
                  item['userId'],
                  item['type'] == 'video'
                      ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL
                      : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                  viewId);
            });
      }
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
          item['userId'],
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
              SettingPage()
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
            ListView(
              scrollDirection: Axis.horizontal,
              children: screenUserList
                  .map<Widget>(
                    (item) => Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Color.fromRGBO(19, 41, 75, 1),
                      child: Wrap(
                        children: List.generate(
                          item.length,
                          (index) => LayoutBuilder(
                            key: ValueKey(
                                item[index]['userId'] + item[index]['type']),
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              Size size = this.getViewSize(
                                  userList.length, index, item.length);
                              ValueKey valueKey = ValueKey(
                                  item[index]['userId'] + item[index]['type']);

                              return Container(
                                key: valueKey,
                                height: size.height,
                                width: size.width,
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
                    ),
                  )
                  .toList(),
            ),
            topSetting(),
            beautySetting(),
            bottomSetting()
          ],
        ),
      ),
    );
  }
}
