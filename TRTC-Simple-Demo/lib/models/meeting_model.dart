import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:trtc_demo/models/data_models.dart';
import 'package:trtc_demo/models/user_model.dart';

class MeetingModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  int? _meetId;
  bool _isTextureRendering = false;
  TRTCAudioQuality _quality = TRTCAudioQuality.defaultMode;

  late UserModel _userInfo;
  List<UserModel> _userList = [];

  Map<BeautyType, double> _beautyInfo = {
    BeautyType.smooth : 0,
    BeautyType.nature : 0,
    BeautyType.white : 0,
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
      TRTCAudioQuality quality = TRTCAudioQuality.defaultMode}) {
    _meetId = meetId;
    _userInfo = UserModel(userId: userId);
    _userInfo.isOpenCamera = enabledCamera;
    _userInfo.isOpenMic = enabledMicrophone;
    _isTextureRendering = enableTextureRendering;
    _quality = quality;
  }

  int? getMeetId() {
    return _meetId;
  }

  TRTCAudioQuality getQuality() {
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
