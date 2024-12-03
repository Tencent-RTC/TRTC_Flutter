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
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:trtc_demo/ui/login.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:provider/provider.dart';

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

  late TRTCCloud _trtcCloud;
  late TXDeviceManager _txDeviceManager;
  List<UserModel> _userList = [];
  List _screenUserList = [];
  BeautyType _beautyType = BeautyType.white;

  late TRTCCloudListener _listener;

  int _logShowLevel = 0;

  _printLog(int level, String msg) {
    if (level > _logShowLevel) {
      debugPrint(msg);
    }
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onError: (errCode, errMsg) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onError errCode:$errCode errMsg:$errMsg");

        _showErrorDialog(errMsg);
      },
      onWarning: (warningCode, warningMsg) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onWarning warningCode:$warningCode warningMsg:$warningMsg");
      },
      onEnterRoom: (result) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onEnterRoom result:$result");

        if (result > 0) {
          MeetingTool.toast('Enter room success', context);
        }
      },
      onExitRoom: (reason) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onExitRoom reason:$reason");

        if (reason > 0) {
          MeetingTool.toast('Exit room success', context);
        }
      },
      onSwitchRole: (errCode, errMsg) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSwitchRole errCode:$errCode errMsg:$errMsg");
      },
      onSwitchRoom: (errCode, errMsg) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSwitchRoom errCode:$errCode errMsg:$errMsg");
      },
      onConnectOtherRoom: (userId, errCode, errMsg) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectOtherRoom userId:$userId errCode:$errCode errMsg:$errMsg");
      },
      onDisconnectOtherRoom: (errCode, errMsg) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onDisconnectOtherRoom errCode:$errCode errMsg:$errMsg");
      },
      onRemoteUserEnterRoom: (userId) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteUserEnterRoom userId:$userId");

        _handleOnRemoteUserEnterRoom(userId);
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteUserLeaveRoom userId:$userId reason:$reason");

        _handleOnRemoteUserLeaveRoom(userId);
      },
      onUserVideoAvailable: (userId, available) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVideoAvailable userId:$userId available:$available");

        _handleOnUserVideoAvailable(userId, available);
      },
      onUserSubStreamAvailable: (userId, available) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserSubStreamAvailable userId:$userId available:$available");

        _handleOnUserSubStreamAvailable(userId, available);
      },
      onUserAudioAvailable: (userId, available) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserAudioAvailable userId:$userId available:$available");

        _handleOnUserAudioAvailable(userId, available);
      },
      onFirstVideoFrame: (userId, streamType, width, height) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onFirstVideoFrame userId:$userId streamType:$streamType width:$width height:$height");
      },
      onFirstAudioFrame: (userId) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onFirstAudioFrame userId:$userId");
      },
      onSendFirstLocalVideoFrame: (streamType) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSendFirstLocalVideoFrame streamType:$streamType");
      },
      onSendFirstLocalAudioFrame: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSendFirstLocalAudioFrame");
      },
      onRemoteVideoStatusUpdated: (userId, streamType, status, reason) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteVideoStatusUpdated userId:$userId streamType:$streamType status:$status reason:$reason");
      },
      onRemoteAudioStatusUpdated: (userId, status, reason) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteAudioStatusUpdated userId:$userId status:$status reason:$reason");
      },
      onUserVideoSizeChanged: (userId, streamType, newWidth, newHeight) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVideoSizeChanged userId:$userId streamType:$streamType newWidth:$newWidth newHeight:$newHeight");
      },
      onNetworkQuality: (localQuality, remoteQuality) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onNetworkQuality localQuality userId:${localQuality.userId} quality:${localQuality.quality}");

        for (TRTCQualityInfo info in remoteQuality) {
          _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onNetworkQuality remoteQuality userId:${info.userId} quality:${info.quality}");
        }
      },
      onStatistics: (statistics) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics "
            "appCu:${statistics.appCpu} systemCu:${statistics.systemCpu} upLoss:${statistics.upLoss} "
            "downLoss:${statistics.downLoss} rtt:${statistics.rtt} gatewayRtt:${statistics.gatewayRtt} "
            "sendBytes:${statistics.sentBytes} receiveBytes:${statistics.receivedBytes}");

        for (TRTCLocalStatistics info in statistics.localStatisticsArray!) {
          _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics width:${info.width} height:${info.height} frameRate:${info.frameRate} \n"
              " onStatistics videoBitrate:${info.videoBitrate} audioSampleRate:${info.audioSampleRate} audioBitrate:${info.audioBitrate} \n"
              " onStatistics streamType:${info.streamType} audioCaptureState:${info.audioCaptureState}");
        }

        for (TRTCRemoteStatistics info in statistics.remoteStatisticsArray!) {
          _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics userId:${info.userId} audioPacketLoss:${info.audioPacketLoss} videoPacketLoss:${info.videoPacketLoss} \n"
              " onStatistics width:${info.width} height:${info.height} frameRate:${info.frameRate} videoBitrate:${info.videoBitrate} audioSampleRate:${info.audioSampleRate} \n"
              " onStatistics audioBitrate:${info.audioBitrate} jitterBufferDelay:${info.jitterBufferDelay} point2PointDelay:${info.point2PointDelay} audioTotalBlockTime:${info.audioTotalBlockTime} \n"
              " onStatistics audioBlockRate:${info.audioBlockRate} videoTotalBlockTime:${info.videoTotalBlockTime} videoBlockRate:${info.videoBlockRate} finalLoss:${info.finalLoss} remoteNetworkUplinkLoss:${info.remoteNetworkUplinkLoss} \n"
              " onStatistics remoteNetworkRTT:${info.remoteNetworkRTT} streamType:${info.streamType}");
        }
      },
      onSpeedTestResult: (result) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSpeedTestResult TRTCSpeedTestResult: success:${result.success} errMsg:${result.errMsg} ip:${result.ip} \n"
            " onSpeedTestResult quality:${result.quality} upLostRate:${result.upLostRate} downLostRate:${result.downLostRate} rtt:${result.rtt} \n"
            " onSpeedTestResult availableUpBandwidth:${result.availableUpBandwidth} availableDownBandwidth:${result.availableDownBandwidth} upJitter:${result.upJitter} downJitter:${result.downJitter}\n");
      },
      onConnectionLost: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectionLost");
      },
      onTryToReconnect: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onTryToReconnect");
      },
      onConnectionRecovery: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectionRecovery");
      },
      onCameraDidReady: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onCameraDidReady");
      },
      onMicDidReady: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onMicDidReady");
      },
      onUserVoiceVolume: (userVolumes, totalVolume) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVoiceVolume totalVolume:$totalVolume");

        for (TRTCVolumeInfo info in userVolumes) {
          _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVoiceVolume userId:${info.userId} volume:${info.volume}");
        }
      },
      onAudioDeviceCaptureVolumeChanged: (volume, muted) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onAudioDeviceCaptureVolumeChanged volume:$volume muted:$muted");
      },
      onAudioDevicePlayoutVolumeChanged: (volume, muted) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onAudioDevicePlayoutVolumeChanged volume:$volume muted:$muted");
      },
      onSystemAudioLoopbackError: (errCode) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSystemAudioLoopbackError errCode:$errCode");
      },
      onTestMicVolume: (volume) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onTestMicVolume volume:$volume");
      },
      onTestSpeakerVolume: (volume) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onTestSpeakerVolume volume:$volume");
      },
      onRecvCustomCmdMsg: (userId, cmdId, seq, message) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRecvCustomCmdMsg userId:$userId cmdId:$cmdId seq:$seq message:$message");

        MeetingTool.toast(message, context);
      },
      onMissCustomCmdMsg: (userId, cmdId, errCode, missed) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onMissCustomCmdMsg userId:$userId cmdId:$cmdId errCode:$errCode missed:$missed");
      },
      onRecvSEIMsg: (userId, message) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onRecvSEIMsg userId:$userId message:$message");

        MeetingTool.toast(message, context);
      },
      onStartPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStartPublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
      },
      onUpdatePublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onUpdatePublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
      },
      onStopPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStopPublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
      },
      onCdnStreamStateChanged: (cdnUrl, status, errCode, errMsg, extraInfo) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onCdnStreamStateChanged cdnUrl:$cdnUrl status:$status errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
      },
      onScreenCaptureStarted: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureStarted");
      },
      onScreenCapturePaused: (reason) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCapturePaused reason:$reason");
      },
      onScreenCaptureResumed: (reason) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureResumed reason:$reason");
      },
      onScreenCaptureStopped: (reason) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureStopped reason:$reason");
      },
      onScreenCaptureCovered: () {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onScreenCaptureCovered");
      },
      onLocalRecordBegin: (errCode, storagePath) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecordBegin errCode:$errCode storagePath:$storagePath");
      },
      onLocalRecording: (duration, storagePath) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecording duration:$duration storagePath:$storagePath");
      },
      onLocalRecordFragment: (storagePath) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecordingFragment storagePath:$storagePath");
      },
      onLocalRecordComplete: (errCode, storagePath) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onLocalRecordComplete errCode:$errCode storagePath:$storagePath");
      },
      onSnapshotComplete: (userId, type, data, length, width, height, format) {
        _printLog(1, "TRTCCloudExample TRTCCloudListenerparseCallbackParam onSnapshotComplete userId:$userId type:$type data:$data length:$length width:$width height:$height format:$format");
      },
    );
  }


  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _meetModel = context.read<MeetingModel>();
    _initRoom();
  }

  _initRoom() async {
    // Create TRTCCloud singleton
    _trtcCloud = await TRTCCloud.sharedInstance();
    // Tencent Cloud Audio Effect Management Module
    _txDeviceManager = _trtcCloud.getDeviceManager();
    _listener = getListener();
    _trtcCloud.registerListener(_listener);
    // Enter the room
    _enterRoom();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
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
  _enterRoom() {
    try {
      _meetModel.getUserInfo().userSig =
           GenerateTestUserSig.genTestSig(_meetModel.getUserInfo().userId);
    } catch (err) {
      _meetModel.getUserInfo().userSig = '';
      print(err);
    }
    _trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: GenerateTestUserSig.sdkAppId,
            userId: _meetModel.getUserInfo().userId,
            userSig: _meetModel.getUserInfo().userSig ?? '',
            role: TRTCRoleType.anchor,
            roomId: _meetModel.getMeetId()!),
        TRTCAppScene.live);
  }

  _initData() {
    _userList.add(_meetModel.getUserInfo());
    if (_meetModel.getUserInfo().isOpenMic) {
      if (kIsWeb) {
        Future.delayed(Duration(seconds: 3), () {
          _trtcCloud.startLocalAudio(_meetModel.getQuality());
        });
      } else {
        _trtcCloud.startLocalAudio(_meetModel.getQuality());
      }
    }

    _screenUserList = MeetingTool.getScreenList(_userList);

    _meetModel.setList(_userList);
    setState(() {});
  }

  _destroyRoom() {
    _trtcCloud.exitRoom();
    _trtcCloud.unRegisterListener(_listener);
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _destroyRoom();
    super.dispose();
  }

  _handleOnRemoteUserEnterRoom(param) {
    UserModel user = UserModel(userId: param);
    user.type = 'video';
    user.isOpenCamera = false;
    user.size = WidgetSize(width: 0, height: 0);
    _userList.add(user);

    _screenUserList = MeetingTool.getScreenList(_userList);
    this.setState(() {});
    _meetModel.setList(_userList);
  }

  _handleOnRemoteUserLeaveRoom(String userId) {
    for (var i = 0; i < _userList.length; i++) {
      if (_userList[i].userId == userId) {
        _userList.removeAt(i);
      }
    }
    _screenUserList = MeetingTool.getScreenList(_userList);
    this.setState(() {});
    _meetModel.setList(_userList);
  }

  _handleOnUserAudioAvailable(String userId, bool available) {
    for (var i = 0; i < _userList.length; i++) {
      if (_userList[i].userId == userId) {
        _userList[i].isOpenMic = available;
      }
    }
  }

  _handleOnUserVideoAvailable(String userId, bool available)  {
    if (available) {
      for (var i = 0; i < _userList.length; i++) {
        if (_userList[i].userId == userId && _userList[i].type == 'video') {
          _userList[i].isOpenCamera = true;
        }
      }
    } else {
      for (var i = 0; i < _userList.length; i++) {
        if (_userList[i].userId == userId && _userList[i].type == 'video') {
          _trtcCloud.stopRemoteView(
              userId, TRTCVideoStreamType.big);
          _userList[i].isOpenCamera = false;
        }
      }
    }

    _screenUserList = MeetingTool.getScreenList(_userList);
    this.setState(() {});
    _meetModel.setList(_userList);
  }

  _handleOnUserSubStreamAvailable(String userId, bool available) {
    if (available) {
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
              userId, TRTCVideoStreamType.sub);
          _userList.removeAt(i);
        }
      }
    }
    _screenUserList = MeetingTool.getScreenList(_userList);
    _meetModel.setList(_userList);
    this.setState(() {});
  }

  _startShare(int viewId) {
    _trtcCloud.startScreenCapture(
        viewId,
        TRTCVideoStreamType.sub,
        TRTCVideoEncParam(
          videoFps: 10,
          videoResolution: TRTCVideoResolution.res_1280_720,
          videoBitrate: 1600,
          videoResolutionMode: TRTCVideoResolutionMode.portrait,
        ));
  }

  _onShareClick() {
    if (Platform.isAndroid) {
      if (!_meetModel.getUserInfo().isShowingWindow) {
        _startShare(0);
        this.setState(() {
          _meetModel.getUserInfo().isShowingWindow = true;
        });
      } else {
        _trtcCloud.stopScreenCapture();
        this.setState(() {
          _meetModel.getUserInfo().isShowingWindow = false;
        });
      }
    }
  }

  Future<bool?> _showErrorDialog(errorMsg) {
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

  Widget _renderView(UserModel item, valueKey, width, height) {
    if (item.isOpenCamera) {
      return GestureDetector(
          key: valueKey,
          behavior: HitTestBehavior.opaque,
          child: TRTCCloudVideoView(
              key: valueKey,
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              onViewCreated: (viewId) async {
                if (item.userId == _meetModel.getUserInfo().userId) {
                   _trtcCloud.startLocalPreview(
                      _meetModel.getUserInfo().isFrontCamera, viewId);
                  setState(() {
                    _meetModel.getUserInfo().localViewId = viewId;
                  });
                } else {
                  _trtcCloud.startRemoteView(
                      item.userId,
                      item.type == 'video'
                          ? TRTCVideoStreamType.big
                          : TRTCVideoStreamType.sub,
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
                          TXAudioRoute.speakerPhone);
                    } else {
                      _txDeviceManager
                          .setAudioRoute(TXAudioRoute.earpiece);
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

  // Widget _beautySetting() {
  //   return Positioned(
  //     bottom: 80,
  //     child: Offstage(
  //       offstage: _meetModel.getUserInfo().isShowBeauty,
  //       child: Container(
  //         padding: EdgeInsets.all(10),
  //         color: Color.fromRGBO(0, 0, 0, 0.8),
  //         height: 100,
  //         width: MediaQuery.of(context).size.width,
  //         child: Column(
  //           children: [
  //             Row(children: [
  //               Expanded(
  //                 flex: 2,
  //                 child: Slider(
  //                   value: _meetModel.getBeautyInfo()[_beautyType] ?? 0.0,
  //                   min: 0,
  //                   max: 9,
  //                   divisions: 9,
  //                   onChanged: (double value) {
  //                     switch (_beautyType) {
  //                       case BeautyType.smooth:
  //                         _trtcCloud.setBeautyStyle(TRTCBeautyStyle.smooth, value.round(), 0, 0);
  //                         break;
  //                       case BeautyType.nature:
  //                         _trtcCloud.setBeautyStyle(TRTCBeautyStyle.nature, value.round(), 0, 0);
  //                         break;
  //                       case BeautyType.white:
  //                         _trtcCloud.setBeautyStyle(TRTCBeautyStyle.smooth, 0, value.round(), 0);
  //                         break;
  //                       case BeautyType.ruddy:
  //                         _trtcCloud.setBeautyStyle(TRTCBeautyStyle.smooth, 0, 0, value.round());
  //                         break;
  //                       default:
  //                         break;
  //                     }
  //                     this.setState(() {
  //                       _meetModel.getBeautyInfo()[_beautyType] = value;
  //                     });
  //                   },
  //                 ),
  //               ),
  //               Text(_meetModel.getBeautyInfo()[_beautyType]?.round().toString() ?? '0',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(color: Colors.white)),
  //             ]),
  //
  //             Padding(
  //               padding: EdgeInsets.only(top: 10),
  //               child: Row(
  //                 children: [
  //                   GestureDetector(
  //                     child: Container(
  //                       alignment: Alignment.centerLeft,
  //                       width: 80.0,
  //                       child: Text(
  //                         'Smooth',
  //                         style: TextStyle(
  //                             color: _beautyType == BeautyType.smooth
  //                                 ? Color.fromRGBO(64, 158, 255, 1)
  //                                 : Colors.white),
  //                       ),
  //                     ),
  //                     onTap: () => this.setState(() {
  //                       _beautyType = BeautyType.smooth;
  //                       _trtcCloud.setBeautyStyle(TRTCBeautyStyle.smooth,
  //                           _meetModel.getBeautyInfo()[BeautyType.smooth]?.round() ?? 0, 0, 0);
  //                     }),
  //                   ),
  //
  //                   GestureDetector(
  //                     child: Container(
  //                       alignment: Alignment.centerLeft,
  //                       width: 80.0,
  //                       child: Text(
  //                         'Nature',
  //                         style: TextStyle(
  //                             color: _beautyType == BeautyType.nature
  //                                 ? Color.fromRGBO(64, 158, 255, 1)
  //                                 : Colors.white),
  //                       ),
  //                     ),
  //                     onTap: () => this.setState(() {
  //                       _beautyType = BeautyType.nature;
  //                       _trtcCloud.setBeautyStyle(TRTCBeautyStyle.nature,
  //                           _meetModel.getBeautyInfo()[BeautyType.nature]?.round() ?? 0, 0, 0);
  //                     }),
  //                   ),
  //
  //                   GestureDetector(
  //                     child: Container(
  //                       alignment: Alignment.centerLeft,
  //                       width: 80.0,
  //                       child: Text(
  //                         'White',
  //                         style: TextStyle(
  //                             color: _beautyType == BeautyType.white
  //                                 ? Color.fromRGBO(64, 158, 255, 1)
  //                                 : Colors.white),
  //                       ),
  //                     ),
  //                     onTap: () => this.setState(() {
  //                       _beautyType = BeautyType.white;
  //                       _trtcCloud.setBeautyStyle(TRTCBeautyStyle.nature, 0,
  //                           _meetModel.getBeautyInfo()[BeautyType.ruddy]?.round() ?? 0, 0);
  //                     }),
  //                   ),
  //
  //                   GestureDetector(
  //                     child: Container(
  //                       alignment: Alignment.centerLeft,
  //                       width: 50.0,
  //                       child: Text(
  //                         'Ruddy',
  //                         style: TextStyle(
  //                             color: _beautyType == BeautyType.ruddy
  //                                 ? Color.fromRGBO(64, 158, 255, 1)
  //                                 : Colors.white),
  //                       ),
  //                     ),
  //                     onTap: () => this.setState(() {
  //                       _beautyType = BeautyType.ruddy;
  //                       _trtcCloud.setBeautyStyle(TRTCBeautyStyle.nature, 0, 0,
  //                           _meetModel.getBeautyInfo()[BeautyType.white]?.round() ?? 0);
  //                     }),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
            // _beautySetting(),
            _bottomSetting()
          ],
        ),
      ),
    );
  }
}
