import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting.dart';
import 'package:trtc_demo/page/trtcmeetingdemo/tool.dart';
import 'package:provider/provider.dart';

// Multiplayer video meeting page
class IndexPage extends StatefulWidget {
  IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  /// user id
  String userId = '';

  /// meeting id
  String meetId = '';

  /// whether turn on the camera
  bool enabledCamera = true;

  /// whether turn on the microphone
  bool enabledMicrophone = false;

  bool enableTextureRendering = false;

  /// sound quality selection
  int quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH;

  final meetIdFocusNode = FocusNode();
  final userFocusNode = FocusNode();

  @override
  initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
        setState(() {
          enableTextureRendering = true;
        });
      }
    });
  }

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
      MeetingTool.toast('Please fill in Sdkappid', context);
      return;
    }
    if (GenerateTestUserSig.secretKey == '') {
      MeetingTool.toast('Please fill in the key', context);
      return;
    }
    meetId = meetId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (meetId == '') {
      MeetingTool.toast('Please enter the conference number', context);
      return;
    } else if (meetId == '0') {
      MeetingTool.toast('请输入合法的会议ID', context);
      return;
    } else if (meetId.toString().length > 10) {
      MeetingTool.toast('Please enter a valid conference ID', context);
      return;
    } else if (!new RegExp(r"[0-9]+$").hasMatch(meetId)) {
      MeetingTool.toast(
          'Conference ID can only be numeric. Please enter a legal conference ID',
          context);
      return;
    }
    userId = userId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (userId == '') {
      MeetingTool.toast('Please enter user ID', context);
      return;
    } else if (!new RegExp(r"[A-Za-z0-9_]+$").hasMatch(userId)) {
      MeetingTool.toast(
          'User ID can only be numbers, letters and underscores. Please enter the correct user ID',
          context);
      return;
    } else if (userId.length > 10) {
      MeetingTool.toast(
          'The user ID is too long. Please enter a legal user ID', context);
      return;
    }
    unFocus();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.camera.request().isGranted) ||
          !(await Permission.microphone.request().isGranted)) {
        MeetingTool.toast(
            'You need to obtain audio and video permission to enter', context);
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
        title: const Text('Multiplayer video conference'),
        centerTitle: true,
        elevation: 0,
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
                          labelText: "Conference number",
                          hintText: "Please enter the conference number",
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
                          labelText: "User ID",
                          hintText: "Please enter user ID",
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
                      title: Text("Turn on the camera",
                          style: TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: enabledCamera,
                        onChanged: (value) =>
                            this.setState(() => enabledCamera = value),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Turn on the microphone",
                          style: TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: enabledMicrophone,
                        onChanged: (value) =>
                            this.setState(() => enabledMicrophone = value),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Texture rendering",
                          style: TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: enableTextureRendering,
                        onChanged: (value) {
                          if (kIsWeb && value) {
                            MeetingTool.toast(
                                'Texture rendering is not supported on the web',
                                context);
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
                        child: Text("Enter the meeting"),
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
