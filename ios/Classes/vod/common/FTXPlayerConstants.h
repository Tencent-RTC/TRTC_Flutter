// Copyright (c) 2024 Tencent. All rights reserved.
#ifndef TRTC_FLUTTER_V3_IOS_CLASSES_VOD_COMMON_FTXPLAYERCONSTANTS_H_
#define TRTC_FLUTTER_V3_IOS_CLASSES_VOD_COMMON_FTXPLAYERCONSTANTS_H_

#import "FTXLiteAVSDKHeader.h"

#define ADJUST_RESOLUTION 0
#define FULL_FILL_CONTAINER 1
#define SCALE_FULL_FILL_CONTAINER 2

// ============================================================
// PIP error event code (moved from SuperPlayer FTXPipConstants.h)
// VodPlayer uses TXVodPlayer's native PIP capability; these constants
// are only kept as error code mapping when dispatching PIP events.
// ============================================================
/// No error.
#define NO_PIP_ERROR                         0
/// Device or system version is not supported (PIP is only supported on iPad iOS9+).
#define ERROR_IOS_PIP_DEVICE_NOT_SUPPORT     -104
/// Player not supported.
#define ERROR_IOS_PIP_PLAYER_NOT_SUPPORT     -105
/// Video not supported.
#define ERROR_IOS_PIP_VIDEO_NOT_SUPPORT      -106
/// PIP controller not available.
#define ERROR_IOS_PIP_IS_NOT_POSSIBLE        -107
/// PIP controller reported an error.
#define ERROR_IOS_PIP_FROM_SYSTEM            -108
/// Player object does not exist.
#define ERROR_IOS_PIP_PLAYER_NOT_EXIST       -109
/// PIP function is already running.
#define ERROR_IOS_PIP_IS_RUNNING             -110
/// PIP function is not started.
#define ERROR_IOS_PIP_NOT_RUNNING            -111
/// PIP start timeout.
#define ERROR_IOS_PIP_START_TIME_OUT         -112

#endif  // TRTC_FLUTTER_V3_IOS_CLASSES_VOD_COMMON_FTXPLAYERCONSTANTS_H_
