import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/ui/login.dart';
import 'package:trtc_demo/ui/meeting.dart';
import 'package:trtc_demo/ui/member_list.dart';
import 'package:trtc_demo/ui/test/test_api.dart';
import 'package:trtc_demo/models/meeting_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeetingModel(),
      child: MaterialApp(
        routes: {
          "/": (context) => LoginPage(),
          "/login": (context) => LoginPage(),
          "/meeting": (context) => MeetingPage(),
          "/memberList": (context) => MemberListPage(),
          "/test": (context) => TestPage(),
        },
      ),
    );
  }
}
