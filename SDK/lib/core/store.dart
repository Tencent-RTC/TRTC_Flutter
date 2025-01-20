import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/core/event_center.dart';

class Store {
  static Store? _instance;
  static Store sharedInstance() {
    if (_instance == null) {
      _instance =  Store._internal();
    }
    return _instance!;
  }
  Store._internal() {}

  TRTCRenderParams _localTextureParam = TRTCRenderParams();
  Map<String, TRTCRenderParams> _userRenderParamsMap = {};
  Map<int, String> _textureUserIdMap = {};

  TRTCRenderParams get localTextureParam => _localTextureParam;
  Map<String, TRTCRenderParams> get userRenderParamsMap => _userRenderParamsMap;
  Map<int, String> get textureUserIdMap => _textureUserIdMap;

  void clean() {
    _localTextureParam = TRTCRenderParams();
    _userRenderParamsMap.clear();
    _textureUserIdMap.clear();
  }

  void setLocalTextureParam(TRTCRenderParams param) {
    _localTextureParam = param;
    EventCenter().notify(updateTextureRenderEvent);
  }

  void setUserRenderParamsMap(String userId, TRTCRenderParams param) {
    _userRenderParamsMap[userId] = param;
    EventCenter().notify(updateTextureRenderEvent);
  }

  void setTextureUserIdMap(int textureId, String userId) {
    textureUserIdMap[textureId] = userId;
  }

  void deleteUser(String userId) {
    _userRenderParamsMap.remove(userId);
    _textureUserIdMap.removeWhere((key, value) => value == userId);
  }
}

