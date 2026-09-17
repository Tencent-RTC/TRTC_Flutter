/// Compatibility re-export for the legacy package path.
///
/// Since 13.4.x tencent_rtc_sdk no longer bundles superPlayer and instead depends
/// on the public [super_player](https://pub.dev/packages/super_player) plugin.
/// This file re-exports the public plugin to keep the historical import path
/// `package:tencent_rtc_sdk/impl/super_player/super_player.dart` working.
///
/// New code should import `package:super_player/super_player.dart` directly.
library;

export 'package:super_player/super_player.dart';
