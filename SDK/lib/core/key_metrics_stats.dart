
import 'dart:convert';

import 'package:tencent_trtc_cloud/trtc_cloud.dart';

const int KeyMetricsStats_TextureRender = 154001;
const int KeyMetricsStats_PlatformViewRender = 154002;

void setKeyMetricsStats(int key) async {

  TRTCCloud trtcCloud = (await TRTCCloud.sharedInstance())!;

  trtcCloud.callExperimentalAPI(jsonEncode({"api": "KeyMetricsStats",
                              "params": { "opt": "count",
                                          "key": key}}));
}