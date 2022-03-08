import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_api_example/Common/ExamplePageLayout.dart';
import 'package:trtc_api_example/Common/ExampleData.dart';
import 'package:trtc_api_example/Common/TXHelper.dart';

import 'LiveAnchorPage.dart';
import 'LiveAudiencePage.dart';

///  LiveEnterPage.dart
///  TRTC-API-Example-Dart
class LiveEnterPage extends StatefulWidget {
  const LiveEnterPage({Key? key}) : super(key: key);

  @override
  _LiveEnterPageState createState() => _LiveEnterPageState();
}

class _LiveEnterPageState extends State<LiveEnterPage> {
  String roomId = "1256732";
  String userId = TXHelper.generateRandomUserId();
  goLivePage() {
    ExamplePageItem item = ExamplePageItem(
      title: '房间号: $roomId',
      detailPage: isSelectAnchor
          ? LiveAnchorPage(roomId: int.parse(roomId), userId: userId)
          : LiveAudiencePage(roomId: int.parse(roomId), userId: userId),
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

  // 隐藏底部输入框
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
                      labelText: "请输入房间号（必填项）",
                      hintText: "请输入房间号",
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
                      labelText: "请输入用户ID（必填项）",
                      hintText: "请输入用户ID",
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
                      Text("请选择角色（必选项）"),
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
                        child: Text('主播'),
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
                        child: Text('观众'),
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
                  backgroundColor: greenColor,
                ),
                onPressed: () {
                  this.goLivePage();
                },
                child: Text("进入房间"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
