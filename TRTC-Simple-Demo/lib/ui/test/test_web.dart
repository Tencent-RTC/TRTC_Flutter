import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trtc_demo/utils/tool.dart';

class TestWebPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestWebPageState();
  }
}

class TestWebPageState extends State<TestWebPage> {
  late TRTCCloud trtcCloud;
  late TXDeviceManager txDeviceManager;
  late TXBeautyManager txBeautyManager;
  late TXAudioEffectManager txAudioManager;

  @override
  initState() {
    super.initState();
    initTrtc();
  }

  initTrtc() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('测试API'),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(tabs: [
            Tab(text: '主要接口'),
            Tab(text: '音乐人生'),
            Tab(text: '视频接口'),
            Tab(text: '美颜&设备')
          ]),
        ),
        body: TabBarView(children: [
          ListView(
            children: [
              TextButton(
                onPressed: () async {
                  String? version = await trtcCloud.getSDKVersion();
                  MeetingTool.toast(version, context);
                },
                child: Text('getSDKVersion'),
              ),
               TextButton(
                onPressed: () async {
                  trtcCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
                },
                child: Text('switchRole-audience'),
              ),
              TextButton(
                onPressed: () async {
                  trtcCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
                },
                child: Text('switchRole-anchor'),
              ),
            ],
          ),
          ListView(
            children: [],
          ),
          ListView(children: []),
          ListView(
            children: [],
          ),
        ]),
      ),
    );
  }
}
