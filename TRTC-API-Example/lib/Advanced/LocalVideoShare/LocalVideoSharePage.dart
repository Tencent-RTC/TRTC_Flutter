import 'package:flutter/material.dart';

///  LocalVideoSharePage.dart
///  TRTC-API-Example-Dart
class LocalVideoSharePage extends StatefulWidget {
  const LocalVideoSharePage({Key? key}) : super(key: key);

  @override
  _LocalVideoSharePageState createState() => _LocalVideoSharePageState();
}

class _LocalVideoSharePageState extends State<LocalVideoSharePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enableCustomVideoCapture',
          overflow: TextOverflow.visible,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        Text(
          'enableCustomAudioCapture',
          overflow: TextOverflow.visible,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        Text(
          'sendCustomVideoData',
          overflow: TextOverflow.visible,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        Text(
          'flutter暂时不支持',
          overflow: TextOverflow.visible,
        ),
      ],
    ));
  }
}
