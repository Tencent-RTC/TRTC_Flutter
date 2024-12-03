// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:tencent_rtc_sdk/trtc_cloud.dart';
// import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
// import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
// import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
//
// import '../../Debug/GenerateTestUserSig.dart';
//
// ///  JoinMultipleRoomPage.dart
// ///  TRTC-API-Example-Dart
// class JoinMultipleRoomPage extends StatefulWidget {
//   const JoinMultipleRoomPage({Key? key}) : super(key: key);
//
//   @override
//   _JoinMultipleRoomPageState createState() => _JoinMultipleRoomPageState();
// }
//
// class _JoinMultipleRoomPageState extends State<JoinMultipleRoomPage> {
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (kIsWeb || Platform.isWindows || Platform.isWindows) {
//       return Center(
//         child: Text('The platform does not yet support multiple instances'),
//       );
//     }
//
//     return GridView.count(
//       crossAxisCount: 2,
//       crossAxisSpacing: 10.0,
//       mainAxisSpacing: 30.0,
//       padding: EdgeInsets.all(20.0),
//       childAspectRatio: 0.5,
//       children: <Widget>[
//         CustomTextFieldAndButton(defaultId: "147888"),
//         CustomTextFieldAndButton(defaultId: "147999"),
//         CustomTextFieldAndButton(defaultId: "147000"),
//         CustomTextFieldAndButton(defaultId: "147111"),
//       ],
//     );
//   }
// }
//
// class CustomTextFieldAndButton extends StatefulWidget {
//   String defaultId;
//
//   CustomTextFieldAndButton({
//     required String this.defaultId,
//   });
//
//   @override
//   _CustomTextFieldAndButtonState createState() => _CustomTextFieldAndButtonState();
// }
//
// class _CustomTextFieldAndButtonState extends State<CustomTextFieldAndButton> {
//   late TRTCCloud? cloud;
//   late TRTCCloud subCloud;
//   int? localViewId;
//   int? remoteViewId;
//
//   bool _isEnterRoom = false;
//   String? _remoteUserId;
//   late TextEditingController _textEditingController;
//
//
//   @override
//   void initState() {
//     super.initState();
//     initTRTCCloud();
//     _textEditingController = TextEditingController(text: widget.defaultId);
//   }
//
//   initTRTCCloud() async {
//     cloud = (await TRTCCloud.sharedInstance())!;
//     subCloud = await cloud!.createSubCloud();
//   }
//
//
//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     subCloud.exitRoom();
//     cloud?.destroySubCloud(subCloud);
//     super.dispose();
//   }
//
//   onTrtcListener(type, params) async {
//     if (type == TRTCCloudListener.onUserVideoAvailable) {
//       onUserVideoAvailable(params["userId"], params['available']);
//     }
//   }
//
//   onUserVideoAvailable(String userId, bool available) {
//     if (available && _remoteUserId == null) {
//       subCloud.startRemoteView(userId, TRTCVideoStreamType.big, remoteViewId);
//       setState(() {
//         _remoteUserId = userId;
//       });
//     } else if (!available && _remoteUserId == userId){
//       subCloud.stopRemoteView(userId, TRTCVideoStreamType.big);
//       setState(() {
//         _remoteUserId = null;
//       });
//     }
//   }
//
//   startPushStream(String roomId, String userId) async {
//     subCloud.startLocalPreview(true, localViewId);
//     TRTCParams params = new TRTCParams();
//     params.sdkAppId = GenerateTestUserSig.sdkAppId;
//     params.roomId = int.parse(roomId);
//     params.userId = userId;
//     params.role = TRTCRoleType.anchor;
//     params.userSig = await GenerateTestUserSig.genTestSig(params.userId);
//     subCloud.enterRoom(params, TRTCAppScene.live);
//
//     subCloud.registerListener(onTrtcListener);
//   }
//
//   quitRoom() {
//     setState(() {
//       _remoteUserId = null;
//     });
//     subCloud.exitRoom();
//   }
//
//   Widget buildEnterButton() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 5,
//           child: TextField(
//             controller: _textEditingController,
//             decoration: InputDecoration(),
//           ),
//         ),
//         Expanded(
//           flex: 4,
//           child: TextButton(
//             onPressed: () {
//               if (!_isEnterRoom) {
//                 String time = DateTime.now().toString();
//                 String userId = time.substring(time.length - 8);
//                 startPushStream(_textEditingController.text, userId);
//               } else {
//                 quitRoom();
//               }
//               setState(() {
//                 _isEnterRoom = !_isEnterRoom;
//               });
//             },
//             child: Text(_isEnterRoom ? "Quit" : "Enter"),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget showSign(String sign) {
//     return Positioned(
//       top: 0,
//       left: 0,
//       child: Text(sign, style: TextStyle(color: Colors.red),),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         Expanded(
//             flex: 2,
//             child: Stack(
//               children: [
//                 TRTCCloudVideoView(
//                   key: ValueKey("LocalView"),
//                   viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
//                   onViewCreated: (viewId) async {
//                     setState(() {
//                       localViewId = viewId;
//                     });
//                   },
//                 ),
//                 !_isEnterRoom
//                 ? Container(color: Colors.black,)
//                 : showSign("local")
//               ],
//             ),
//         ),
//         Expanded(
//           flex: 2,
//           child: Stack(
//             children: [
//               TRTCCloudVideoView(
//                 key: ValueKey("RemoteView"),
//                 viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
//                 onViewCreated: (viewId) async {
//                   setState(() {
//                     remoteViewId = viewId;
//                   });
//                 },
//               ),
//               (_remoteUserId == null || !_isEnterRoom)
//               ? Container(color: Colors.black,)
//               : showSign("remote")
//             ],
//           ),
//         ),
//         Expanded(
//             flex: 1,
//             child:buildEnterButton(),
//         ),
//       ],
//     );
//   }
//
// }
