

import 'package:trtc_demo/models/data_models.dart';

class UserModel {
  String userId;
  String? userSig;

  String type = 'video';
  WidgetSize size = WidgetSize(width: 0, height: 0);

  bool enableAudio = true;
  bool enableVideo = true;

  bool isOpenMic = true;
  bool isOpenCamera = false;
  bool isFrontCamera = true;
  bool isSpeak = true;
  bool isShowingWindow = false;
  int? localViewId;
  bool isShowBeauty = true;

  UserModel({required String this.userId});
}
