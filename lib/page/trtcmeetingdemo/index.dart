import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/tool.dart';
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

  /// 是否跳转到纹理渲染界面，该功能仅在内部测试阶段
  bool enableTextureRendering = false;

  /// 音质选择
  int quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH;

  final meetIdFocusNode = FocusNode();
  final userFocusNode = FocusNode();

  @override
  initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      if (Platform.isMacOS || Platform.isWindows) {
        setState(() {
          enableTextureRendering = true;
        });
      }
    });
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
      MeetingTool.toast('请填写SDKAPPID', context);
      return;
    }
    if (GenerateTestUserSig.secretKey == '') {
      MeetingTool.toast('请填写密钥', context);
      return;
    }
    meetId = meetId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (meetId == '') {
      MeetingTool.toast('请输入会议号', context);
      return;
    } else if (meetId == '0') {
      MeetingTool.toast('请输入合法的会议ID', context);
      return;
    } else if (meetId.toString().length > 10) {
      MeetingTool.toast('会议ID过长，请输入合法的会议ID', context);
      return;
    } else if (!new RegExp(r"[0-9]+$").hasMatch(meetId)) {
      MeetingTool.toast('会议ID只能为数字，请输入合法的会议ID', context);
      return;
    }
    userId = userId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (userId == '') {
      MeetingTool.toast('请输入用户ID', context);
      return;
    } else if (!new RegExp(r"[A-Za-z0-9_]+$").hasMatch(userId)) {
      MeetingTool.toast('用户ID只能为数字、字母、下划线，请输入正确的用户ID', context);
      return;
    } else if (userId.length > 10) {
      MeetingTool.toast('用户ID过长，请输入合法的用户ID', context);
      return;
    }
    unFocus();
    if (Platform.isAndroid || Platform.isIOS) {
      if (!(await Permission.camera.request().isGranted) &&
          !(await Permission.microphone.request().isGranted)) {
        MeetingTool.toast('需要获取音视频权限才能进入', context);
        return;
      }
    }
    var meetModel = context.read<MeetingModel>();
    meetModel.setUserSettig({
      "meetId": int.parse(meetId),
      "userId": userId,
      "enabledCamera": enabledCamera,
      "enabledMicrophone": enabledMicrophone,
      "quality": quality
    });
    if (enableTextureRendering) {
      if (Platform.isWindows) {
        MeetingTool.toast('windows 的本地纹理渲染还不支持', context);
      }
      Navigator.pushNamed(context, "/textureRender");
    } else {
      Navigator.pushNamed(context, "/video");
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
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("纹理渲染（内测阶段）",
                          style: TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: enableTextureRendering,
                        onChanged: (value) {
                          if (Platform.isMacOS || Platform.isWindows) {
                            MeetingTool.toast('PC 只支持纹理渲染', context);
                            return;
                          }
                          this.setState(() => enableTextureRendering = value);
                        },
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
