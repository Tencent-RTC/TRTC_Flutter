import 'package:flutter/material.dart';
import 'package:trtc_api_example/Common/ExamplePageLayout.dart';
import 'package:trtc_api_example/Common/ExampleData.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';
import 'AudioCallingPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  AudioCallingEnterPage.dart
///  TRTC-API-Example-Dart
class AudioCallingEnterPage extends StatefulWidget {
  const AudioCallingEnterPage({Key? key}) : super(key: key);

  @override
  _AudioCallingEnterPageState createState() => _AudioCallingEnterPageState();
}

class _AudioCallingEnterPageState extends State<AudioCallingEnterPage> {
  String roomId = "1356732";
  String userId = TXHelper.generateRandomUserId();
  goAudioCallingPage() {
    ExamplePageItem item = ExamplePageItem(
      title: 'Room ID: $roomId',
      detailPage: AudioCallingPage(roomId: int.parse(roomId), userId: userId),
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

  unFocus() {
    if (roomIdFocusNode.hasFocus) {
      roomIdFocusNode.unfocus();
    } else if (userIdFocusNode.hasFocus) {
      userIdFocusNode.unfocus();
    }
  }

  final roomIdFocusNode = FocusNode();
  final userIdFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
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
                  this.goAudioCallingPage();
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
