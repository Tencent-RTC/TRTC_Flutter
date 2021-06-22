import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting.dart';
import 'package:provider/provider.dart';

// 多人视频会议首页
class IndexPage extends StatefulWidget {
  IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  /// 用户id
  String userId = '';

  /// 会议id
  String meetId = '';

  /// 是否开启摄像头
  bool enabledCamera = true;

  /// 是否开启麦克风
  bool enabledMicrophone = false;

  /// 音质选择
  int quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH;

  final meetIdFocusNode = FocusNode();
  final userFocusNode = FocusNode();

  // 提示浮层
  showToast(text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  initState() {
    super.initState();
  }

  // 隐藏底部输入框
  unFocus() {
    if (meetIdFocusNode.hasFocus) {
      meetIdFocusNode.unfocus();
    } else if (userFocusNode.hasFocus) {
      userFocusNode.unfocus();
    }
  }

  @override
  dispose() {
    super.dispose();
    unFocus();
  }

  enterMeeting() async {
    if (GenerateTestUserSig.sdkAppId == 0) {
      showToast('请填写SDKAPPID');
      return;
    }
    if (GenerateTestUserSig.secretKey == '') {
      showToast('请填写密钥');
      return;
    }
    meetId = meetId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (meetId == '') {
      showToast('请输入会议号');
      return;
    } else if (meetId == '0') {
      showToast('请输入合法的会议ID');
      return;
    } else if (meetId.toString().length > 10) {
      showToast('会议ID过长，请输入合法的会议ID');
      return;
    } else if (!new RegExp(r"[0-9]+$").hasMatch(meetId)) {
      showToast('会议ID只能为数字，请输入合法的会议ID');
      return;
    }
    userId = userId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (userId == '') {
      showToast('请输入用户ID');
      return;
    } else if (!new RegExp(r"[A-Za-z0-9_]+$").hasMatch(userId)) {
      showToast('用户ID只能为数字、字母、下划线，请输入正确的用户ID');
      return;
    } else if (userId.length > 10) {
      showToast('用户ID过长，请输入合法的用户ID');
      return;
    }
    unFocus();
    if (Platform.isMacOS ||
        (await Permission.camera.request().isGranted &&
            await Permission.microphone.request().isGranted)) {
      var meetModel = context.read<MeetingModel>();
      meetModel.setUserSettig({
        "meetId": int.parse(meetId),
        "userId": userId,
        "enabledCamera": enabledCamera,
        "enabledMicrophone": enabledMicrophone,
        "quality": quality
      });
      Navigator.pushNamed(context, "/video");
    } else {
      showToast('需要获取音视频权限才能进入');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('多人视频会议'),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (meetIdFocusNode.hasFocus) {
            meetIdFocusNode.unfocus();
          } else if (userFocusNode.hasFocus) {
            userFocusNode.unfocus();
          }
        },
        child: Container(
          color: Color.fromRGBO(14, 25, 44, 1),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              Container(
                color: Color.fromRGBO(13, 44, 91, 1),
                margin: const EdgeInsets.only(top: 60.0),
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: [
                    TextField(
                        style: TextStyle(color: Colors.white),
                        autofocus: false,
                        focusNode: meetIdFocusNode,
                        decoration: InputDecoration(
                          labelText: "会议号",
                          hintText: "请输入会议号",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.5)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => meetId = value),
                    TextField(
                        style: TextStyle(color: Colors.white),
                        autofocus: false,
                        focusNode: userFocusNode,
                        decoration: InputDecoration(
                          labelText: "用户ID",
                          hintText: "请输入用户ID",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.5)),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) => this.userId = value),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title:
                          Text("开启摄像头", style: TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: enabledCamera,
                        onChanged: (value) =>
                            this.setState(() => enabledCamera = value),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title:
                          Text("开启麦克风", style: TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: enabledMicrophone,
                        onChanged: (value) =>
                            this.setState(() => enabledMicrophone = value),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("进入会议"),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: enterMeeting,
                      ),
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
}
