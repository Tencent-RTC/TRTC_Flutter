import 'package:flutter/cupertino.dart';

///  PushCDNAudiencePage.dart
///  TRTC-API-Example-Dart
class PushCDNAudiencePage extends StatefulWidget {
  const PushCDNAudiencePage({Key? key}) : super(key: key);

  @override
  _PushCDNAudiencePageState createState() => _PushCDNAudiencePageState();
}

class _PushCDNAudiencePageState extends State<PushCDNAudiencePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('CDN观看可集成pub插件"live_flutter_plugin"使用V2TXLivePlayer播放cdn url'),
    );
  }
}
