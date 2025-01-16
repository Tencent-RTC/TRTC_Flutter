import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/models/user_model.dart';
import 'package:trtc_demo/utils/tool.dart';

/// Member list page
class MemberListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MemberListPageState();
}

class MemberListPageState extends State<MemberListPage> {
  late TRTCCloud _trtcCloud;
  late MeetingModel _meetModel;
  List<UserModel> _micList = [];

  String _totalSilence = "Total Silence";
  String _totalDarkness = "Total Darkness";

  @override
  initState() {
    super.initState();
    _initRoom();
    _meetModel = context.read<MeetingModel>();

    _totalSilence = _meetModel.getUserInfo().enableAudio
        ? "Total silence"
        : "Lift total silence";

    _totalDarkness = _meetModel.getUserInfo().enableVideo
        ? "Total darkness"
        : "Lift total darkness";
  }

  _initRoom() async {
    _trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  @override
  dispose() {
    super.dispose();
    _micList = [];
  }

  @override
  Widget build(BuildContext context) {
    List<UserModel> newList = [];
    _meetModel.getList().forEach((item) {
      if (item.type == 'video') {
        newList.add(item);
      }
    });
    _micList = newList;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
            'Member List',
            style: TextStyle(color: Colors.white)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Container(
        color: Color.fromRGBO(14, 25, 44, 1),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView(
                children: newList
                    .map<Widget>((item) => Container(
                  key: ValueKey(item.userId),
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(item.userId,
                            style: TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Offstage(
                          offstage:
                          item.userId == _meetModel.getUserInfo().userId,
                          child: IconButton(
                              icon: Icon(
                                item.enableAudio == true
                                    ? Icons.mic
                                    : Icons.mic_off,
                                color: Colors.white,
                                size: 36.0,
                              ),
                              onPressed: () {
                                if (item.enableAudio ==
                                    false) {
                                  item.enableAudio = true;
                                  _trtcCloud.muteRemoteAudio(
                                      item.userId, false);
                                } else {
                                  item.enableAudio = false;
                                  _trtcCloud.muteRemoteAudio(
                                      item.userId, true);
                                }
                                this.setState(() {});
                              }),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Offstage(
                          offstage:
                          item.userId == _meetModel.getUserInfo().userId,
                          child: IconButton(
                              icon: Icon(
                                item.enableVideo == true
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                color: Colors.white,
                                size: 36.0,
                              ),
                              onPressed: () {
                                if (item.enableVideo ==
                                    false) {
                                  item.enableVideo = true;
                                  _trtcCloud.muteRemoteVideoStream(
                                      item.userId, false);
                                } else {
                                  item.enableVideo = false;
                                  _trtcCloud.muteRemoteVideoStream(
                                      item.userId, true);
                                }
                                this.setState(() {});
                              }),
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
            new Align(
                child: new Container(
                  // grey box
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _trtcCloud.muteAllRemoteAudio(_meetModel.getUserInfo().enableAudio);
                          MeetingTool.toast(_totalSilence, context);
                          for (int i = 0; i < _micList.length; i++) {
                            _micList[i].enableAudio = !_micList[i].enableAudio;
                          }
                          this.setState(() {
                            _totalSilence = _meetModel.getUserInfo().enableAudio
                                ? "Total silence"
                                : "Lift total silence";
                          });
                        },
                        child: Text(_totalSilence,
                            style: TextStyle(
                                color: Color.fromRGBO(245, 108, 108, 1))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _trtcCloud.muteAllRemoteVideoStreams(_meetModel.getUserInfo().enableVideo);
                          MeetingTool.toast(_totalDarkness, context);
                          for (int i = 0; i < _micList.length; i++) {
                            _micList[i].enableVideo = !_micList[i].enableVideo;
                          }
                          this.setState(() {
                            _totalDarkness = _meetModel.getUserInfo().enableVideo
                                ? "Total darkness"
                                : "Lift total darkness";
                          });
                        },
                        child: Text(_totalDarkness,
                            style: TextStyle(
                                color: Color.fromRGBO(64, 158, 255, 1))),
                      ),
                    ],
                  ),
                  height: 50.0,
                ),
                alignment: Alignment.bottomCenter),
          ],
        ),
      ),
    );
  }
}
