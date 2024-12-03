import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:flutter/cupertino.dart';

import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:trtc_demo/models/user_model.dart';
import 'package:trtc_demo/ui/test/api_checker_button.dart';
import 'package:trtc_demo/ui/test/callback_checker.dart';
import 'package:trtc_demo/ui/test/parameter_type.dart';
import 'package:trtc_demo/utils/tool.dart';

typedef VoidFunction = void Function();

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  late UserModel userInfo;
  late MeetingModel meetModel;

  late TRTCCloud trtcCloud;
  late TXDeviceManager txDeviceManager;
  late TXAudioEffectManager txAudioEffectManager;

  String musicPath = "";
  String recordPath = "";

  TRTCCloud? subCloud;

  @override
  void initState() {
    super.initState();
    initRoom();
    initData();
    meetModel = context.read<MeetingModel>();
    userInfo = meetModel.getUserInfo();
  }

  initData() async {
    Directory? appDocDir;
    if(Platform.isAndroid) {
      appDocDir = await getExternalStorageDirectory();
    } else {
      appDocDir = await getApplicationDocumentsDirectory();
    }

    recordPath = '${appDocDir?.path}/isolocalVideo.mp4';

    musicPath = await MeetingTool.copyAssetToLocal('media/daoxiang.mp3');
  }

  initRoom() async {
    trtcCloud = (await TRTCCloud.sharedInstance());

    txDeviceManager = trtcCloud.getDeviceManager();
    txAudioEffectManager = trtcCloud.getAudioEffectManager();

    trtcCloud.setLogCallback(TRTCLogCallback(
        onLog: (String msg, TRTCLogLevel level, String extInfo) {
          CallbackChecker.invokeCheck(msg);
        }
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Test API'),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'TRTCCloud'),
                Tab(text: 'TXDeviceManager'),
                Tab(text: 'TXAudioEffectManager'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _testTRTCCloud(),
              _testTXDevice(),
              _testTXAudioEffect(),
            ],
          ),
        )
    );
  }

  ListView _testTRTCCloud() {
    return ListView(
      children: [
        ApiCheckerButton(
            methodName: "switchRole",
            parameters: [
              Parameter(name: 'role', type: ParameterType.tEnum, value: TRTCRoleType.audience),
            ],
            extString: 'audience',
            callApi: (params) {
              trtcCloud.switchRole(params['role']);
            }
        ),
        ApiCheckerButton(
            methodName: "SwitchRole",
            parameters: [
              Parameter(name: 'role', type: ParameterType.tEnum, value: TRTCRoleType.anchor),
            ],
            extString: 'anchor',
            callApi: (params) {
              trtcCloud.switchRole(params['role']);
            }
        ),
        ApiCheckerButton(
            methodName: "switchRoom",
            parameters: [
              Parameter(
                  name: 'roomId',
                  type: ParameterType.tClass,
                  value: TRTCSwitchRoomConfig(
                      roomId: 666,
                      userSig: GenerateTestUserSig.genTestSig(userInfo.userId),
                  ),
              ),
            ],
            extString: '666',
            callApi: (params) {
              trtcCloud.switchRoom(params['roomId']);
            }
        ),
        ApiCheckerButton(
            methodName: "switchRoom",
            parameters: [
              Parameter(
                name: 'roomId',
                type: ParameterType.tClass,
                value: TRTCSwitchRoomConfig(
                  roomId: meetModel.getMeetId()!,
                  userSig: GenerateTestUserSig.genTestSig(userInfo.userId),
                ),
              ),
            ],
            extString: 'origin',
            callApi: (params) {
              trtcCloud.switchRoom(params['roomId']);
            }
        ),
        ApiCheckerButton(
            methodName: 'connectOtherRoom',
            parameters: [
              Parameter(name: 'param', type: ParameterType.string,
                  value: jsonEncode({
                    'roomId' : 155,
                    'userId' : "345"
                  })),
            ],
            callApi: (params) {
              trtcCloud.connectOtherRoom(params['param']);
            },
        ),
        // ApiCheckerButton(
        //     methodName: 'createSubCloud',
        //     parameters: [],
        //     callApi: (params) {
        //       subCloud ??= trtcCloud.createSubCloud();
        //     }
        // ),
        // ApiCheckerButton(
        //     methodName: 'destroySubCloud',
        //     parameters: [
        //       Parameter(name: 'subCloud', type: ParameterType.tClass, value: subCloud,),
        //     ],
        //     callApi: (params) {
        //       if (params['subCloud'] != null) {
        //         trtcCloud.destroySubCloud(params['subCloud']!);
        //       }
        //     }
        // ),
        ApiCheckerButton(
            methodName: 'disconnectOtherRoom',
            parameters: [],
            callApi: (params) {
              trtcCloud.disconnectOtherRoom();
            }
        ),
        ApiCheckerButton(
            methodName: 'setDefaultStreamRecvMode',
            parameters: [
              Parameter(name: 'autoRecvAudio', type: ParameterType.bool, value: false),
              Parameter(name: 'autoRecvVideo', type: ParameterType.bool, value: false),
            ],
            callApi: (params) {
              trtcCloud.setDefaultStreamRecvMode(params['autoRecvAudio'], params['autoRecvVideo']);
            }
        ),
        ApiCheckerButton(
            methodName: 'startPublishMediaStream',
            parameters: [
              Parameter(name: 'target', type: ParameterType.tClass, value: _getTRTCPublishTarget()),
              Parameter(name: 'param', type: ParameterType.tClass, value: _getTRTCStreamEncoderParam()),
              Parameter(name: 'config', type: ParameterType.tClass, value: _getTRTCStreamMixingConfig()),
            ],
            callApi: (params) {
              trtcCloud.startPublishMediaStream(params['target'], params['param'], params['config']);
            }
        ),
        ApiCheckerButton(
            methodName: 'updatePublishMediaStream',
            parameters: [
              Parameter(name: 'taskId', type: ParameterType.string, value: "888",),
              Parameter(name: 'target', type: ParameterType.tClass, value: _getTRTCPublishTarget()),
              Parameter(name: 'param', type: ParameterType.tClass, value: _getTRTCStreamEncoderParam()),
              Parameter(name: 'config', type: ParameterType.tClass, value: _getTRTCStreamMixingConfig()),
            ],
            callApi: (params) {
              trtcCloud.updatePublishMediaStream(params['taskId'], params['target'], params['param'], params['config']);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopPublishMediaStream',
            parameters: [
              Parameter(name: 'taskId', type: ParameterType.string, value: "888",),
            ],
            callApi: (params) {
              trtcCloud.stopPublishMediaStream(params['taskId']);
            }
        ),
        ApiCheckerButton(
            methodName: 'updateLocalView',
            parameters: [
              Parameter(name: 'viewId', type: ParameterType.int, value: 0,),
            ],
            callApi: (params) {
              trtcCloud.updateLocalView(params['viewId']);
            }
        ),
        ApiCheckerButton(
            methodName: 'muteLocalVideo',
            parameters: [
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
              Parameter(name: 'mute', type: ParameterType.bool, value: true,),
            ],
            extString: 'true',
            callApi: (params) {
              trtcCloud.muteLocalVideo(params['streamType'], params['mute']);
            }
        ),
        ApiCheckerButton(
            methodName: 'muteLocalVideo',
            parameters: [
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
              Parameter(name: 'mute', type: ParameterType.bool, value: false,),
            ],
            extString: 'false',
            callApi: (params) {
              trtcCloud.muteLocalVideo(params['streamType'], params['mute']);
            }
        ),
        // ApiCheckerButton(
        //     methodName: 'setVideoMuteImage',
        //     token: 'setMuteImage',
        //     parameters: [
        //       Parameter(name: 'image', type: ParameterType.tClass, value: TRTCImageBuffer(),),
        //       Parameter(name: 'fps', type: ParameterType.int, value: 5,),
        //     ],
        //     callApi: (params) {
        //       trtcCloud.setVideoMuteImage(params['image'], params['fps']);
        //     }
        // ),
        ApiCheckerButton(
            methodName: 'updateRemoteView',
            parameters: [
              Parameter(name: 'userId', type: ParameterType.string, value: 'value'),
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
              Parameter(name: 'viewId', type: ParameterType.int, value: 0,),
            ],
            callApi: (params) {
              trtcCloud.updateRemoteView(params['userId'], params['streamType'], params['viewId']);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopAllRemoteView',
            parameters: [],
            callApi: (params) {
              trtcCloud.stopAllRemoteView();
            }
        ),
        ApiCheckerButton(
            methodName: 'muteRemoteVideoStream',
            token: 'MuteRemoteVideo',
            parameters: [
              Parameter(name: 'userId', type: ParameterType.string, value: 'value'),
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
              Parameter(name: 'mute', type: ParameterType.bool, value: false,),
            ],
            callApi: (params) {
              trtcCloud.muteRemoteVideoStream(params['userId'], params['streamType'], params['mute']);
            }
        ),
        ApiCheckerButton(
            methodName: 'muteAllRemoteVideoStreams',
            token: 'MuteAllRemoteVideo',
            parameters: [
              Parameter(name: 'mute', type: ParameterType.bool, value: true,),
            ],
            callApi: (params) {
              trtcCloud.muteAllRemoteVideoStreams(params['mute']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setVideoEncoderParam',
            token: 'SetVideoEncodeParams',
            parameters: [
              Parameter(name: 'params', type: ParameterType.tClass,
                value: TRTCVideoEncParam(
                  videoBitrate: 1000,
                  videoResolution: TRTCVideoResolution.res_1920_1080,
                  videoResolutionMode: TRTCVideoResolutionMode.landscape,
                  videoFps: 15,
                  minVideoBitrate: 10,
                  enableAdjustRes: false,
                ),),
            ],
            callApi: (params) {
              trtcCloud.setVideoEncoderParam(params['params']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setNetworkQosParam',
            token: 'SetQosConfigParams',
            parameters: [
              Parameter(name: 'params', type: ParameterType.tClass,
                value: TRTCNetworkQosParam(
                  preference: TRTCVideoQosPreference.smooth,
                ),),
            ],
            callApi: (params) {
              trtcCloud.setNetworkQosParam(params['params']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setLocalRenderParams',
            parameters: [
              Parameter(name: 'params', type: ParameterType.tClass,
                value: TRTCRenderParams(
                  rotation: TRTCVideoRotation.rotation0,
                  fillMode: TRTCVideoFillMode.fit,
                  mirrorType: TRTCVideoMirrorType.enable,
                ),),
            ],
            callApi: (params) {
              trtcCloud.setLocalRenderParams(params['params']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setRemoteRenderParams',
            parameters: [
              Parameter(name: 'userId', type: ParameterType.string, value: 'value'),
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
              Parameter(name: 'params', type: ParameterType.tClass, value: TRTCRenderParams(),),
            ],
            callApi: (params) {
              trtcCloud.setRemoteRenderParams(params['userId'], params['streamType'], params['params']);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableSmallVideoStream',
            token: 'SetVideoEncodeParams',
            parameters: [
              Parameter(name: 'enable', type: ParameterType.bool, value: true,),
              Parameter(name: 'smallVideoEncParam', type: ParameterType.tClass,
                value: TRTCVideoEncParam(
                  videoBitrate: 1000,
                  videoResolution: TRTCVideoResolution.res_320_240,
                  videoResolutionMode: TRTCVideoResolutionMode.portrait,
                  videoFps: 15,
                  minVideoBitrate: 103,
                  enableAdjustRes: false,
                ),),
            ],
            callApi: (params) {
              trtcCloud.enableSmallVideoStream(params['enable'], params['smallVideoEncParam']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setRemoteVideoStreamType',
            parameters: [
              Parameter(name: 'userId', type: ParameterType.string, value: 'value'),
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
            ],
            callApi: (params) {
              trtcCloud.setRemoteVideoStreamType(params['userId'], params['streamType']);
            }
        ),
        ApiCheckerButton(
            methodName: 'snapshotVideo',
            parameters: [
              Parameter(name: 'userId', type: ParameterType.string, value: 'value'),
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
              Parameter(name: 'sourceType', type: ParameterType.tEnum, value: TRTCSnapshotSourceType.stream),
            ],
            callApi: (params) {
              trtcCloud.snapshotVideo(params['userId'], params['streamType'], params['sourceType']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setGravitySensorAdaptiveMode',
            parameters: [
              Parameter(name: 'mode', type: ParameterType.tEnum, value: TRTCGSensorMode.uiAutoLayout),
            ],
            callApi: (params) {
              trtcCloud.setGravitySensorAdaptiveMode(params['mode']);
            }
        ),
        ApiCheckerButton(
            methodName: 'startLocalAudio',
            parameters: [
              Parameter(name: 'quality', type: ParameterType.tEnum, value: TRTCAudioQuality.music,),
            ],
            callApi: (params) {
              trtcCloud.startLocalAudio(params['quality']);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopLocalAudio',
            parameters: [],
            callApi: (params) {
              trtcCloud.stopLocalAudio();
            }
        ),
        ApiCheckerButton(
            methodName: 'muteLocalAudio',
            parameters: [
              Parameter(name: 'enable', type: ParameterType.bool, value: true,),
            ],
            extString: 'true',
            callApi: (params) {
              trtcCloud.muteLocalAudio(params['enable']);
            }
        ),
        ApiCheckerButton(
            methodName: 'muteLocalAudio',
            parameters: [
              Parameter(name: 'enable', type: ParameterType.bool, value: false,),
            ],
            extString: 'false',
            callApi: (params) {
              trtcCloud.muteLocalAudio(params['enable']);
            }
        ),
        ApiCheckerButton(
            methodName: 'muteRemoteAudio',
            parameters: [
              Parameter(name: 'userId', type: ParameterType.string, value: 'value'),
              Parameter(name: 'enable', type: ParameterType.bool, value: false,),
            ],
            callApi: (params) {
              trtcCloud.muteRemoteAudio(params['userId'], params['enable']);
            }
        ),
        ApiCheckerButton(
            methodName: 'muteAllRemoteAudio',
            parameters: [
              Parameter(name: 'enable', type: ParameterType.bool, value: false,),
            ],
            callApi: (params) {
              trtcCloud.muteAllRemoteAudio(params['enable']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setRemoteAudioVolume',
            parameters: [
              Parameter(name: 'userId', type: ParameterType.string, value: 'value',),
              Parameter(name: 'volume', type: ParameterType.int, value: 70,),
            ],
            callApi: (params) {
              trtcCloud.setRemoteAudioVolume(params['userId'], params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setAudioCaptureVolume',
            parameters: [
              Parameter(name: 'volume', type: ParameterType.int, value: 80,),
            ],
            callApi: (params) {
              trtcCloud.setAudioCaptureVolume(params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'getAudioCaptureVolume',
            parameters: [],
            callApi: (params) {
              int result = trtcCloud.getAudioCaptureVolume();
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setAudioPlayoutVolume',
            parameters: [
              Parameter(name: 'volume', type: ParameterType.int, value: 60,),
            ],
            callApi: (params) {
              trtcCloud.setAudioPlayoutVolume(params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'getAudioPlayoutVolume',
            parameters: [],
            callApi: (params) {
              int result = trtcCloud.getAudioPlayoutVolume();
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableAudioVolumeEvaluation',
            parameters: [
              Parameter(name: 'enable', type: ParameterType.bool, value: false,),
              Parameter(name: 'params', type: ParameterType.tClass,
                value: TRTCAudioVolumeEvaluateParams(
                  enablePitchCalculation: true,
                  enableSpectrumCalculation: false,
                  enableVadDetection: true,
                  interval: 1200,
                ),
              ),
            ],
            callApi: (params) {
              trtcCloud.enableAudioVolumeEvaluation(params['enable'], params['params']);
            }
        ),
        ApiCheckerButton(
            methodName: 'startLocalRecording',
            parameters: [
              Parameter(name: 'param', type: ParameterType.tClass,
                value: TRTCLocalRecordingParams(
                  filePath: recordPath,
                  recordType: TRTCLocalRecordType.both,
                  interval: 10000,
                  maxDurationPerFile: 100000,
                ),),
            ],
            callApi: (params) {
              int result = trtcCloud.startLocalRecording(params['param']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopLocalRecording',
            parameters: [],
            callApi: (params) {
              trtcCloud.stopLocalRecording();
            },
        ),
        // ApiCheckerButton(
        //     methodName: 'setWatermark',
        //     parameters: [
        //       Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
        //       Parameter(name: 'srcData', type: ParameterType.string, value: 'images/watermark_img.png'),
        //       Parameter(name: 'srcType', type: ParameterType.tEnum, value: TRTCWaterMarkSrcType.file),
        //       Parameter(name: 'width', type: ParameterType.int, value: 100),
        //       Parameter(name: 'height', type: ParameterType.int, value: 100),
        //       Parameter(name: 'xOffset', type: ParameterType.double, value: 0.5),
        //       Parameter(name: 'yOffset', type: ParameterType.double, value: 0.5),
        //       Parameter(name: 'fWidthRatio', type: ParameterType.double, value: 0.9),
        //     ],
        //     callApi: (params) {
        //       trtcCloud.setWaterMark(params['streamType'], params['srcData'],
        //           params['srcType'], params['width'], params['height'],
        //           params['xOffset'], params['yOffset'], params['fWidthRatio']);
        //     }
        // ),
        ApiCheckerButton(
            methodName: 'startSystemAudioLoopback',
            parameters: [],
            callApi: (params) {
              trtcCloud.startSystemAudioLoopback();
            }
        ),
        ApiCheckerButton(
            methodName: 'setSystemAudioLoopbackVolume',
            parameters: [
              Parameter(name: 'volume', type: ParameterType.int, value: 50),
            ],
            callApi: (params) {
              trtcCloud.setSystemAudioLoopbackVolume(params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'startScreenCapture',
            parameters: [
              Parameter(name: 'viewId', type: ParameterType.int, value: 0),
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.sub),
              Parameter(name: 'encParam', type: ParameterType.tClass, value: TRTCVideoEncParam()),
            ],
            callApi: (params) {
              trtcCloud.startScreenCapture(params['viewId'], params['streamType'], params['encParam']);
            }
        ),
        ApiCheckerButton(
            methodName: 'pauseScreenCapture',
            parameters: [],
            callApi: (params) {
              trtcCloud.pauseScreenCapture();
            }
        ),
        ApiCheckerButton(
            methodName: 'resumeScreenCapture',
            parameters: [],
            callApi: (params) {
              trtcCloud.resumeScreenCapture();
            }
        ),
        ApiCheckerButton(
            methodName: 'stopScreenCapture',
            parameters: [],
            callApi: (params) {
              trtcCloud.stopScreenCapture();
            }
        ),
        ApiCheckerButton(
            methodName: 'getScreenCaptureSources',
            parameters: [
              Parameter(name: 'thumbnail', type: ParameterType.tClass, value: TRTCSize()),
              Parameter(name: 'icon', type: ParameterType.tClass, value: TRTCSize()),
            ],
            callApi: (params) {
              TRTCScreenCaptureSourceList? list = trtcCloud.getScreenCaptureSources(params['thumbnail'], params['icon']);
              if (list != null) {
                _showList(list.sourceList);
              }
            }
        ),
        ApiCheckerButton(
            methodName: 'selectScreenCaptureTarget',
            parameters: [
              Parameter(name: 'source', type: ParameterType.tClass, value: TRTCScreenCaptureSourceInfo()),
              Parameter(name: 'rect', type: ParameterType.tClass, value: TRTCRect()),
              Parameter(name: 'property', type: ParameterType.tClass, value: TRTCScreenCaptureProperty()),
            ],
            callApi: (params) {
              trtcCloud.selectScreenCaptureTarget(params['source'], params['rect'], params['property']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setSubStreamEncoderParam',
            token: 'SetVideoEncodeParams',
            parameters: [
              Parameter(name: 'param', type: ParameterType.tClass,
                  value: TRTCVideoEncParam(
                    videoBitrate: 1000,
                    videoResolution: TRTCVideoResolution.res_256_144,
                    videoResolutionMode: TRTCVideoResolutionMode.landscape,
                    videoFps: 12,
                    minVideoBitrate: 10,
                    enableAdjustRes: true,
                  )),
            ],
            callApi: (params) {
              trtcCloud.setSubStreamEncoderParam(params['param']);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableCustomVideoCapture',
            parameters: [
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.sub),
              Parameter(name: 'enable', type: ParameterType.bool, value: false),
            ],
            callApi: (params) {
              trtcCloud.enableCustomVideoCapture(params['streamType'], params['enable']);
            }
        ),
        ApiCheckerButton(
            methodName: 'sendCustomVideoData',
            parameters: [
              Parameter(name: 'streamType', type: ParameterType.tEnum, value: TRTCVideoStreamType.big),
              Parameter(name: 'frame', type: ParameterType.tClass, value: TRTCVideoFrame()),
            ],
            callApi: (params) {
              trtcCloud.sendCustomVideoData(params['streamType'], params['frame']);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableCustomAudioCapture',
            parameters: [
              Parameter(name: 'enable', type: ParameterType.bool, value: true),
            ],
            callApi: (params) {
              trtcCloud.enableCustomAudioCapture(params['enable']);
            }
        ),
        ApiCheckerButton(
            methodName: 'sendCustomAudioData',
            parameters: [
              Parameter(name: 'frame', type: ParameterType.tClass,
                  value: TRTCAudioFrame(length: 3,data: Uint8List.fromList([123,1231,321]))
              ),
            ],
            callApi: (params) {
              trtcCloud.sendCustomAudioData(params['frame']);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableMixExternalAudioFrame',
            parameters: [
              Parameter(name: 'enablePublish', type: ParameterType.bool, value: true),
              Parameter(name: 'enablePlayout', type: ParameterType.bool, value: false),
            ],
            callApi: (params) {
              trtcCloud.enableMixExternalAudioFrame(params['enablePublish'], params['enablePlayout']);
            }
        ),
        // ApiCheckerButton(
        //     methodName: 'enableLocalVideoCustomProcess',
        //     token: 'EnableVideoCustomPreprocess',
        //     parameters: [
        //       Parameter(name: 'enable', type: ParameterType.bool, value: true),
        //       Parameter(name: 'format', type: ParameterType.tEnum, value: TRTCVideoPixelFormat.unknown),
        //       Parameter(name: 'type', type: ParameterType.tEnum, value: TRTCVideoBufferType.unknown),
        //     ],
        //     callApi: (params) {
        //       trtcCloud.enableLocalVideoCustomProcess(params['enable'], params['format'], params['type']);
        //     }
        // ),
        // ApiCheckerButton(
        //     methodName: 'setLocalVideoCustomProcessCallback',
        //     parameters: [],
        //     callApi: (params) {
        //       trtcCloud.setLocalVideoCustomProcessCallback(null);
        //     }
        // ),
        // ApiCheckerButton(
        //     methodName: 'setLocalVideoRenderCallback',
        //     parameters: [
        //       Parameter(name: 'format', type: ParameterType.tEnum, value: TRTCVideoPixelFormat.unknown),
        //       Parameter(name: 'type', type: ParameterType.tEnum, value: TRTCVideoBufferType.unknown),
        //     ],
        //     callApi: (params) {
        //       int result = trtcCloud.setLocalVideoRenderCallback(params['format'], params['type'], null);
        //       MeetingTool.toast(result.toString(), context);
        //     }
        // ),
        // ApiCheckerButton(
        //     methodName: 'setRemoteVideoRenderCallback',
        //     parameters: [
        //       Parameter(name: 'userId', type: ParameterType.string, value: '123'),
        //       Parameter(name: 'format', type: ParameterType.tEnum, value: TRTCVideoPixelFormat.unknown),
        //       Parameter(name: 'type', type: ParameterType.tEnum, value: TRTCVideoBufferType.unknown),
        //     ],
        //     callApi: (params) {
        //       int result = trtcCloud.setRemoteVideoRenderCallback(params['userId'], params['format'], params['type'], null);
        //       MeetingTool.toast(result.toString(), context);
        //     }
        // ),
        // ApiCheckerButton(
        //     methodName: 'setAudioFrameCallback',
        //     parameters: [],
        //     callApi: (params) {
        //       int result = trtcCloud.setAudioFrameCallback(
        //           TRTCAudioFrameCallback(
        //               onCapturedAudioFrame: (frame) {
        //                 debugPrint("onCapturedAudioFrame frame: ${frame.data.length}");
        //                 String hexString = frame.data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        //                 debugPrint("onCapturedAudioFrame framedata: $hexString");
        //               },
        //               onLocalProcessedAudioFrame: (frame) {
        //
        //               },
        //               onPlayAudioFrame: (frame, userId) {
        //
        //               },
        //               onMixedPlayAudioFrame: (frame) {
        //
        //               },
        //               onMixedAllAudioFrame: (frame) {
        //                 debugPrint("onMixedAllAudioFrame frame: ${frame.data.length}");
        //                 String hexString = frame.data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        //                 debugPrint("onMixedAllAudioFrame framedata: $hexString");
        //               }
        //           ));
        //       MeetingTool.toast(result.toString(), context);
        //     }
        // ),
        ApiCheckerButton(
            methodName: 'sendCustomCmdMsg',
            parameters: [
              Parameter(name: 'cmdID', type: ParameterType.int, value: 0),
              Parameter(name: 'data', type: ParameterType.string, value: '123'),
              Parameter(name: 'reliable', type: ParameterType.bool, value: false),
              Parameter(name: 'ordered', type: ParameterType.bool, value: false),
            ],
            callApi: (params) {
              bool result = trtcCloud.sendCustomCmdMsg(params['cmdID'], params['data'], params['reliable'], params['ordered']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'sendSEIMsg',
            parameters: [
              Parameter(name: 'data', type: ParameterType.string, value: '123'),
              Parameter(name: 'repeatCount', type: ParameterType.int, value: 1),
            ],
            callApi: (params) {
              bool result = trtcCloud.sendSEIMsg(params['data'], params['repeatCount']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'startSpeedTest',
            parameters: [
              Parameter(name: 'params', type: ParameterType.tClass,
                  value: TRTCSpeedTestParams(
                    sdkAppId: GenerateTestUserSig.sdkAppId,
                    userId: "5555",
                    userSig: GenerateTestUserSig.genTestSig("5555"),
                    scene: TRTCSpeedTestScene.delayAndBandwidthTesting,
                    expectedDownBandwidth: 500,
                    expectedUpBandwidth: 500,
                  )),
            ],
            callApi: (params) {
              int result = trtcCloud.startSpeedTest(params['params']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopSpeedTest',
            parameters: [],
            callApi: (params) {
              trtcCloud.stopSpeedTest();
            }
        ),
        ApiCheckerButton(
            methodName: 'getSDKVersion',
            parameters: [],
            callApi: (params) {
              String version = trtcCloud.getSDKVersion();
              MeetingTool.toast(version, context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setLogLevel',
            parameters: [
              Parameter(name: 'level', type: ParameterType.tEnum, value: TRTCLogLevel.none),
            ],
            callApi: (params) {
              trtcCloud.setLogLevel(params['level']);
            }
        ),

        ApiCheckerButton(
            methodName: 'showDebugView',
            parameters: [],
            callApi: (params) {
              trtcCloud.showDebugView(1);
            }
        ),

        ApiCheckerButton(
            methodName: 'callExperimentalAPI',
            parameters: [],
            callApi: (params) {
              trtcCloud.callExperimentalAPI(jsonEncode({"api":"enablePictureInPictureFloatingWindow",
              "params":{"enable": true}}));
             }
        ),
      ],
    );
  }

  ListView _testTXAudioEffect() {
    return ListView(
      children: [
        ApiCheckerButton(
            methodName: 'enableVoiceEarMonitor',
            parameters: [
              Parameter(name: 'enable', type: ParameterType.bool, value: true),
            ],
            callApi: (params) {
              txAudioEffectManager.enableVoiceEarMonitor(params['enable']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setVoiceEarMonitorVolume',
            parameters: [
              Parameter(name: 'volume', type: ParameterType.int, value: 60),
            ],
            callApi: (params) {
              txAudioEffectManager.setVoiceEarMonitorVolume(params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setVoiceReverbType',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXVoiceReverbType.type3),
            ],
            callApi: (params) {
              txAudioEffectManager.setVoiceReverbType(params['type']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setVoiceChangerType',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXVoiceChangerType.type1),
            ],
            callApi: (params) {
              txAudioEffectManager.setVoiceChangerType(params['type']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setVoiceCaptureVolume',
            parameters: [
              Parameter(name: 'volume', type: ParameterType.int, value: 60),
            ],
            callApi: (params) {
              txAudioEffectManager.setVoiceCaptureVolume(params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setVoicePitch',
            parameters: [
              Parameter(name: 'pitch', type: ParameterType.double, value: 0.5),
            ],
            callApi: (params) {
              txAudioEffectManager.setVoicePitch(params['pitch']);
            }
        ),
        ApiCheckerButton(
            methodName: 'startPlayMusic',
            parameters: [],
            callApi: (params) {
              txAudioEffectManager.setMusicObserver(1,TXMusicPlayObserver(onStart: (int id, int errorCode){
                  debugPrint("TRTCCloudExample TXMusicPlayObserver onStart id:${id} , errCode:${errorCode}");
              } ,onPlayProgress: (int id, int curPtsMSm, int durationMS){
                  debugPrint("TRTCCloudExample TXMusicPlayObserver onPlayProgress id:${id} , curPtsMSm:${curPtsMSm} , durationMS:${durationMS}");
              }, onComplete: (int id, int errorCode){
                  debugPrint("TRTCCloudExample TXMusicPlayObserver onComplete id:${id} , errCode:${errorCode}");
              }) );
              print("TRTCCloudExample ------------------------ ${musicPath}");
              txAudioEffectManager.startPlayMusic(AudioMusicParam(
                  id: 1,
                  path: musicPath));
            }
        ),
        ApiCheckerButton(
            methodName: 'pausePlayMusic',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
            ],
            callApi: (params) {
              txAudioEffectManager.pausePlayMusic(params['id']);
            }
        ),
        ApiCheckerButton(
            methodName: 'resumePlayMusic',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
            ],
            callApi: (params) {
              txAudioEffectManager.resumePlayMusic(params['id']);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopPlayMusic',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
            ],
            callApi: (params) {
              txAudioEffectManager.stopPlayMusic(params['id']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setAllMusicVolume',
            parameters: [
              Parameter(name: 'volume', type: ParameterType.int, value: 100),
            ],
            callApi: (params) {
              txAudioEffectManager.setAllMusicVolume(params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setMusicPublishVolume',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
              Parameter(name: 'volume', type: ParameterType.int, value: 100),
            ],
            callApi: (params) {
              txAudioEffectManager.setMusicPublishVolume(params['id'], params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setMusicPlayoutVolume',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
              Parameter(name: 'volume', type: ParameterType.int, value: 100),
            ],
            callApi: (params) {
              txAudioEffectManager.setMusicPlayoutVolume(params['id'], params['volume']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setMusicPitch',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
              Parameter(name: 'pitch', type: ParameterType.double, value: 0.5),
            ],
            callApi: (params) {
              txAudioEffectManager.setMusicPitch(params['id'], params['pitch']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setMusicSpeedRate',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
              Parameter(name: 'rate', type: ParameterType.double, value: 0.5),
            ],
            callApi: (params) {
              txAudioEffectManager.setMusicSpeedRate(params['id'], params['rate']);
            }
        ),
        ApiCheckerButton(
            methodName: 'getMusicCurrentPosInMS',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
            ],
            callApi: (params) {
              int result = txAudioEffectManager.getMusicCurrentPosInMS(params['id']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'getMusicDurationInMS',
            parameters: [
              Parameter(name: 'path', type: ParameterType.string, value: musicPath),
            ],
            callApi: (params) {
              int result = txAudioEffectManager.getMusicDurationInMS(params['path']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'seekMusicToPosInTime',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
              Parameter(name: 'pts', type: ParameterType.int, value: 1000),
            ],
            callApi: (params) {
              txAudioEffectManager.seekMusicToPosInTime(params['id'], params['pts']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setMusicScratchSpeedRate',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
              Parameter(name: 'scratchSpeedRate', type: ParameterType.double, value: 0.5),
            ],
            callApi: (params) {
              txAudioEffectManager.setMusicScratchSpeedRate(params['id'], params['scratchSpeedRate']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setPreloadObserver',
            parameters: [],
            callApi: (params) {
              txAudioEffectManager.setPreloadObserver(
                  TXMusicPreloadObserver(
                      onLoadProgress: (id, progress) {
                        debugPrint("TXMusicPreloadObserver onLoadProgress id:${id} , progress:${progress}");
                      },
                      onLoadError: (id, errCode) {
                        debugPrint("TXMusicPreloadObserver onLoadError id:${id} , errCode:${errCode}");
                      },
                  ));
            }
        ),
        ApiCheckerButton(
            methodName: 'preloadMusic',
            parameters: [],
            callApi: (params) {
              txAudioEffectManager.setPreloadObserver(TXMusicPreloadObserver(onLoadProgress: (int id, int progress){
                  debugPrint("TRTCCloudExample TXMusicPreloadObserver onLoadProgress id:${id} , progress:${progress}");
              }, onLoadError: (int id, int progress){
                  debugPrint("TRTCCloudExample TXMusicPreloadObserver onLoadError id:${id} , errCode:${progress}");
              }));
              txAudioEffectManager.preloadMusic(AudioMusicParam(
                  id: 1,
                  path: musicPath));
            }
        ),
        ApiCheckerButton(
            methodName: 'getMusicTrackCount',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
            ],
            callApi: (params) {
              int result = txAudioEffectManager.getMusicTrackCount(params['id']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setMusicTrack',
            parameters: [
              Parameter(name: 'id', type: ParameterType.int, value: 1),
              Parameter(name: 'track', type: ParameterType.int, value: 1),
            ],
            callApi: (params) {
              txAudioEffectManager.setMusicTrack(params['id'], params['track']);
            }
        ),
      ],
    );
  }

  ListView _testTXDevice() {
    return ListView(
      children: [
        ApiCheckerButton(
            methodName: 'isFrontCamera',
            parameters: [],
            callApi: (params) {
              bool isFront = txDeviceManager.isFrontCamera();
              MeetingTool.toast(isFront.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'switchCamera',
            parameters: [
              Parameter(name: 'frontCamera', type: ParameterType.bool, value: true),
            ],
            callApi: (params) {
              txDeviceManager.switchCamera(params['frontCamera']);
            }
        ),
        ApiCheckerButton(
            methodName: 'getCameraZoomMaxRatio',
            parameters: [],
            callApi: (params) {
              double result = txDeviceManager.getCameraZoomMaxRatio();
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setCameraZoomRatio',
            parameters: [
              Parameter(name: 'ratio', type: ParameterType.double, value: 0.5),
            ],
            callApi: (params) {
              int result = txDeviceManager.setCameraZoomRatio(params['ratio']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'isAutoFocusEnabled',
            parameters: [],
            callApi: (params) {
              bool result = txDeviceManager.isAutoFocusEnabled();
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableCameraAutoFocus',
            parameters: [
              Parameter(name: 'enabled', type: ParameterType.bool, value: true),
            ],
            callApi: (params) {
              int result = txDeviceManager.enableCameraAutoFocus(params['enabled']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setCameraFocusPosition',
            parameters: [
              Parameter(name: 'x', type: ParameterType.double, value: 0.5),
              Parameter(name: 'y', type: ParameterType.double, value: 0.5),
            ],
            callApi: (params) {
              int result = txDeviceManager.setCameraFocusPosition(params['x'], params['y']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableCameraTorch',
            parameters: [
              Parameter(name: 'enabled', type: ParameterType.bool, value: true),
            ],
            callApi: (params) {
              int result = txDeviceManager.enableCameraTorch(params['enabled']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setAudioRoute',
            parameters: [
              Parameter(name: 'route', type: ParameterType.tEnum, value: TXAudioRoute.earpiece),
            ],
            extString: 'earpiece',
            callApi: (params) {
              int result = txDeviceManager.setAudioRoute(params['route']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setAudioRoute',
            parameters: [
              Parameter(name: 'route', type: ParameterType.tEnum, value: TXAudioRoute.speakerPhone),
            ],
            extString: 'speakerPhone',
            callApi: (params) {
              int result = txDeviceManager.setAudioRoute(params['route']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'getDevicesList',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
            ],
            callApi: (params) {
              List<TXDeviceInfo> list = txDeviceManager.getDevicesList(params['type']);
              _showList(list);
            }
        ),
        ApiCheckerButton(
            methodName: 'setCurrentDevice',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
              Parameter(name: 'deviceId', type: ParameterType.string, value: '123'),
            ],
            callApi: (params) {
              int result = txDeviceManager.setCurrentDevice(params['type'], params['deviceId']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'getCurrentDevice',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
            ],
            callApi: (params) {
              TXDeviceInfo result = txDeviceManager.getCurrentDevice(params['type']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setCurrentDeviceVolume',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
              Parameter(name: 'volume', type: ParameterType.int, value: 100),
            ],
            callApi: (params) {
              int result = txDeviceManager.setCurrentDeviceVolume(params['type'], params['volume']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'getCurrentDeviceVolume',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
            ],
            callApi: (params) {
              int result = txDeviceManager.getCurrentDeviceVolume(params['type']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setCurrentDeviceMute',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
              Parameter(name: 'mute', type: ParameterType.bool, value: true),
            ],
            callApi: (params) {
              int result = txDeviceManager.setCurrentDeviceMute(params['type'], params['mute']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'getCurrentDeviceMute',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
            ],
            callApi: (params) {
              bool result = txDeviceManager.getCurrentDeviceMute(params['type']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'enableFollowingDefaultAudioDevice',
            parameters: [
              Parameter(name: 'type', type: ParameterType.tEnum, value: TXMediaDeviceType.camera),
              Parameter(name: 'enable', type: ParameterType.bool, value: true),
            ],
            callApi: (params) {
              int result = txDeviceManager.enableFollowingDefaultAudioDevice(params['type'], params['enable']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'startCameraDeviceTest',
            parameters: [
              Parameter(name: 'viewId', type: ParameterType.int, value: 0),
            ],
            callApi: (params) {
              int result = txDeviceManager.startCameraDeviceTest(params['viewId']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopCameraDeviceTest',
            parameters: [],
            callApi: (params) {
              txDeviceManager.stopCameraDeviceTest();
            }
        ),
        ApiCheckerButton(
            methodName: 'startMicDeviceTest',
            parameters: [
              Parameter(name: 'interval', type: ParameterType.int, value: 10),
            ],
            callApi: (params) {
              int result = txDeviceManager.startMicDeviceTest(params['interval']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'startMicDeviceTest',
            parameters: [
              Parameter(name: 'interval', type: ParameterType.int, value: 10),
              Parameter(name: 'playback', type: ParameterType.bool, value: false)
            ],
            callApi: (params) {
              int result = txDeviceManager.startMicDeviceTestAndPlayback(params['interval'], params['playback']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopMicDeviceTest',
            parameters: [],
            callApi: (params) {
              txDeviceManager.stopMicDeviceTest();
            }
        ),
        ApiCheckerButton(
            methodName: 'startSpeakerDeviceTest',
            parameters: [
              Parameter(name: 'filePath', type: ParameterType.string, value: ''),
            ],
            callApi: (params) {
              int result = txDeviceManager.startSpeakerDeviceTest(params['filePath']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'stopSpeakerDeviceTest',
            parameters: [],
            callApi: (params) {
              txDeviceManager.stopSpeakerDeviceTest();
            }
        ),
        ApiCheckerButton(
            methodName: 'setApplicationPlayVolume',
            parameters: [
              Parameter(name: 'volume', type: ParameterType.int, value: 100),
            ],
            callApi: (params) {
              int result = txDeviceManager.setApplicationPlayVolume(params['volume']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'getApplicationPlayVolume',
            parameters: [],
            callApi: (params) {
              int result = txDeviceManager.getApplicationPlayVolume();
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setApplicationMuteState',
            parameters: [
              Parameter(name: 'mute', type: ParameterType.bool, value: false),
            ],
            callApi: (params) {
              int result = txDeviceManager.setApplicationMuteState(params['mute']);
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'getApplicationMuteState',
            parameters: [],
            callApi: (params) {
              int result = txDeviceManager.getApplicationMuteState();
              MeetingTool.toast(result.toString(), context);
            }
        ),
        ApiCheckerButton(
            methodName: 'setCameraCaptureParam',
            parameters: [
              Parameter(name: 'param', type: ParameterType.tClass, value: TXCameraCaptureParam()),
            ],
            callApi: (params) {
              txDeviceManager.setCameraCaptureParam(params['param']);
            }
        ),
        ApiCheckerButton(
            methodName: 'setDeviceObserver',
            parameters: [],
            callApi: (params) {
              txDeviceManager.setDeviceObserver(null);
            }
        ),
      ]
    );
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
    target.mode = TRTCPublishMode.mixStreamToRoom;
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
        TRTCRect(left: 1, top: 2, right: 3, bottom: 4);
    layout.zOrder = 5555;
    layout.fillMode = TRTCVideoFillMode.fit;
    layout.backgroundColor = 6666;
    layout.placeHolderImage = Uint8List.fromList([1, 2, 3, 4]);
    layout.fixedVideoUser = mixStreamIdentity;
    layout.fixedVideoStreamType = TRTCVideoStreamType.sub;

    TRTCWatermark watermark = TRTCWatermark();
    watermark.watermarkUrl = 'www.11111.com';
    watermark.rect = TRTCRect(left: 1, top: 2, right: 3, bottom: 4);
    watermark.zOrder = 8888;

    TRTCStreamMixingConfig config = TRTCStreamMixingConfig();
    config.backgroundColor = 111111;
    config.backgroundImage = Uint8List.fromList([1, 2, 3, 4]);
    config.videoLayoutList = [layout, layout];
    config.audioMixUserList = [mixStreamIdentity, mixStreamIdentity];
    config.watermarkList = [watermark, watermark];
    return config;
  }

  _showList(List list) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Current Parameters'),
          content: SingleChildScrollView(
            child: ListBody(
              children: list.map((source) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    source.toString(), // 将每个源转换为字符串
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}