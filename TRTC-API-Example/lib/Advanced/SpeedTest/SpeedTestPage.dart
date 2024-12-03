import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'package:trtc_api_example/Debug/GenerateTestUserSig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  SpeedTestPage.dart
///  TRTC-API-Example-Dart
class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({Key? key}) : super(key: key);

  @override
  _SpeedTestPageState createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  String userId = TXHelper.generateRandomUserId();
  late TRTCCloud trtcCloud;
  late TRTCCloudListener listener;
  String btnTitle = "Speed test start";
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
    listener = getListener();
    trtcCloud.unRegisterListener(listener);
    trtcCloud.stopSpeedTest();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    destroyRoom();
    super.dispose();
  }

  final userIdFocusNode = FocusNode();
  unFocus() {
    if (userIdFocusNode.hasFocus) {
      userIdFocusNode.unfocus();
    }
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onSpeedTestResult: (result) {
        debugPrint("TRTCCloudExample TRTCCloudListenerparseCallbackParam onSpeedTestResult TRTCSpeedTestResult: success:${result.success} errMsg:${result.errMsg} ip:${result.ip} \n"
          " onSpeedTestResult quality:${result.quality} upLostRate:${result.upLostRate} downLostRate:${result.downLostRate} rtt:${result.rtt} \n"
          " onSpeedTestResult availableUpBandwidth:${result.availableUpBandwidth} availableDownBandwidth:${result.availableDownBandwidth} upJitter:${result.upJitter} downJitter:${result.downJitter}\n");
      }
    );
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
        btnTitle = "Speed test finished";
      });
      return;
    }
  }

  beginSpeedTest() async {
    btnTitle = "0%";
    int sdkAppId = GenerateTestUserSig.sdkAppId;
    String userSig = await GenerateTestUserSig.genTestSig(userId);
    trtcCloud.startSpeedTest(TRTCSpeedTestParams(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: "5555",
      userSig: GenerateTestUserSig.genTestSig("5555"),
      scene: TRTCSpeedTestScene.delayAndBandwidthTesting,
      expectedDownBandwidth: 500,
      expectedUpBandwidth: 500,
    ));
    listener = getListener();
    trtcCloud.registerListener(listener);
  }

  onStartButtonClick() {
    printResultList.clear();
    if (btnTitle == "Speed test start") {
      beginSpeedTest();
    } else if (btnTitle == "Speed test finished") {
      btnTitle = "Speed test start";
      trtcCloud.unRegisterListener(listener);
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
                  labelText: AppLocalizations.of(context)!.please_input_userid_required,
                  hintText: AppLocalizations.of(context)!.please_input_userid,
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
              child: Text('Speed test result'),
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
