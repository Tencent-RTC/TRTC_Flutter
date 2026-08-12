// Copyright (c) Tencent. All rights reserved.  // NOLINT(build/header_guard)
//
// ITXVodPlayerCallback.h
//

﻿#ifndef __ITXVODPLAYERCALLBACK_H__
#define __ITXVODPLAYERCALLBACK_H__
#include "TXLiteAVBase.h"
  // NOLINT(whitespace/blank_line)
/**
 * VOD player error code
 */
enum TXVodPlayerError {

    /// Unknown error
    VOD_PLAY_ERR_UNKNOWN = -6001,

    /// General error code
    VOD_PLAY_ERR_GENERAL = -6002,

    /// Demuxer failed
    VOD_PLAY_ERR_DEMUXER_FAIL = -6003,

    /// Demuxer timeout
    VOD_PLAY_ERR_DEMUXER_TIMEOUT = -6005,

    /// Video decode error
    VOD_PLAY_ERR_DECODE_VIDEO_FAIL = -6006,

    /// Audio decode error  // NOLINT(whitespace/blank_line)
    VOD_PLAY_ERR_DECODE_AUDIO_FAIL = -6007,

    /// Video render error
    VOD_PLAY_ERR_RENDER_FAIL = -6009,

};

/////////////////////////////////////////////////////////////////////////////////
//
//                      VOD callback  // NOLINT(whitespace/indent)
//  // NOLINT(readability/braces)
/////////////////////////////////////////////////////////////////////////////////

class ITXVodPlayerEventCallback {
   public:
    virtual ~ITXVodPlayerEventCallback(){};

    /**
     * When the multimedia file playback starts, the SDK will notify through this callback.
     *
     * @param msLength The total length of the multimedia file, in milliseconds.
     */
    virtual void onVodPlayerStarted(uint64_t msLength) {
    }

    /**
     * When the playback progress of the multimedia file is changed,the SDK will notify through this callback.
     *
     * @param msPos Multimedia file playback progress, in milliseconds.
     */
    virtual void onVodPlayerProgress(uint64_t msPos) {
    }

    /**
     * When multimedia file playback is paused,the SDK will notify through this callback.
     */
    virtual void onVodPlayerPaused() {
    }

    /**
     * When multimedia file playback is resumed,the SDK will notify through this callback.
     */
    virtual void onVodPlayerResumed() {
    }

    /**
     * When multimedia file playback is stopped,the SDK will notify through this callback.
     *
     * @param reason Stop reason, 0 means the user stops actively, 1 means the file is finished playing, 2 means the
      * video is cut off.
     */
    virtual void onVodPlayerStopped(int reason) {
    }

    /**
     * When a multimedia file fails to play, the SDK notifies you through this callback, and the meaning of the error
      * code can be found in TXVodPlayerError.
     */  // NOLINT(whitespace/indent)
    virtual void onVodPlayerError(int error) = 0;  // NOLINT(readability/braces)
};

class ITXVodPlayerDataCallback {
   public:
    virtual ~ITXVodPlayerDataCallback(){};

    /**
     * Vod video frames callback.
     */
    virtual int onVodVideoFrame(TRTCVideoFrame& frame) = 0;

    /**
     * Vod audio frames callback.
     */
    virtual int onVodAudioFrame(TRTCAudioFrame& frame) = 0;
};

#endif /*__ITXVODPLAYERCALLBACK_H__ */
