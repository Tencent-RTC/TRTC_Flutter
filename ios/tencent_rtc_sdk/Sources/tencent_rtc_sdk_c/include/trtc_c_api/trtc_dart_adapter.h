// Copyright (c) 2024 Tencent. All rights reserved.
// Author: vincepzhang

#ifndef SDK_COMMON_FLUTTER_TRTC_TRTC_DART_ADAPTER_H_  // NOLINT(build/header_guard)
#define SDK_COMMON_FLUTTER_TRTC_TRTC_DART_ADAPTER_H_

#include "trtc_cloud.h"
#include "tx_audio_effect_manager.h"
#include "tx_device_manager.h"

void LiteavFFIRegisterTRTCCloudObserver(int64_t sendPort,
                                                          trtc_cloud trtc_cloud_ptr);
void LiteavFFIUnRegisterTRTCCloudObserver(trtc_cloud trtc_cloud_ptr);

int LiteavFFIRegisterLogObserver(int64_t sendPort,
                                                   trtc_cloud trtc_cloud_ptr);
int LiteavFFIUnRegisterLogObserver(int64_t sendPort,
                                                     trtc_cloud trtc_cloud_ptr);

int LiteavFFIRegisterMusicPreloadObserver(int64_t sendPort,
                                                            tx_audio_effect_manager instance);
int LiteavFFIUnRegisterMusicPreloadObserver(int64_t sendPort,
                                                              tx_audio_effect_manager instance);

int LiteavFFIRegisterMusicPlayObserver(int64_t sendPort,
                                                         tx_audio_effect_manager instance,
                                                         char* param);
int LiteavFFIUnRegisterMusicPlayObserver(int64_t sendPort,
                                                           tx_audio_effect_manager instance,
                                                           char* param);

int LiteavFFIRegisterDeviceChangeObserver(int64_t sendPort,
                                                            tx_device_manager instance);
int LiteavFFIUnRegisterDeviceChangeObserver(int64_t sendPort,
                                                              tx_device_manager instance);

int LiteavFFIRegisterAudioFrameObserver(int64_t sendPort,
                                                          trtc_cloud trtc_cloud_ptr);
int LiteavFFIUnRegisterAudioFrameObserver(int64_t sendPort,
                                                            trtc_cloud trtc_cloud_ptr);

int LiteavFFIRegisterChorusPlayerObserver(int64_t sendPort, void* chorus_player_ptr);
int LiteavFFIUnRegisterChorusPlayerObserver(int64_t sendPort, void* chorus_player_ptr);

#endif  // SDK_COMMON_FLUTTER_TRTC_TRTC_DART_ADAPTER_H_  // NOLINT(build/header_guard)
