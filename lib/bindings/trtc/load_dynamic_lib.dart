import 'dart:ffi';
import 'dart:io';

class LoadDynamicLib {
  DynamicLibrary loadTRTCSDK() {
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('liteav.dll');
    } else {
      return DynamicLibrary.open("libliteavsdk.so");
    }
  }
}

// const String _libName = 'TXLiteAVSDK_Professional';
// final DynamicLibrary _dylib = () {
//   if (Platform.isMacOS || Platform.isIOS) {
//     return DynamicLibrary.open('$_libName.xcframework/$_libName');
//   }
//   // if (Platform.isAndroid || Platform.isLinux || Platform.isOhos) {
//   //   return DynamicLibrary.open('lib$_libName.so');
//   // }
//   if (Platform.isAndroid || Platform.isLinux) {
//     return DynamicLibrary.open('lib$_libName.so');
//   }
//   if (Platform.isWindows) {
//     return DynamicLibrary.open('$_libName.dll');
//   }
//   throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
// }();
