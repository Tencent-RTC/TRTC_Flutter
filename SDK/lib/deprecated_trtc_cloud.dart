
abstract class DeprecatedTRTCCloud {

  /// Start network speed testing, which should be avoided during video calls to ensure call quality
  ///
  /// Deprecated : This interface is deprecated. It is recommended to use the startSpeedTestWithParams interface.
  ///
  /// The speed test result will be used to optimize the SDK's subsequent selection policy. We recommend you perform the speed test before users place the first call, which will help select the optimal server. If the test result is not satisfactory, you can use a noticeable UI prompt to remind the user to select a better network. The test result is called back through [TRTCCloudListener.onSpeedTest].
  ///
  /// **Note:** the speed test will incur small basic service fees. For more information, please see [Basic Services](https://cloud.tencent.com/document/product/647/17157#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1).
  ///
  /// **Parameters:**
  ///
  /// `sdkAppId` Application ID
  ///
  /// `userId` User ID
  ///
  /// `userSig` User signature
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> startSpeedTest(int sdkAppId, String userId, String userSig);
}