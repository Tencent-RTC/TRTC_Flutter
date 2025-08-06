import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Common/TXUpdateEvent.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:trtc_api_example/generated/l10n.dart';

///  LocalRecordPage.dart
///  TRTC-API-Example-Dart
class LocalRecordPage extends StatefulWidget {
  const LocalRecordPage({Key? key}) : super(key: key);

  @override
  _LocalRecordPageState createState() => _LocalRecordPageState();
}

class _LocalRecordPageState extends State<LocalRecordPage> {
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  late TXAudioEffectManager audioEffectManager;
  int? localViewId;
  bool isStartPush = false;
  bool isStartRecord = false;
  DateTime now = DateTime.now(); //Get the current time
  String recordFileName =
      "TRTC_" + DateFormat("yyMMddHHmmss").format(DateTime.now()) + ".mp4";
  int roomId = int.parse(TXHelper.generateRandomStrRoomId());
  String userId = TXHelper.generateRandomUserId();
  Map<String, String> remoteUidSet = {};

  @override
  void initState() {
    initTRTCCloud();
    super.initState();
    eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
    _requestPermission();
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    showToast(info);
  }

  initTRTCCloud() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    audioEffectManager = trtcCloud.getAudioEffectManager();
  }

  startPushStream() async {
    trtcCloud.startLocalPreview(true, localViewId!);
    TRTCParams params = new TRTCParams();
    params.sdkAppId = GenerateTestUserSig.sdkAppId;
    params.roomId = this.roomId;
    params.userId = this.userId;
    params.role = TRTCRoleType.anchor;
    params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
    trtcCloud.enterRoom(params, TRTCAppScene.live);

    TRTCVideoEncParam encParams = new TRTCVideoEncParam();
    encParams.videoResolution = TRTCVideoResolution.res_960_540;
    // In TRTCVIDEORESOLUTION, only the horizontal screen resolution (such as 640 × 360) is defined. If you need to use a vertical screen resolution (such as 360 × 640), you need to specify the TRTCVIDEORESOLUTIONMODE to be Portrait.
    encParams.videoResolutionMode = TRTCVideoResolutionMode.portrait;
    encParams.videoFps = 24;
    trtcCloud.setVideoEncoderParam(encParams);
    trtcCloud.startLocalAudio(TRTCAudioQuality.music);
    TRTCCloudListener listener = getListener();
    trtcCloud.registerListener(listener);
  }

  stopPushStream() {
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
  }

  startRecord() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    String filePath = appDocDir.path + recordFileName;
    File file = new File(filePath);
    if (file.existsSync()) file.deleteSync();
    TRTCLocalRecordingParams recordParams = new TRTCLocalRecordingParams(
        filePath: filePath,
        recordType: TRTCLocalRecordType.both,
        interval: 1000);
    await trtcCloud.startLocalRecording(recordParams);
    showToast('Start recording', dismissOtherToast: true);
  }

  saveImage() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath = appDocDir.path + recordFileName;
    // If you need to use image_gallery_saver plug -in, reduce the Flutter version to less than 2.10
    // await ImageGallerySaver.saveFile(savePath);
    showToast('Save to the album', dismissOtherToast: true);
  }

  stopRecord() async {
    trtcCloud.stopLocalRecording();
    if (!kIsWeb && Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        saveImage();
      } else {
        showToast("IOS reject",
            backgroundColor: Colors.red, dismissOtherToast: true);
      }
    } else if (!kIsWeb && Platform.isAndroid) {
      if (await Permission.photos.request().isGranted) {
        saveImage();
      } else {
        showToast("Android reject",
            backgroundColor: Colors.red, dismissOtherToast: true);
      }
    }
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        onUserVideoAvailable(userId, available);
      },

    );
  }

  onUserVideoAvailable(String userId, bool available) {
    if (available) {
      setState(() {
        remoteUidSet[userId] = userId;
      });
    }
    if (!available && remoteUidSet.containsKey(userId)) {
      setState(() {
        remoteUidSet.remove(userId);
      });
    }
  }

  destroyRoom() {
    trtcCloud.stopLocalRecording();
    trtcCloud.stopLocalAudio();
    trtcCloud.stopLocalPreview();
    trtcCloud.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    destroyRoom();
    super.dispose();
  }

  onRecordClick() {
    bool nowStartRecord = !isStartRecord;
    if (nowStartRecord) {
      startRecord();
    } else {
      stopRecord();
    }
    setState(() {
      isStartRecord = nowStartRecord;
    });
  }

  onStartPushStreamClick() {
    bool isNowStartPush = !isStartPush;
    if (isNowStartPush) {
      startPushStream();
    } else {
      stopPushStream();
    }
    setState(() {
      isStartPush = isNowStartPush;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> remoteUidList = remoteUidSet.values.toList();
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {},
          child: TRTCCloudVideoView(
            key: ValueKey("LocalView"),
            onViewCreated: (viewId) async {
              setState(() {
                localViewId = viewId;
              });
            },
          ),
        ),
        Positioned(
          left: 10,
          top: 15,
          width: 72,
          height: 370,
          child: Container(
            child: GridView.builder(
              itemCount: remoteUidList.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (BuildContext context, int index) {
                String userId = remoteUidList[index];
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 72,
                    minWidth: 72,
                    maxHeight: 120,
                    minHeight: 120,
                  ),
                  child: Stack(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TRTCCloudVideoView(
                          key: ValueKey('RemoteView_$userId'),
                          onViewCreated: (viewId) async {
                            trtcCloud.startRemoteView(
                                userId,
                                TRTCVideoStreamType.small,
                                viewId);
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Text(
                          userId,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          height: 160,
          bottom: 15,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    isStartRecord
                        ? Text(
                            'Recording...',
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(''),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                          autofocus: false,
                          enabled: !isStartRecord,
                          decoration: InputDecoration(
                            labelText: "Recording file name",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: this.recordFileName,
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: this.recordFileName.length,
                                ),
                              ),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            setState(() {
                              recordFileName = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: isStartPush && recordFileName != ""
                              ? MaterialStateProperty.all(Colors.green)
                              : MaterialStateProperty.all(Colors.grey),
                        ),
                        onPressed: () {
                          onRecordClick();
                        },
                        child: Text(isStartRecord ? TRTCAPIExampleLocalizations.current.localrecord_stop_record : TRTCAPIExampleLocalizations.current.localrecord_start_record),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        enabled: !isStartPush,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: "Room ID",
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.roomId.toString(),
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.roomId.toString().length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          roomId = int.parse(value);
                          eventBus.fire(TitleUpdateEvent('Room ID: $roomId'));
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        autofocus: false,
                        enabled: !isStartPush,
                        decoration: InputDecoration(
                          labelText: "User ID",
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: this.userId,
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: this.userId.length,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          userId = value;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                        onPressed: () {
                          onStartPushStreamClick();
                        },
                        child: Text(isStartPush ? TRTCAPIExampleLocalizations.current.stop_push : TRTCAPIExampleLocalizations.current.start_push),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
