// Copyright (c) Tencent. All rights reserved.
//
// SymbolDummy.m
//
//
//  SymbolDummy.m
//  ffi_test
//
//  Created by vincepzhang on 2024/7/2.
//

#import "SymbolDummy.h"
#import "live_c_api/live_dart_def.h"
#import "live_c_api/live_dart_player_adapter.h"
#import "live_c_api/live_dart_premier_adapter.h"
#import "live_c_api/v2tx_live_def.h"
#import "live_c_api/v2tx_live_player.h"
#import "live_c_api/v2tx_live_premier.h"
#import "trtc_c_api/trtc_cloud_callback.h"
#import "trtc_c_api/trtc_dart_adapter.h"


@implementation LiteavSymbolDeclarationClass

+(void)liteavCFunction {
    LiteavFFIInitApiDL(NULL);
    LiteavFFIRegisterTRTCCloudObserver(0, NULL);
    LiteavFFIUnRegisterTRTCCloudObserver(NULL);
    LiteavFFIRegisterLogObserver(0, NULL);
    LiteavFFIUnRegisterLogObserver(0, NULL);
    LiteavFFIRegisterMusicPreloadObserver(0, NULL);
    LiteavFFIUnRegisterMusicPreloadObserver(0, NULL);
    LiteavFFIRegisterMusicPlayObserver(0, NULL, NULL);
    LiteavFFIUnRegisterMusicPlayObserver(0, NULL, NULL);
    LiteavFFIRegisterDeviceChangeObserver(0, NULL);
    LiteavFFIUnRegisterDeviceChangeObserver(0, NULL);
    LiteavFFIRegisterAudioFrameObserver(0, NULL);
    LiteavFFIUnRegisterAudioFrameObserver(0, NULL);

    // 1.1
    trtc_cloud_get_instance(NULL);
    // 1.2
    trtc_cloud_destroy_instance(NULL);
    trtc_cloud_create_cloud_callback(NULL);
    trtc_cloud_destroy_cloud_callback(NULL);
    // 2.1
    trtc_params_t trtc_params_t_;
    trtc_cloud_enter_room(NULL, trtc_params_t_, 0);
    // 2.2
    trtc_cloud_exit_room(NULL);
    // 2.3
    trtc_cloud_switch_role(NULL, 0);
    // 2.5
    trtc_switch_room_config_t trtc_switch_room_config_t_;
    trtc_cloud_switch_room(NULL, trtc_switch_room_config_t_);
    // 2.6
    trtc_cloud_connect_other_room(NULL, NULL);
    // 2.7
    trtc_cloud_disconnect_other_room(NULL);
    // 2.8
    trtc_cloud_set_default_stream_recv_mode(NULL, 0, 0);
    // 2.9
    trtc_cloud_create_sub_cloud(NULL);
    // 2.10
    trtc_cloud_destroy_sub_cloud(NULL, NULL);
    // 2.11
    trtc_cloud_update_other_room_forward_mode(NULL, NULL);
    // 3.1
    trtc_cloud_start_publishing(NULL, NULL, 0);
    // 3.2
    trtc_cloud_stop_publishing(NULL);
    // 3.5
    trtc_cloud_set_mix_transcoding_config(NULL, NULL);
    // 3.6
    trtc_cloud_start_publish_media_stream(NULL, NULL, NULL, NULL);
    // 3.7
    trtc_cloud_update_publish_media_stream(NULL, NULL, NULL, NULL, NULL);
    // 3.8
    trtc_cloud_stop_publish_media_stream(NULL, NULL);
    // 4.1 4.2  front_camera
    trtc_cloud_start_local_preview(NULL, 0, NULL);
    // 4.3
    trtc_cloud_update_local_view(NULL, NULL);
    // 4.4
    trtc_cloud_stop_local_preview(NULL);
    // 4.5
    trtc_cloud_mute_local_video(NULL, 0, 0);
    // 4.6
    trtc_cloud_set_video_mute_image(NULL, NULL, 0);
    // 4.7
    trtc_cloud_start_remote_view(NULL, NULL, 0, NULL);
    // 4.8
    trtc_cloud_update_remote_view(NULL, NULL, 0, NULL);
    // 4.9
    trtc_cloud_stop_remote_view(NULL, NULL, 0);
    // 4.10
    trtc_cloud_stop_all_remote_view(NULL);
    // 4.12
    trtc_cloud_mute_all_remote_video_streams(NULL, 0);
    // 4.13
    trtc_video_enc_param_t trtc_video_enc_param_t_;
    trtc_cloud_set_video_encoder_param(NULL, trtc_video_enc_param_t_);
    // 4.14
    trtc_network_qos_param_t trtc_network_qos_param_t_;
    trtc_cloud_set_network_qos_param(NULL, trtc_network_qos_param_t_);
    // 4.15
    trtc_cloud_set_local_render_params(NULL, 0, 0, 0);
    // 4.16
    trtc_render_params_t trtc_render_params_t_;
    trtc_cloud_set_remote_render_params(NULL, NULL, 0, trtc_render_params_t_);
    // 4.17
    trtc_cloud_set_video_encoder_rotation(NULL, 0);
    // 4.18
    trtc_cloud_set_video_encoder_mirror(NULL, 0);
    // 4.20
    trtc_cloud_enable_small_video_stream(NULL, 0, trtc_video_enc_param_t_);
    // 4.21
    trtc_cloud_set_remote_video_stream_type(NULL, NULL, 0);
    // 4.22
    trtc_cloud_mute_remote_video_stream(NULL, NULL, 0, 0);
    // 4.23
    trtc_cloud_snapshot_video(NULL, NULL, 0, 0);
    // 5.1
    trtc_cloud_start_local_audio(NULL, 0);
    // 5.2
    trtc_cloud_stop_local_audio(NULL);
    // 5.3
    trtc_cloud_mute_local_audio(NULL, 0);
    // 5.4
    trtc_cloud_mute_remote_audio(NULL, NULL, 0);
    // 5.5
    trtc_cloud_mute_all_remote_audio(NULL, 0);
    // 5.7
    trtc_cloud_set_remote_audio_volume(NULL, NULL, 0);
    // 5.8
    trtc_cloud_set_audio_capture_volume(NULL, 0);
    // 5.9
    trtc_cloud_get_audio_capture_volume(NULL);
    // 5.10
    trtc_cloud_set_audio_playout_volume(NULL, 0);
    // 5.11
    trtc_cloud_get_audio_playout_volume(NULL);
    // 5.12
    trtc_audio_volume_evaluate_params_t trtc_audio_volume_evaluate_params_t_;
    trtc_cloud_enable_audio_volume_evaluation(NULL, 0, trtc_audio_volume_evaluate_params_t_);
    // 5.15
    trtc_local_recording_params_t trtc_local_recording_params_t_;
    trtc_cloud_start_local_recording(NULL, trtc_local_recording_params_t_);
    // 5.16
    trtc_cloud_stop_local_recording(NULL);
    // 5.17
    trtc_cloud_set_gravity_sensor_adaptive_mode(NULL, 0);
    // 6.1
    trtc_cloud_get_device_manager(NULL);
    // 7.1
    trtc_cloud_set_beauty_style(NULL, 0, 0, 0, 0);
    // 7.2
    trtc_cloud_set_water_mark(NULL, 0, NULL, 0, 0, 0, 0, 0, 0, 0);
    // 8.1
    trtc_cloud_get_audio_effect_manager(NULL);
    // 8.2 TARGET_PLATFORM_DESKTOP || __ANDROID__
    trtc_cloud_start_system_audio_loopback(NULL, NULL);
    // 8.3 TARGET_PLATFORM_DESKTOP || __ANDROID__
    trtc_cloud_stop_system_audio_loopback(NULL);
    // 8.4
    trtc_cloud_set_system_audio_loopback_volume(NULL, 0);
    // 9.1
    trtc_cloud_start_screen_capture(NULL, NULL, 0, NULL);
    // 9.2
    trtc_cloud_stop_screen_capture(NULL);
    // 9.3
    trtc_cloud_pause_screen_capture(NULL);
    // 9.4
    trtc_cloud_resume_screen_capture(NULL);
    // 9.5 TARGET_PLATFORM_DESKTOP

    trtc_size_t trtc_size_t_;
    trtc_cloud_get_screen_capture_source_list(NULL, trtc_size_t_, trtc_size_t_, NULL, NULL);
    trtc_screen_capture_source_list trtc_screen_capture_source_list_;
    trtc_cloud_get_screen_capture_sources_info( trtc_screen_capture_source_list_, 0, NULL);
    trtc_cloud_release_screen_capture_sources_list(trtc_screen_capture_source_list_);
    // 9.6 TARGET_PLATFORM_DESKTOP
    trtc_screen_capture_source_info_t trtc_screen_capture_source_info_t_;
    trtc_rect_t trtc_rect_t_;
    trtc_screen_capture_property_t trtc_screen_capture_property_t_;
    trtc_cloud_select_screen_capture_target(NULL, trtc_screen_capture_source_info_t_, trtc_rect_t_, trtc_screen_capture_property_t_);
    // 9.8 TARGET_PLATFORM_DESKTOP
    tx_view tx_view_;
    trtc_cloud_add_excluded_share_window(NULL, tx_view_);
    // 9.9 TARGET_PLATFORM_DESKTOP
    trtc_cloud_remove_excluded_share_window(NULL, tx_view_);
    // 9.10 TARGET_PLATFORM_DESKTOP
    trtc_cloud_remove_all_excluded_share_windows(NULL);
    // 9.11 TARGET_PLATFORM_DESKTOP
    trtc_cloud_add_included_share_window(NULL, tx_view_);
    // 9.12 TARGET_PLATFORM_DESKTOP
    trtc_cloud_remove_included_share_window(NULL, tx_view_);
    // 9.13 TARGET_PLATFORM_DESKTOP
    trtc_cloud_remove_all_included_share_windows(NULL);
    // 9.7
    trtc_cloud_set_sub_stream_encoder_param(NULL, 0, 0, 0, 0, 0, 0);
    // 10.1
    trtc_cloud_enable_custom_video_capture(NULL, 0, 0);
    // 10.2
    trtc_video_frame_t trtc_video_frame_t_;
    trtc_cloud_send_custom_video_data(NULL, 0, trtc_video_frame_t_);
    // 10.3
    trtc_cloud_enable_custom_audio_capture(NULL, 0);
    // 10.4
    trtc_audio_frame_t trtc_audio_frame_t_;
    trtc_cloud_send_custom_audio_data(NULL, trtc_audio_frame_t_);
    // 10.5
    trtc_cloud_enable_mix_external_audio_frame(NULL, 0, 0);
    // 10.8
    trtc_cloud_generate_custom_pts(NULL);
    // 10.9.1
    trtc_cloud_enable_local_video_custom_process(NULL, 0, 0, 0);
    // 10.9.2
    trtc_video_frame_callback trtc_video_frame_callback_;
    trtc_cloud_set_local_video_custom_process_callback(NULL, trtc_video_frame_callback_);
    // 10.10
    trtc_cloud_set_local_video_render_callback(NULL, 0, 0, NULL);
    // 10.11
    trtc_cloud_set_remote_video_render_callback(NULL, NULL, 0, 0, NULL);
    // 10.12
    trtc_cloud_set_audio_frame_callback(NULL, NULL);
    // 10.13
    trtc_audio_frame_callback_format_t trtc_audio_frame_callback_format_t_;
    trtc_cloud_set_captured_audio_frame_callback_format(NULL, trtc_audio_frame_callback_format_t_);
    // 10.14
    trtc_cloud_set_local_processed_audio_frame_callback_format(NULL, trtc_audio_frame_callback_format_t_);
    // 10.15
    trtc_cloud_set_mixed_play_audio_frame_callback_format(NULL, trtc_audio_frame_callback_format_t_);
    // 11.1
    trtc_cloud_send_sustom_cmd_msg(NULL, 0, NULL, 0, 0, 0);
    // 11.2
    trtc_cloud_send_sei_msg(NULL, NULL, 0, 0);
    // 12.1
    trtc_speed_test_params_t trtc_speed_test_params_t_;
    trtc_cloud_start_speed_test(NULL, trtc_speed_test_params_t_);
    // 12.2
    trtc_cloud_stop_speed_test(NULL);
    // 13.1
    trtc_cloud_get_sdk_version(NULL);
    // 13.2 - 13.5
    trtc_log_param_t trtc_log_param_t_;
    trtc_cloud_set_log_param(NULL, trtc_log_param_t_);
    // 13.6
    trtc_cloud_set_log_callback(NULL, NULL);
    // 13.7
    trtc_cloud_show_debug_view(NULL, 0);
    // 13.9
    trtc_cloud_call_experimental_api(NULL, NULL);
    trtc_cloud_write_log(0, NULL, NULL, NULL);


    ///MARK: Effect Manager
    tx_audio_effect_manager_create_music_play_observer(NULL, NULL, NULL, NULL);
    tx_audio_effect_manager_destroy_music_play_observer(NULL);
    tx_audio_effect_manager_create_music_preload_observer(NULL, NULL, NULL);
    tx_audio_effect_manager_destroy_music_preload_observer(NULL);
    // 1.1
    tx_audio_effect_manager_enable_voice_ear_monitor(NULL, 0);
    // 1.2
    tx_audio_effect_manager_set_voice_ear_monitor_volume(NULL, 0);
    // 1.3
    tx_audio_effect_manager_set_voice_reverb_type(NULL, 0);
    // 1.4
    tx_audio_effect_manager_set_voice_changer_type(NULL, 0);
    // 1.5
    tx_audio_effect_manager_set_voice_capture_volume(NULL, 0);
    // 1.6
    tx_audio_effect_manager_set_voice_pitch(NULL, 0);
    // 2.0
    tx_audio_effect_manager_set_music_observer(NULL, 0, NULL);
    // 2.1
    tx_audio_music_param_t tx_audio_music_param_t_;
    tx_audio_effect_manager_start_play_music(NULL, tx_audio_music_param_t_);
    // 2.2
    tx_audio_effect_manager_stop_play_music(NULL, 0);
    // 2.3
    tx_audio_effect_manager_pause_play_music(NULL, 0);
    // 2.4
    tx_audio_effect_manager_resume_play_music(NULL, 0);
    // 2.5
    tx_audio_effect_manager_set_all_music_volume(NULL, 0);
    // 2.6
    tx_audio_effect_manager_set_music_publish_volume(NULL, 0, 0);
    // 2.7
    tx_audio_effect_manager_set_music_playout_volume(NULL, 0, 0);
    // 2.8
    tx_audio_effect_manager_set_music_pitch(NULL, 0, 0);
    // 2.9
    tx_audio_effect_manager_set_music_speed_rate(NULL, 0, 0);
    // 2.10
    tx_audio_effect_manager_get_current_pos_in_ms(NULL, 0);
    // 2.11
    tx_audio_effect_manager_get_music_duration_in_ms(NULL, NULL);
    // 2.12
    tx_audio_effect_manager_seek_music_to_pos_in_time(NULL, 0, 0);
    // 2.13
    tx_audio_effect_manager_set_music_scratch_speed_rate(NULL, 0, 0);
    // 2.14
    tx_audio_effect_manager_set_preload_observer(NULL, NULL);
    // 2.15
    tx_audio_effect_manager_preload_music(NULL, tx_audio_music_param_t_);
    // 2.16
    tx_audio_effect_manager_get_music_track_count(NULL, 0);
    // 2.17
    tx_audio_effect_manager_set_music_track(NULL, 0, 0);

    ///MARK: Device Manager
    tx_device_manager_create_device_observer(NULL, NULL);
    tx_device_manager_destroy_device_observer(NULL);
    tx_device_manager_is_front_camera(NULL);
    // 1.2
    tx_device_manager_switch_camera(NULL, 0);
    // 1.3
    tx_device_manager_get_camera_zoom_max_ratio(NULL);
    // 1.4
    tx_device_manager_set_camera_zoom_ratio(NULL, 0);
    // 1.5
    tx_device_manager_is_audio_focus_enabled(NULL);
    // 1.6
    tx_device_manager_enable_camera_auto_focus(NULL, 0);
    // 1.7
    tx_device_manager_set_camera_focus_position(NULL, 0, 0);
    // 1.8
    tx_device_manager_enable_camera_torch(NULL, 0);
    // 1.9
    tx_audio_route_e tx_audio_route_e_;
    tx_device_manager_set_audio_route(NULL, tx_audio_route_e_);
    // 2.1
    tx_device_manager_get_device_count(NULL, 0);
    tx_device_manager_get_device_info(NULL, 0, 0, NULL);
    // 2.2
    tx_device_manager_set_current_device(NULL, 0, NULL);
    // 2.3
    tx_device_manager_get_current_device(NULL, 0, NULL);
    // 2.4
    tx_device_manager_set_current_device_volume(NULL, 0, 0);
    // 2.5
    tx_device_manager_get_current_device_volume(NULL, 0);
    // 2.6
    tx_device_manager_set_current_device_mute(NULL, 0, 0);
    // 2.7
    tx_device_manager_get_current_device_mute(NULL, 0);
    // 2.8
    tx_device_manager_enable_following_default_audio_device(NULL, 0, 0);
    // 2.9
    tx_device_manager_start_camera_device_test(NULL, NULL);
    // 2.10
    tx_device_manager_stop_camera_device_test(NULL);
    // 2.11
    tx_device_manager_start_mic_device_test(NULL, 0);
    // 2.12
    tx_device_manager_start_mic_device_test_and_playback(NULL, 0, 0);
    // 2.13
    tx_device_manager_stop_mic_device_test(NULL);
    // 2.14
    tx_device_manager_start_speaker_device_test(NULL, NULL);
    // 2.15
    tx_device_manager_stop_speaker_device_test(NULL);
    // 2.16
    tx_device_manager_start_camera_device_test_and_callback(NULL, NULL);
    // 2.18
    tx_device_manager_set_application_play_volume(NULL, 0);
    // 2.19
    tx_device_manager_get_application_play_volume(NULL);
    // 2.20
    tx_device_manager_set_application_mute_state(NULL, 0);
    // 2.21
    tx_device_manager_get_application_mute_state(NULL);
    // 2.22
    tx_camera_capture_param_t tx_camera_capture_param_t_;
    tx_device_manager_set_camera_capture_param(NULL, tx_camera_capture_param_t_);
    // 2.23
    tx_device_manager_set_device_observer(NULL, NULL);
    // 2.24
    tx_device_manager_set_system_volume_type(NULL, 0);


    // v2tx_live_premier.h
    v2tx_live_premier_set_user_id(NULL);
    v2tx_live_premier_set_environment(NULL);
    v2tx_live_premier_get_sdk_version();
    v2tx_live_premier_set_license(NULL, NULL);
    v2tx_live_log_config_t v2tx_live_log_config_t_;
    v2tx_live_premier_set_log_config(v2tx_live_log_config_t_);
    v2tx_live_premier_call_experimental_api(NULL);

    // v2tx_live_player.h
    create_v2tx_live_player();
    create_v2tx_live_player_by_identifier(NULL);
    release_v2tx_live_player(NULL);
    v2tx_live_player_start_play(NULL, NULL);
    v2tx_live_player_stop_play(NULL);
    v2tx_live_player_is_playing(NULL);
    v2tx_live_player_pause_audio(NULL);
    v2tx_live_player_resume_audio(NULL);
    v2tx_live_player_pause_video(NULL);
    v2tx_live_player_resume_video(NULL);
    v2tx_live_player_switch_stream(NULL, NULL);
    v2tx_live_player_set_render_view(NULL, NULL);
    v2tx_live_player_set_playout_volume(NULL, 0);
    v2tx_live_player_set_cache_params(NULL, 0, 0);
    v2tx_live_player_set_render_rotation(NULL, 0);
    v2tx_live_player_set_render_fill_mode(NULL, 0);
    v2tx_live_player_set_property(NULL, NULL, NULL);
    v2tx_live_player_enable_receive_sei_message(NULL, false, 0);
    v2tx_live_player_enable_volume_evaluation(NULL, 0);
    v2tx_live_player_enable_observer_video_frame(NULL, false, 0, 0);
    v2tx_live_player_show_debug_view(NULL, 0);
    v2tx_live_player_snapshot(NULL);
    v2tx_live_player_enable_picture_in_picture(NULL, false);
    v2tx_live_player_start_local_recording(NULL, NULL, 0, 0);
    v2tx_live_player_stop_local_recording(NULL);

  // live_dart_premier_adapter.h
    LiteavFFIRegisterPremierListener(0);
    LiteavFFIUnRegisterPremierListener();

    // live_dart_player_adapter.h
    LiteavFFIRegisterPlayerListener(0, NULL);
    LiteavFFIUnRegisterPlayerListener(NULL);
    LiteavFFIRegisterPlayerVideoRenderCallback(NULL, 0);
    LiteavFFIUnRegisterPlayerVideoRenderCallback(NULL);
}

@end
