import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:trtc_demo/models/data_models.dart';
import 'package:trtc_demo/models/user_model.dart';

class MeetingModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  int? _meetId;
  bool _isTextureRendering = false;
  int _quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;

  late UserModel _userInfo;
  List<UserModel> _userList = [];

  Map<BeautyType, double> _beautyInfo = {
    BeautyType.smooth : 6,
    BeautyType.nature : 6,
    BeautyType.pitu : 6,
    BeautyType.ruddy : 0
  };

  void setList(list) {
    _userList = list;
    notifyListeners();
  }

  void setUserSettings(
      {required int meetId,
      required String userId,
      required bool enabledCamera,
      required bool enabledMicrophone,
      required bool enableTextureRendering,
      int? quality = null}) {
    _meetId = meetId;
    _userInfo = UserModel(userId: userId);
    _userInfo.isOpenCamera = enabledCamera;
    _userInfo.isOpenMic = enabledMicrophone;
    _isTextureRendering = enableTextureRendering;
    _quality = quality ?? TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
  }

  int? getMeetId() {
    return _meetId;
  }

  int getQuality() {
    return _quality;
  }

  Map getBeautyInfo() {
    return _beautyInfo;
  }

  bool getTextureRenderingEnable() {
    return _isTextureRendering;
  }

  UserModel getUserInfo() {
    return _userInfo;
  }

  List<UserModel> getList() {
    return _userList;
  }

  void removeAll() {
    _userList.clear();
    notifyListeners();
  }
}
