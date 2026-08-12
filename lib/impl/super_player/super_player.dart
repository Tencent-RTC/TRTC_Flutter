// Copyright (c) 2022 Tencent. All rights reserved.
// ignore_for_file: unnecessary_import

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== Vod module (migrated from SuperPlayer) =====
part 'superplayer_plugin.dart';
part 'txplayer_controller.dart';
part 'txplayer_define.dart';
part 'txplayer_widget.dart';
part 'txvodplayer_config.dart';
part 'txvodplayer_controller.dart';
part 'txvoddownload_controller.dart';
part '../../bridge/super_player/vod_method_channel.dart';
part 'common/common_config.dart';
part 'provider/txplayer_holder.dart';
part 'tools/common_utils.dart';
part 'tools/log_utils.dart';
