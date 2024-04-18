import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:trtc_demo/utils/tool.dart';
import 'package:provider/provider.dart';

// Multiplayer video meeting page
class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  /// user id
  String _userId = '';

  /// meeting id
  String _meetId = '';

  /// whether turn on the camera
  bool _enabledCamera = true;

  /// whether turn on the microphone
  bool _enabledMicrophone = false;

  bool _enableTextureRendering = false;

  /// sound quality selection
  int _quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH;

  final _meetIdFocusNode = FocusNode();
  final _userFocusNode = FocusNode();

  @override
  initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
        setState(() {
          _enableTextureRendering = true;
        });
      }
    });
  }

  _unFocus() {
    if (_meetIdFocusNode.hasFocus) {
      _meetIdFocusNode.unfocus();
    } else if (_userFocusNode.hasFocus) {
      _userFocusNode.unfocus();
    }
  }

  @override
  dispose() {
    super.dispose();
    _unFocus();
  }

  _enterMeeting() async {
    if (GenerateTestUserSig.sdkAppId == 0) {
      MeetingTool.toast('Please fill in Sdkappid', context);
      return;
    }
    if (GenerateTestUserSig.secretKey == '') {
      MeetingTool.toast('Please fill in the key', context);
      return;
    }
    _meetId = _meetId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (_meetId == '') {
      MeetingTool.toast('Please enter the conference number', context);
      return;
    } else if (_meetId == '0') {
      MeetingTool.toast('Please enter the legal meeting ID', context);
      return;
    } else if (_meetId.toString().length > 10) {
      MeetingTool.toast('Please enter a valid conference ID', context);
      return;
    } else if (!new RegExp(r"[0-9]+$").hasMatch(_meetId)) {
      MeetingTool.toast(
          'Conference ID can only be numeric. Please enter a legal conference ID',
          context);
      return;
    }
    _userId = _userId.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (_userId == '') {
      MeetingTool.toast('Please enter user ID', context);
      return;
    } else if (!new RegExp(r"[A-Za-z0-9_]+$").hasMatch(_userId)) {
      MeetingTool.toast(
          'User ID can only be numbers, letters and underscores. Please enter the correct user ID',
          context);
      return;
    } else if (_userId.length > 10) {
      MeetingTool.toast(
          'The user ID is too long. Please enter a legal user ID', context);
      return;
    }
    _unFocus();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.camera.request().isGranted) ||
          !(await Permission.microphone.request().isGranted)) {
        MeetingTool.toast(
            'You need to obtain audio and video permission to enter', context);
        return;
      }
    }
    var meetModel = context.read<MeetingModel>();
    meetModel.setUserSettings(
      meetId: int.parse(_meetId),
      userId: _userId,
      enabledCamera: _enabledCamera,
      enabledMicrophone: _enabledMicrophone,
      enableTextureRendering:_enableTextureRendering,
      quality: _quality
    );
    Navigator.pushNamed(context, "/meeting");
  }

  Widget _setIdentityInfo() {
    return Column(
      children: [
        TextField(
            style: TextStyle(color: Colors.white),
            autofocus: false,
            focusNode: _meetIdFocusNode,
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
            onChanged: (value) => _meetId = value),
        TextField(
            style: TextStyle(color: Colors.white),
            autofocus: false,
            focusNode: _userFocusNode,
            decoration: InputDecoration(
              labelText: "User ID",
              hintText: "Please enter user ID",
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.5)),
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) => this._userId = value),
      ],
    );
  }

  Widget _setRoomOptions() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text("Turn on the camera",
              style: TextStyle(color: Colors.white)),
          trailing: Switch(
            value: _enabledCamera,
            onChanged: (value) =>
                this.setState(() => _enabledCamera = value),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text("Turn on the microphone",
              style: TextStyle(color: Colors.white)),
          trailing: Switch(
            value: _enabledMicrophone,
            onChanged: (value) =>
                this.setState(() => _enabledMicrophone = value),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text("Texture rendering",
              style: TextStyle(color: Colors.white)),
          trailing: Switch(
            value: _enableTextureRendering,
            onChanged: (value) {
              if (kIsWeb && value) {
                MeetingTool.toast(
                    'Texture rendering is not supported on the web',
                    context);
                return;
              }
              if ((Platform.isMacOS || Platform.isWindows) && !value) {
                MeetingTool.toast(
                    'Platform rendering is not supported on the MacOS/Windows',
                    context);
                return;
              }
              this.setState(() => _enableTextureRendering = value);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
            'Multiplayer video conference',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_meetIdFocusNode.hasFocus) {
            _meetIdFocusNode.unfocus();
          } else if (_userFocusNode.hasFocus) {
            _userFocusNode.unfocus();
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
                child: _setIdentityInfo(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _setRoomOptions(),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 30.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    "Enter the meeting",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _enterMeeting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
