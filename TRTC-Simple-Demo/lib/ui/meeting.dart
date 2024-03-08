import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trtc_demo/models/data_models.dart';
import 'package:trtc_demo/models/user_model.dart';
import 'package:trtc_demo/utils/tool.dart';
import 'package:trtc_demo/ui/settings.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:trtc_demo/ui/login.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:provider/provider.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';

const iosAppGroup = 'group.com.tencent.comm.trtc.demo';
const iosExtensionName = 'TRTC Demo Screen';

/// Meeting Page
class MeetingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeetingPageState();
}

class MeetingPageState extends State<MeetingPage> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late MeetingModel _meetModel;

  BeautyType _curBeauty = BeautyType.pitu;

  late TRTCCloud _trtcCloud;
  late TXDeviceManager _txDeviceManager;
  late TXBeautyManager _txBeautyManager;
  late TXAudioEffectManager _txAudioManager;

  List<UserModel> _userList = [];
  List _screenUserList = [];

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _meetModel = context.read<MeetingModel>();
    _initRoom();
  }

  _initRoom() async {
    // Create TRTCCloud singleton
    _trtcCloud = (await TRTCCloud.sharedInstance())!;
    // Tencent Cloud Audio Effect Management Module
    _txDeviceManager = _trtcCloud.getDeviceManager();
    // Beauty filter and animated effect parameter management
    _txBeautyManager = _trtcCloud.getBeautyManager();
    // Tencent Cloud Audio Effect Management Module
    _txAudioManager = _trtcCloud.getAudioEffectManager();
    // Register event callback
    _trtcCloud.registerListener(_onRtcListener);
    // trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
    //   videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480,
    //   videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT));

    // Enter the room
    _enterRoom();

    _initData();

    //Set beauty effect
    _txBeautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE);
    _txBeautyManager.setBeautyLevel(6);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState
            .resumed: //Switch from the background to the foreground, and the interface is visible
        if (!kIsWeb && Platform.isAndroid) {
          List<UserModel> userListLast = jsonDecode(jsonEncode(_userList));
          _userList = [];
          _screenUserList = MeetingTool.getScreenList(_userList);
          this.setState(() {});

          const timeout = const Duration(milliseconds: 100); //10ms
          Timer(timeout, () {
            _userList = userListLast;
            _screenUserList = MeetingTool.getScreenList(_userList);
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
  _enterRoom() async {
    try {
      _meetModel.getUserInfo().userSig =
          await GenerateTestUserSig.genTestSig(_meetModel.getUserInfo().userId);
    } catch (err) {
      _meetModel.getUserInfo().userSig = '';
      print(err);
    }
    await _trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: GenerateTestUserSig.sdkAppId,
            userId: _meetModel.getUserInfo().userId,
            userSig: _meetModel.getUserInfo().userSig ?? '',
            role: TRTCCloudDef.TRTCRoleAnchor,
            roomId: _meetModel.getMeetId()!),
        TRTCCloudDef.TRTC_APP_SCENE_LIVE);
  }

  _initData() async {
    _userList.add(_meetModel.getUserInfo());
    if (_meetModel.getUserInfo().isOpenMic) {
      if (kIsWeb) {
        Future.delayed(Duration(seconds: 3), () {
          _trtcCloud.startLocalAudio(_meetModel.getQuality());
        });
      } else {
        await _trtcCloud.startLocalAudio(_meetModel.getQuality());
      }
    }

    _screenUserList = MeetingTool.getScreenList(_userList);
    _meetModel.setList(_userList);
    this.setState(() {});
  }

  _destoryRoom() {
    _trtcCloud.unRegisterListener(_onRtcListener);
    _trtcCloud.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _destoryRoom();
    super.dispose();
  }

  /// Event callbacks
  _onRtcListener(type, param) async {
    if (type == TRTCCloudListener.onError) {
      if (param['errCode'] == -1308) {
        MeetingTool.toast('Failed to start screen recording', context);
        await _trtcCloud.stopScreenCapture();
        _userList[0].isOpenCamera = true;
        _meetModel.getUserInfo().isShowingWindow = false;
        this.setState(() {});
        _trtcCloud.startLocalPreview(
            _meetModel.getUserInfo().isFrontCamera, _meetModel.getUserInfo().localViewId);
      } else {
        _showErrordDialog(param['errMsg']);
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
      UserModel user = UserModel(userId: param);
      user.type = 'video';
      user.isOpenCamera = false;
      user.size = WidgetSize(width: 0, height: 0);
      _userList.add(user);

      _screenUserList = MeetingTool.getScreenList(_userList);
      this.setState(() {});
      _meetModel.setList(_userList);
    }
    // Remote user leaves room
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      String userId = param['userId'];
      for (var i = 0; i < _userList.length; i++) {
        if (_userList[i].userId == userId) {
          _userList.removeAt(i);
        }
      }
      _screenUserList = MeetingTool.getScreenList(_userList);
      this.setState(() {});
      _meetModel.setList(_userList);
    }
    if (type == TRTCCloudListener.onUserAudioAvailable) {
      String userId = param['userId'];

      for (var i = 0; i < _userList.length; i++) {
        if (_userList[i].userId == userId) {
          _userList[i].isOpenMic = param['available'];
        }
      }
    }
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      String userId = param['userId'];

      if (param['available']) {
        for (var i = 0; i < _userList.length; i++) {
          if (_userList[i].userId == userId && _userList[i].type == 'video') {
            _userList[i].isOpenCamera = true;
          }
        }
      } else {
        for (var i = 0; i < _userList.length; i++) {
          if (_userList[i].userId == userId && _userList[i].type == 'video') {
            _trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            _userList[i].isOpenCamera = false;
          }
        }
      }

      _screenUserList = MeetingTool.getScreenList(_userList);
      this.setState(() {});
      _meetModel.setList(_userList);
    }

    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      if (param["available"]) {
        UserModel user = UserModel(userId: userId);
        user.type = 'subStream';
        user.isOpenCamera = true;
        user.size = WidgetSize(width: 0, height: 0);
        _userList.add(user);
      } else {
        for (var i = 0; i < _userList.length; i++) {
          if (_userList[i].userId == userId &&
              _userList[i].type == 'subStream') {
            _trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
            _userList.removeAt(i);
          }
        }
      }
      _screenUserList = MeetingTool.getScreenList(_userList);
      this.setState(() {});
      _meetModel.setList(_userList);
    }
  }

  Future<bool?> _showErrordDialog(errorMsg) {
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
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showExitMeetingConfirmDialog() {
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

  _startShare({String shareUserId = '', String shareUserSig = ''}) async {
    if (shareUserId == '') await _trtcCloud.stopLocalPreview();
    _trtcCloud.startScreenCapture(
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

  _onShareClick() async {
    if (kIsWeb) {
      String shareUserId = 'share-' + _meetModel.getUserInfo().userId;
      String shareUserSig = await GenerateTestUserSig.genTestSig(shareUserId);
      await _startShare(shareUserId: shareUserId, shareUserSig: shareUserSig);
    } else if (!kIsWeb && Platform.isAndroid) {
      if (!_meetModel.getUserInfo().isShowingWindow) {
        await _startShare();
        _userList[0].isOpenCamera = false;
        this.setState(() {
          _meetModel.getUserInfo().isShowingWindow = true;
          _meetModel.getUserInfo().isOpenCamera = false;
        });
      } else {
        await _trtcCloud.stopScreenCapture();
        _userList[0].isOpenCamera = true;
        _trtcCloud.startLocalPreview(
            _meetModel.getUserInfo().isFrontCamera, _meetModel.getUserInfo().localViewId);
        this.setState(() {
          _meetModel.getUserInfo().isShowingWindow = false;
          _meetModel.getUserInfo().isOpenCamera = true;
        });
      }
    } else if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      MeetingTool.toast(
          'The current platform does not support screen sharing.', context);
      return;
    } else {
      await _startShare();
      //The screen sharing function can only be tested on the real machine
      ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
      this.setState(() {
        _meetModel.getUserInfo().isOpenCamera = false;
      });
    }
  }

  Widget _renderView(UserModel item, valueKey, width, height) {
    if (item.isOpenCamera) {
      return GestureDetector(
          key: valueKey,
          behavior: HitTestBehavior.opaque,
          child: TRTCCloudVideoView(
              key: valueKey,
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              viewType: _meetModel.getTextureRenderingEnable()
                  ? TRTCCloudDef.TRTC_VideoView_Texture
                  : TRTCCloudDef.TRTC_VideoView_TextureView,
              // viewMode: TRTCCloudDef.TRTC_VideoView_Model_Hybrid,
              textureParam: _buildTextureParam(item, width, height),
              onViewCreated: (viewId) async {
                if (item.userId == _meetModel.getUserInfo().userId) {
                  await _trtcCloud.startLocalPreview(
                      _meetModel.getUserInfo().isFrontCamera, viewId);
                  setState(() {
                    _meetModel.getUserInfo().localViewId = viewId;
                  });
                } else {
                  _trtcCloud.startRemoteView(
                      item.userId,
                      item.type == 'video'
                          ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
                          : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                      viewId);
                }
                item.localViewId = viewId;
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

  CustomRender? _buildTextureParam(UserModel item, width, height) {
    if (_meetModel.getTextureRenderingEnable()) {
      return CustomRender(
        userId: item.userId,
        isLocal: item.userId == _meetModel.getUserInfo().userId ? true : false,
        streamType: item.type == 'video'
            ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
            : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
        width: width.round(),
        height: height.round(),
      );
    } else {
      return null;
    }
  }

  /// The user name and sound are displayed on the video layer
  Widget _videoVoice(UserModel item) {
    return Positioned(
      child: new Container(
          child: Row(children: <Widget>[
        Text(
          item.userId == _meetModel.getUserInfo().userId
              ? item.userId + "(me)"
              : item.userId,
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

  Widget _topSetting() {
    return new Align(
        child: new Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    _meetModel.getUserInfo().isSpeak ? Icons.volume_up : Icons.hearing,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    if (_meetModel.getUserInfo().isSpeak) {
                      _txDeviceManager.setAudioRoute(
                          TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
                    } else {
                      _txDeviceManager
                          .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
                    }
                    setState(() {
                      _meetModel.getUserInfo().isSpeak = !_meetModel.getUserInfo().isSpeak;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    if (_meetModel.getUserInfo().isFrontCamera) {
                      _txDeviceManager.switchCamera(false);
                    } else {
                      _txDeviceManager.switchCamera(true);
                    }
                    setState(() {
                      _meetModel.getUserInfo().isFrontCamera = !_meetModel.getUserInfo().isFrontCamera;
                    });
                  }),
              Text(_meetModel.getMeetId().toString(),
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(color: Colors.white)),
                onPressed: () async {
                  bool? delete = await _showExitMeetingConfirmDialog();
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
  Widget _beautySetting() {
    return Positioned(
      bottom: 80,
      child: Offstage(
        offstage: _meetModel.getUserInfo().isShowBeauty,
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
                    value: _meetModel.getBeautyInfo()[_curBeauty] ?? 0.0,
                    min: 0,
                    max: 9,
                    divisions: 9,
                    onChanged: (double value) {
                      switch (_curBeauty) {
                        case BeautyType.smooth:
                          _txBeautyManager.setBeautyLevel(value.round());
                          break;
                        case BeautyType.nature:
                          _txBeautyManager.setBeautyLevel(value.round());
                          break;
                        case BeautyType.pitu:
                          _txBeautyManager.setBeautyLevel(value.round());
                          break;
                        case BeautyType.ruddy:
                          _txBeautyManager.setRuddyLevel(value.round());
                          break;
                        default:
                          break;
                      }

                      this.setState(() {
                        _meetModel.getBeautyInfo()[_curBeauty] = value;
                      });
                    },
                  ),
                ),
                Text(_meetModel.getBeautyInfo()[_curBeauty]?.round().toString() ?? '0',
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
                              color: _curBeauty == BeautyType.smooth
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        _txBeautyManager.setBeautyStyle(
                            TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH);
                        _curBeauty = BeautyType.smooth;
                        _txBeautyManager.setBeautyLevel(
                            _meetModel.getBeautyInfo()[_curBeauty]?.round() ?? 0);
                      }),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 80.0,
                        child: Text(
                          'Nature',
                          style: TextStyle(
                              color: _curBeauty == BeautyType.nature
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        _txBeautyManager.setBeautyStyle(
                            TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE);
                        _curBeauty = BeautyType.nature;
                        _txBeautyManager.setBeautyLevel(
                            _meetModel.getBeautyInfo()[_curBeauty]?.round() ?? 0);
                      }),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 80.0,
                        child: Text(
                          'Pitu',
                          style: TextStyle(
                              color: _curBeauty == BeautyType.pitu
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        _txBeautyManager.setBeautyStyle(
                            TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
                        _curBeauty = BeautyType.pitu;
                        _txBeautyManager.setBeautyLevel(
                            _meetModel.getBeautyInfo()[_curBeauty]?.round() ?? 0);
                      }),
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: 50.0,
                        child: Text(
                          'Ruddy',
                          style: TextStyle(
                              color: _curBeauty == BeautyType.ruddy
                                  ? Color.fromRGBO(64, 158, 255, 1)
                                  : Colors.white),
                        ),
                      ),
                      onTap: () => this.setState(() {
                        _curBeauty = BeautyType.ruddy;
                        _txBeautyManager.setRuddyLevel(
                            _meetModel.getBeautyInfo()[_curBeauty]?.round() ?? 0);
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

  Widget _bottomSetting() {
    return new Align(
        child: new Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    _meetModel.getUserInfo().isOpenMic ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    if (_meetModel.getUserInfo().isOpenMic) {
                      _trtcCloud.stopLocalAudio();
                    } else {
                      _trtcCloud.startLocalAudio(_meetModel.getQuality());
                    }

                    setState(() {
                      _meetModel.getUserInfo().isOpenMic = !_meetModel.getUserInfo().isOpenMic;
                    });
                  }),
              IconButton(
                  icon: Icon(
                    _meetModel.getUserInfo().isOpenCamera
                        ? Icons.videocam
                        : Icons.videocam_off,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    if (_meetModel.getUserInfo().isOpenCamera) {
                      _userList[0].isOpenCamera = false;
                      _trtcCloud.stopLocalPreview();
                    } else {
                      _userList[0].isOpenCamera = true;
                    }
                    setState(() { });
                  }),
              IconButton(
                  icon: Icon(
                    Icons.face,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    this.setState(() {
                      if (_meetModel.getUserInfo().isShowBeauty) {
                        _meetModel.getUserInfo().isShowBeauty = false;
                      } else {
                        _meetModel.getUserInfo().isShowBeauty = true;
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
                  this._onShareClick();
                },
              ),
              SettingsPage(),
              IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () {
                    if (kIsWeb) {
                      Navigator.pushNamed(context, '/testweb');
                      return;
                    }
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
          _trtcCloud.exitRoom();
          return true;
        },
        child: Stack(
          children: <Widget>[
            PageView.builder(
                physics: new ClampingScrollPhysics(),
                itemCount: _screenUserList.length,
                itemBuilder: (BuildContext context, index) {
                  List<UserModel> item = _screenUserList[index];
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Color.fromRGBO(19, 41, 75, 1),
                    child: Wrap(
                      children: List.generate(
                        item.length,
                        (index) => LayoutBuilder(
                          key: ValueKey(item[index].userId +
                              item[index].type +
                              item[index].size.width.toString()),
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            Size size = MeetingTool.getViewSize(
                                MediaQuery.of(context).size,
                                _userList.length,
                                index,
                                item.length);
                            double width = size.width;
                            double height = size.height;

                            ValueKey valueKey = ValueKey(item[index].userId +
                                item[index].type +
                                "0");
                            if (item[index].size.width > 0) {
                              width = double.parse(
                                  item[index].size.width.toString());
                              height = double.parse(
                                  item[index].size.height.toString());
                            }

                            return Container(
                              key: valueKey,
                              height: height,
                              width: width,
                              child: Stack(
                                key: valueKey,
                                children: <Widget>[
                                  _renderView(
                                      item[index], valueKey, width, height),
                                  _videoVoice(item[index])
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
            _topSetting(),
            _beautySetting(),
            _bottomSetting()
          ],
        ),
      ),
    );
  }
}
