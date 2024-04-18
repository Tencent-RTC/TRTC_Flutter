import 'package:flutter/material.dart';
import 'package:trtc_api_example/Common/ExamplePageLayout.dart';
import 'package:trtc_api_example/Common/ExampleData.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'VoiceChatRoomAnchorPage.dart';
import 'VoiceChatRoomAudiencePage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  VoiceChatRoomEnterPage.dart
///  TRTC-API-Example-Dart
class VoiceChatRoomEnterPage extends StatefulWidget {
  const VoiceChatRoomEnterPage({Key? key}) : super(key: key);

  @override
  _VoiceChatRoomEnterPageState createState() => _VoiceChatRoomEnterPageState();
}

class _VoiceChatRoomEnterPageState extends State<VoiceChatRoomEnterPage> {
  String roomId = "1256732";
  String userId = TXHelper.generateRandomUserId();
  goVoiceChatRoomPage() {
    ExamplePageItem item = ExamplePageItem(
      title: 'Room ID: $roomId',
      detailPage: isSelectAnchor
          ? VoiceChatRoomAnchorPage(roomId: int.parse(roomId), userId: userId)
          : VoiceChatRoomAudiencePage(
              roomId: int.parse(roomId), userId: userId),
    );
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => ExamplePageLayout(
          examplePageData: item,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    unFocus();
    super.dispose();
  }

  // Hide the bottom input box
  unFocus() {
    if (roomIdFocusNode.hasFocus) {
      roomIdFocusNode.unfocus();
    } else if (userIdFocusNode.hasFocus) {
      userIdFocusNode.unfocus();
    }
  }

  final roomIdFocusNode = FocusNode();
  final userIdFocusNode = FocusNode();
  bool isSelectAnchor = true;
  @override
  Widget build(BuildContext context) {
    MaterialStateProperty<Color> greenColor =
        MaterialStateProperty.all(Colors.green);
    MaterialStateProperty<Color> greyColor =
        MaterialStateProperty.all(Colors.grey);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        unFocus();
      },
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 30, left: 45, right: 45),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(color: Colors.white),
                    autofocus: false,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: this.roomId.toString(),
                        selection: TextSelection.fromPosition(
                          TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: '${this.roomId}'.length),
                        ),
                      ),
                    ),
                    focusNode: roomIdFocusNode,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.please_input_roomid_required,
                      hintText: AppLocalizations.of(context)!.please_input_roomid,
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle:
                          TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      roomId = value;
                    },
                  ),
                  SizedBox(height: 25),
                  TextField(
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
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.live_please_select_role),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              isSelectAnchor ? greenColor : greyColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isSelectAnchor = true;
                          });
                        },
                        child: Text('Anchor'),
                      ),
                      SizedBox(width: 25),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              !isSelectAnchor ? greenColor : greyColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isSelectAnchor = false;
                          });
                        },
                        child: Text('Audience'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                  this.goVoiceChatRoomPage();
                },
                child: Text(AppLocalizations.of(context)!.enter_room),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
