// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class TRTCAPIExampleLocalizations {
  TRTCAPIExampleLocalizations();

  static TRTCAPIExampleLocalizations? _current;

  static TRTCAPIExampleLocalizations get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<TRTCAPIExampleLocalizations> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = TRTCAPIExampleLocalizations();
      TRTCAPIExampleLocalizations._current = instance;

      return instance;
    });
  }

  static TRTCAPIExampleLocalizations of(BuildContext context) {
    final instance = TRTCAPIExampleLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static TRTCAPIExampleLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<TRTCAPIExampleLocalizations>(context, TRTCAPIExampleLocalizations);
  }

  /// `Original`
  String get audiaeffect_effect_default {
    return Intl.message(
      'Original',
      name: 'audiaeffect_effect_default',
      desc: '',
      args: [],
    );
  }

  /// `Enter Room`
  String get audiocall_enter_room {
    return Intl.message(
      'Enter Room',
      name: 'audiocall_enter_room',
      desc: '',
      args: [],
    );
  }

  /// `Hang Up`
  String get audiocall_hang_up {
    return Intl.message(
      'Hang Up',
      name: 'audiocall_hang_up',
      desc: '',
      args: [],
    );
  }

  /// `Enter Room`
  String get enter_room {
    return Intl.message('Enter Room', name: 'enter_room', desc: '', args: []);
  }

  /// `Info Panel`
  String get audiocall_info_view {
    return Intl.message(
      'Info Panel',
      name: 'audiocall_info_view',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get audiocall_input_error_tip {
    return Intl.message(
      'Enter a room ID and username',
      name: 'audiocall_input_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `Mic Off`
  String get audiocall_mute {
    return Intl.message('Mic Off', name: 'audiocall_mute', desc: '', args: []);
  }

  /// `Mic Off`
  String get audiocall_mute_audio {
    return Intl.message(
      'Mic Off',
      name: 'audiocall_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Network Info`
  String get audiocall_net_info {
    return Intl.message(
      'Network Info',
      name: 'audiocall_net_info',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (Required)`
  String get please_input_roomid_required {
    return Intl.message(
      'Room ID (Required)',
      name: 'please_input_roomid_required',
      desc: '',
      args: [],
    );
  }

  /// `User ID (Required)`
  String get please_input_userid_required {
    return Intl.message(
      'User ID (Required)',
      name: 'please_input_userid_required',
      desc: '',
      args: [],
    );
  }

  /// `Please input room id`
  String get please_input_roomid {
    return Intl.message(
      'Please input room id',
      name: 'please_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Please input user id`
  String get please_input_userid {
    return Intl.message(
      'Please input user id',
      name: 'please_input_userid',
      desc: '',
      args: [],
    );
  }

  /// `Mic On`
  String get open_audio {
    return Intl.message('Mic On', name: 'open_audio', desc: '', args: []);
  }

  /// `Mic Off`
  String get close_audio {
    return Intl.message('Mic Off', name: 'close_audio', desc: '', args: []);
  }

  /// `Beauty pretreatment`
  String get beauty_process {
    return Intl.message(
      'Beauty pretreatment',
      name: 'beauty_process',
      desc: '',
      args: [],
    );
  }

  /// `Beauty open`
  String get beauty_process_open {
    return Intl.message(
      'Beauty open',
      name: 'beauty_process_open',
      desc: '',
      args: [],
    );
  }

  /// `Beauty close`
  String get beauty_process_close {
    return Intl.message(
      'Beauty close',
      name: 'beauty_process_close',
      desc: '',
      args: [],
    );
  }

  /// `Mute`
  String get mute_audio {
    return Intl.message('Mute', name: 'mute_audio', desc: '', args: []);
  }

  /// `Unmute`
  String get unmute_audio {
    return Intl.message('Unmute', name: 'unmute_audio', desc: '', args: []);
  }

  /// `Stop Push`
  String get stop_push {
    return Intl.message('Stop Push', name: 'stop_push', desc: '', args: []);
  }

  /// `Start Push`
  String get start_push {
    return Intl.message('Start Push', name: 'start_push', desc: '', args: []);
  }

  /// `You are on the sharing screen`
  String get screenshare_ing_tips {
    return Intl.message(
      'You are on the sharing screen',
      name: 'screenshare_ing_tips',
      desc: '',
      args: [],
    );
  }

  /// `Unknown state`
  String get screenshare_unknow_tips {
    return Intl.message(
      'Unknown state',
      name: 'screenshare_unknow_tips',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for screen sharing`
  String get screenshare_wait {
    return Intl.message(
      'Waiting for screen sharing',
      name: 'screenshare_wait',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for your screen sharing operation`
  String get screenshare_wait_tips {
    return Intl.message(
      'Waiting for your screen sharing operation',
      name: 'screenshare_wait_tips',
      desc: '',
      args: [],
    );
  }

  /// `Room ID: `
  String get audiocall_roomid {
    return Intl.message(
      'Room ID: ',
      name: 'audiocall_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Mic On`
  String get audiocall_stop_mute_audio {
    return Intl.message(
      'Mic On',
      name: 'audiocall_stop_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Audio Call`
  String get audiocall_title {
    return Intl.message(
      'Audio Call',
      name: 'audiocall_title',
      desc: '',
      args: [],
    );
  }

  /// `Texture Render`
  String get texture_render {
    return Intl.message(
      'Texture Render',
      name: 'texture_render',
      desc: '',
      args: [],
    );
  }

  /// `Use Receiver`
  String get use_receiver {
    return Intl.message(
      'Use Receiver',
      name: 'use_receiver',
      desc: '',
      args: [],
    );
  }

  /// `Use Speaker`
  String get use_speaker {
    return Intl.message('Use Speaker', name: 'use_speaker', desc: '', args: []);
  }

  /// `Volume`
  String get audiocall_voice_info {
    return Intl.message(
      'Volume',
      name: 'audiocall_voice_info',
      desc: '',
      args: [],
    );
  }

  /// `Child`
  String get audioeffect_child {
    return Intl.message('Child', name: 'audioeffect_child', desc: '', args: []);
  }

  /// `Girl`
  String get audioeffect_lolita {
    return Intl.message('Girl', name: 'audioeffect_lolita', desc: '', args: []);
  }

  /// `Metal`
  String get audioeffect_metal {
    return Intl.message('Metal', name: 'audioeffect_metal', desc: '', args: []);
  }

  /// `Enter a room ID and username`
  String get audioeffect_please_input_roomid_and_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'audioeffect_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `Voice Change Effect (Set After Push)`
  String get audioeffect_please_select_effect {
    return Intl.message(
      'Voice Change Effect (Set After Push)',
      name: 'audioeffect_please_select_effect',
      desc: '',
      args: [],
    );
  }

  /// `Reverb Effect (Set After Push)`
  String get audioeffect_please_select_reverb {
    return Intl.message(
      'Reverb Effect (Set After Push)',
      name: 'audioeffect_please_select_reverb',
      desc: '',
      args: [],
    );
  }

  /// `Hall`
  String get audioeffect_reverb_big {
    return Intl.message(
      'Hall',
      name: 'audioeffect_reverb_big',
      desc: '',
      args: [],
    );
  }

  /// `Original`
  String get audioeffect_reverb_default {
    return Intl.message(
      'Original',
      name: 'audioeffect_reverb_default',
      desc: '',
      args: [],
    );
  }

  /// `KTV`
  String get audioeffect_reverb_ktv {
    return Intl.message(
      'KTV',
      name: 'audioeffect_reverb_ktv',
      desc: '',
      args: [],
    );
  }

  /// `You can use 'live_flutter_plugin' pub plugin to play cdn url width V2TXLivePlayer class`
  String get pushcdn_play {
    return Intl.message(
      'You can use \'live_flutter_plugin\' pub plugin to play cdn url width V2TXLivePlayer class',
      name: 'pushcdn_play',
      desc: '',
      args: [],
    );
  }

  /// `Deep`
  String get audioeffect_reverb_low {
    return Intl.message(
      'Deep',
      name: 'audioeffect_reverb_low',
      desc: '',
      args: [],
    );
  }

  /// `Room`
  String get audioeffect_reverb_small {
    return Intl.message(
      'Room',
      name: 'audioeffect_reverb_small',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get audioeffect_roomid {
    return Intl.message(
      'Room ID',
      name: 'audioeffect_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get audioeffect_start_push {
    return Intl.message(
      'Start Push',
      name: 'audioeffect_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get audioeffect_stop_push {
    return Intl.message(
      'End Push',
      name: 'audioeffect_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Audio Effect Setting`
  String get audioeffect_trtc_set_quality {
    return Intl.message(
      'Audio Effect Setting',
      name: 'audioeffect_trtc_set_quality',
      desc: '',
      args: [],
    );
  }

  /// `Man`
  String get audioeffect_uncle {
    return Intl.message('Man', name: 'audioeffect_uncle', desc: '', args: []);
  }

  /// `User ID`
  String get audioeffect_userid {
    return Intl.message(
      'User ID',
      name: 'audioeffect_userid',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get audioquality_please_input_roomid_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'audioquality_please_input_roomid_userid',
      desc: '',
      args: [],
    );
  }

  /// `Audio Quality`
  String get audioquality_please_select_audio_quality {
    return Intl.message(
      'Audio Quality',
      name: 'audioquality_please_select_audio_quality',
      desc: '',
      args: [],
    );
  }

  /// `Capturing Volume`
  String get audioquality_please_set_volumn {
    return Intl.message(
      'Capturing Volume',
      name: 'audioquality_please_set_volumn',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get audioquality_quality_default {
    return Intl.message(
      'Default',
      name: 'audioquality_quality_default',
      desc: '',
      args: [],
    );
  }

  /// `Music`
  String get audioquality_quality_music {
    return Intl.message(
      'Music',
      name: 'audioquality_quality_music',
      desc: '',
      args: [],
    );
  }

  /// `Speech`
  String get audioquality_quality_speech {
    return Intl.message(
      'Speech',
      name: 'audioquality_quality_speech',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get audioquality_roomid {
    return Intl.message(
      'Room ID',
      name: 'audioquality_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get audioquality_start_push {
    return Intl.message(
      'Start Push',
      name: 'audioquality_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get audioquality_stop_push {
    return Intl.message(
      'End Push',
      name: 'audioquality_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Audio Quality Setting`
  String get audioquality_trtc_set_quality {
    return Intl.message(
      'Audio Quality Setting',
      name: 'audioquality_trtc_set_quality',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get audioquality_userid {
    return Intl.message(
      'User ID',
      name: 'audioquality_userid',
      desc: '',
      args: [],
    );
  }

  /// `Music 1`
  String get bgm_bgm_1 {
    return Intl.message('Music 1', name: 'bgm_bgm_1', desc: '', args: []);
  }

  /// `Music 2`
  String get bgm_bgm_2 {
    return Intl.message('Music 2', name: 'bgm_bgm_2', desc: '', args: []);
  }

  /// `Music 3`
  String get bgm_bgm_3 {
    return Intl.message('Music 3', name: 'bgm_bgm_3', desc: '', args: []);
  }

  /// `Enter a room ID and username`
  String get bgm_please_input_roomid_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'bgm_please_input_roomid_userid',
      desc: '',
      args: [],
    );
  }

  /// `Background Music`
  String get bgm_please_select_audio_bgm {
    return Intl.message(
      'Background Music',
      name: 'bgm_please_select_audio_bgm',
      desc: '',
      args: [],
    );
  }

  /// `Background Music Volume`
  String get bgm_please_set_volumn {
    return Intl.message(
      'Background Music Volume',
      name: 'bgm_please_set_volumn',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get bgm_roomid {
    return Intl.message('Room ID', name: 'bgm_roomid', desc: '', args: []);
  }

  /// `Start Push`
  String get bgm_start_push {
    return Intl.message(
      'Start Push',
      name: 'bgm_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get bgm_stop_push {
    return Intl.message('End Push', name: 'bgm_stop_push', desc: '', args: []);
  }

  /// `Background Music`
  String get bgm_trtc_set_bgm {
    return Intl.message(
      'Background Music',
      name: 'bgm_trtc_set_bgm',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get bgm_userid {
    return Intl.message('User ID', name: 'bgm_userid', desc: '', args: []);
  }

  /// `Failed to join call as the user did not grant the required permission.`
  String get common_please_input_roomid_and_userid {
    return Intl.message(
      'Failed to join call as the user did not grant the required permission.',
      name: 'common_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `Anchor’s Room ID`
  String get connectotherroom_please_input_need_pk_roomid {
    return Intl.message(
      'Anchor’s Room ID',
      name: 'connectotherroom_please_input_need_pk_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Anchor’s User ID`
  String get connectotherroom_please_input_need_pk_userid {
    return Intl.message(
      'Anchor’s User ID',
      name: 'connectotherroom_please_input_need_pk_userid',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get connectotherroom_please_input_roomid_and_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'connectotherroom_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `Bitrate`
  String get connectotherroom_please_select_bitrate {
    return Intl.message(
      'Bitrate',
      name: 'connectotherroom_please_select_bitrate',
      desc: '',
      args: [],
    );
  }

  /// `Frame Rate`
  String get connectotherroom_please_select_fps {
    return Intl.message(
      'Frame Rate',
      name: 'connectotherroom_please_select_fps',
      desc: '',
      args: [],
    );
  }

  /// `Resolution`
  String get connectotherroom_please_select_resolution {
    return Intl.message(
      'Resolution',
      name: 'connectotherroom_please_select_resolution',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get connectotherroom_roomid {
    return Intl.message(
      'Room ID',
      name: 'connectotherroom_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get connectotherroom_start_pk {
    return Intl.message(
      'Start',
      name: 'connectotherroom_start_pk',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get connectotherroom_start_push {
    return Intl.message(
      'Start Push',
      name: 'connectotherroom_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get connectotherroom_stop_pk {
    return Intl.message(
      'End',
      name: 'connectotherroom_stop_pk',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get connectotherroom_stop_push {
    return Intl.message(
      'End Push',
      name: 'connectotherroom_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Video Quality Setting`
  String get connectotherroom_trtc_set_quality {
    return Intl.message(
      'Video Quality Setting',
      name: 'connectotherroom_trtc_set_quality',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get connectotherroom_userid {
    return Intl.message(
      'User ID',
      name: 'connectotherroom_userid',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get customcamera_please_input_roomid_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'customcamera_please_input_roomid_userid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get customcamera_roomid {
    return Intl.message(
      'Room ID',
      name: 'customcamera_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get customcamera_start_push {
    return Intl.message(
      'Start Push',
      name: 'customcamera_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get customcamera_stop_push {
    return Intl.message(
      'End Push',
      name: 'customcamera_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Custom Video Capturing &amp; Rendering`
  String get customcamera_trtc_set_bgm {
    return Intl.message(
      'Custom Video Capturing &amp; Rendering',
      name: 'customcamera_trtc_set_bgm',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get customcamera_userid {
    return Intl.message(
      'User ID',
      name: 'customcamera_userid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get joinmultipleroom_room_id {
    return Intl.message(
      'Room ID',
      name: 'joinmultipleroom_room_id',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get joinmultipleroom_start_play {
    return Intl.message(
      'Start',
      name: 'joinmultipleroom_start_play',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get joinmultipleroom_stop_play {
    return Intl.message(
      'End',
      name: 'joinmultipleroom_stop_play',
      desc: '',
      args: [],
    );
  }

  /// `Enter Multiple Rooms`
  String get joinmultipleroom_title {
    return Intl.message(
      'Enter Multiple Rooms',
      name: 'joinmultipleroom_title',
      desc: '',
      args: [],
    );
  }

  /// `Anchor`
  String get live_anchor {
    return Intl.message('Anchor', name: 'live_anchor', desc: '', args: []);
  }

  /// `Audience`
  String get live_audience {
    return Intl.message('Audience', name: 'live_audience', desc: '', args: []);
  }

  /// `Audio Settings`
  String get live_audio_item {
    return Intl.message(
      'Audio Settings',
      name: 'live_audio_item',
      desc: '',
      args: [],
    );
  }

  /// `Camera Off`
  String get live_close_camera {
    return Intl.message(
      'Camera Off',
      name: 'live_close_camera',
      desc: '',
      args: [],
    );
  }

  /// `Mic Off`
  String get live_close_mic {
    return Intl.message('Mic Off', name: 'live_close_mic', desc: '', args: []);
  }

  /// `Unmute`
  String get live_close_mute_audio {
    return Intl.message(
      'Unmute',
      name: 'live_close_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Enter Room`
  String get live_enter_room {
    return Intl.message(
      'Enter Room',
      name: 'live_enter_room',
      desc: '',
      args: [],
    );
  }

  /// `Mute`
  String get live_mute {
    return Intl.message('Mute', name: 'live_mute', desc: '', args: []);
  }

  /// `Muted`
  String get live_mute_audio {
    return Intl.message('Muted', name: 'live_mute_audio', desc: '', args: []);
  }

  /// `Camera On`
  String get live_open_camera {
    return Intl.message(
      'Camera On',
      name: 'live_open_camera',
      desc: '',
      args: [],
    );
  }

  /// `Mic On`
  String get live_open_mic {
    return Intl.message('Mic On', name: 'live_open_mic', desc: '', args: []);
  }

  /// `Operation`
  String get live_operator {
    return Intl.message('Operation', name: 'live_operator', desc: '', args: []);
  }

  /// `Room ID (Required)`
  String get live_please_input_roomid {
    return Intl.message(
      'Room ID (Required)',
      name: 'live_please_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `User ID (Required)`
  String get live_please_input_userid {
    return Intl.message(
      'User ID (Required)',
      name: 'live_please_input_userid',
      desc: '',
      args: [],
    );
  }

  /// `Role (Required)`
  String get live_please_select_role {
    return Intl.message(
      'Role (Required)',
      name: 'live_please_select_role',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get live_room_input_error_tip {
    return Intl.message(
      'Enter a room ID and username',
      name: 'live_room_input_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `Room ID: `
  String get live_roomid {
    return Intl.message('Room ID: ', name: 'live_roomid', desc: '', args: []);
  }

  /// `Interactive Live Video Streaming`
  String get live_title {
    return Intl.message(
      'Interactive Live Video Streaming',
      name: 'live_title',
      desc: '',
      args: [],
    );
  }

  /// `Use Receiver`
  String get live_use_receiver {
    return Intl.message(
      'Use Receiver',
      name: 'live_use_receiver',
      desc: '',
      args: [],
    );
  }

  /// `Use Speaker`
  String get live_use_speaker {
    return Intl.message(
      'Use Speaker',
      name: 'live_use_speaker',
      desc: '',
      args: [],
    );
  }

  /// `Use Rear Camera`
  String get live_user_back_camera {
    return Intl.message(
      'Use Rear Camera',
      name: 'live_user_back_camera',
      desc: '',
      args: [],
    );
  }

  /// `Use Front Camera`
  String get live_user_front_camera {
    return Intl.message(
      'Use Front Camera',
      name: 'live_user_front_camera',
      desc: '',
      args: [],
    );
  }

  /// `Video Settings`
  String get live_video_item {
    return Intl.message(
      'Video Settings',
      name: 'live_video_item',
      desc: '',
      args: [],
    );
  }

  /// `Recording File Address`
  String get localrecord_please_input_record_file_name {
    return Intl.message(
      'Recording File Address',
      name: 'localrecord_please_input_record_file_name',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (8-digit by default, modifiable)`
  String get localrecord_please_input_roomid {
    return Intl.message(
      'Room ID (8-digit by default, modifiable)',
      name: 'localrecord_please_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (Required)`
  String get localrecord_please_input_roomid_and_userid {
    return Intl.message(
      'Room ID (Required)',
      name: 'localrecord_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get localrecord_roomid {
    return Intl.message(
      'Room ID',
      name: 'localrecord_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get localrecord_start_push {
    return Intl.message(
      'Start Push',
      name: 'localrecord_start_push',
      desc: '',
      args: [],
    );
  }

  /// `Start Recording`
  String get localrecord_start_record {
    return Intl.message(
      'Start Recording',
      name: 'localrecord_start_record',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get localrecord_stop_push {
    return Intl.message(
      'End Push',
      name: 'localrecord_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `End Recording`
  String get localrecord_stop_record {
    return Intl.message(
      'End Recording',
      name: 'localrecord_stop_record',
      desc: '',
      args: [],
    );
  }

  /// `Video Quality Setting`
  String get localrecord_trtc_set_quality {
    return Intl.message(
      'Video Quality Setting',
      name: 'localrecord_trtc_set_quality',
      desc: '',
      args: [],
    );
  }

  /// `Audio Call`
  String get main_item_aduio_call {
    return Intl.message(
      'Audio Call',
      name: 'main_item_aduio_call',
      desc: '',
      args: [],
    );
  }

  /// `One-to-one/Group audio call, which supports muting, hands-free mode, etc.`
  String get main_item_aduio_call_desc {
    return Intl.message(
      'One-to-one/Group audio call, which supports muting, hands-free mode, etc.',
      name: 'main_item_aduio_call_desc',
      desc: '',
      args: [],
    );
  }

  /// `Enter Multiple Rooms`
  String get main_item_join_multiple_room {
    return Intl.message(
      'Enter Multiple Rooms',
      name: 'main_item_join_multiple_room',
      desc: '',
      args: [],
    );
  }

  /// `Interactive Live Video Streaming`
  String get main_item_live {
    return Intl.message(
      'Interactive Live Video Streaming',
      name: 'main_item_live',
      desc: '',
      args: [],
    );
  }

  /// `Local Recording`
  String get main_item_local_record {
    return Intl.message(
      'Local Recording',
      name: 'main_item_local_record',
      desc: '',
      args: [],
    );
  }

  /// `Publish via CDN`
  String get main_item_pushcdn {
    return Intl.message(
      'Publish via CDN',
      name: 'main_item_pushcdn',
      desc: '',
      args: [],
    );
  }

  /// `Publish via CDN (New)`
  String get main_item_pushcdn_new {
    return Intl.message(
      'Publish via CDN (New)',
      name: 'main_item_pushcdn_new',
      desc: '',
      args: [],
    );
  }

  /// `Screen Recording Live Streaming`
  String get main_item_screen_share {
    return Intl.message(
      'Screen Recording Live Streaming',
      name: 'main_item_screen_share',
      desc: '',
      args: [],
    );
  }

  /// `Share the screen during live streaming, designed for online education, game streaming, etc.`
  String get main_item_screen_share_desc {
    return Intl.message(
      'Share the screen during live streaming, designed for online education, game streaming, etc.',
      name: 'main_item_screen_share_desc',
      desc: '',
      args: [],
    );
  }

  /// `Receive/Send SEI Message`
  String get main_item_sei_message {
    return Intl.message(
      'Receive/Send SEI Message',
      name: 'main_item_sei_message',
      desc: '',
      args: [],
    );
  }

  /// `Network Speed Testing`
  String get main_item_speed_test {
    return Intl.message(
      'Network Speed Testing',
      name: 'main_item_speed_test',
      desc: '',
      args: [],
    );
  }

  /// `String-type Room ID`
  String get main_item_string_room_id {
    return Intl.message(
      'String-type Room ID',
      name: 'main_item_string_room_id',
      desc: '',
      args: [],
    );
  }

  /// `Switch Room`
  String get main_item_switch_room {
    return Intl.message(
      'Switch Room',
      name: 'main_item_switch_room',
      desc: '',
      args: [],
    );
  }

  /// `Third-party Beauty Filter`
  String get main_item_third_beauty {
    return Intl.message(
      'Third-party Beauty Filter',
      name: 'main_item_third_beauty',
      desc: '',
      args: [],
    );
  }

  /// `Video Call`
  String get main_item_video_call {
    return Intl.message(
      'Video Call',
      name: 'main_item_video_call',
      desc: '',
      args: [],
    );
  }

  /// `One-to-one/Group video call, which supports muting, hands-free mode, etc.`
  String get main_item_video_call_desc {
    return Intl.message(
      'One-to-one/Group video call, which supports muting, hands-free mode, etc.',
      name: 'main_item_video_call_desc',
      desc: '',
      args: [],
    );
  }

  /// `Interactive Live Audio Streaming`
  String get main_item_voice_chat_room {
    return Intl.message(
      'Interactive Live Audio Streaming',
      name: 'main_item_voice_chat_room',
      desc: '',
      args: [],
    );
  }

  /// `Render Control`
  String get main_rerc_render_params {
    return Intl.message(
      'Render Control',
      name: 'main_rerc_render_params',
      desc: '',
      args: [],
    );
  }

  /// `Audio Effect Setting`
  String get main_rtrc_set_audio_effect {
    return Intl.message(
      'Audio Effect Setting',
      name: 'main_rtrc_set_audio_effect',
      desc: '',
      args: [],
    );
  }

  /// `Audio Quality Setting`
  String get main_rtrc_set_audio_quality {
    return Intl.message(
      'Audio Quality Setting',
      name: 'main_rtrc_set_audio_quality',
      desc: '',
      args: [],
    );
  }

  /// `Video Quality Setting`
  String get main_rtrc_set_video_quality {
    return Intl.message(
      'Video Quality Setting',
      name: 'main_rtrc_set_video_quality',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Features`
  String get main_trtc_advanced {
    return Intl.message(
      'Advanced Features',
      name: 'main_trtc_advanced',
      desc: '',
      args: [],
    );
  }

  /// `Basic Features`
  String get main_trtc_base_funciton {
    return Intl.message(
      'Basic Features',
      name: 'main_trtc_base_funciton',
      desc: '',
      args: [],
    );
  }

  /// `Cross-room Competition`
  String get main_trtc_connect_other_room_pk {
    return Intl.message(
      'Cross-room Competition',
      name: 'main_trtc_connect_other_room_pk',
      desc: '',
      args: [],
    );
  }

  /// `Custom Video Capturing &amp; Rendering`
  String get main_trtc_custom_camera {
    return Intl.message(
      'Custom Video Capturing &amp; Rendering',
      name: 'main_trtc_custom_camera',
      desc: '',
      args: [],
    );
  }

  /// `Local Video Sharing`
  String get main_trtc_local_video_share {
    return Intl.message(
      'Local Video Sharing',
      name: 'main_trtc_local_video_share',
      desc: '',
      args: [],
    );
  }

  /// `Background Music Setting`
  String get main_trtc_set_bgm {
    return Intl.message(
      'Background Music Setting',
      name: 'main_trtc_set_bgm',
      desc: '',
      args: [],
    );
  }

  /// `TRTC API Example`
  String get main_trtc_title {
    return Intl.message(
      'TRTC API Example',
      name: 'main_trtc_title',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (8-digit by default, modifiable)`
  String get mediashare_input_roomid {
    return Intl.message(
      'Room ID (8-digit by default, modifiable)',
      name: 'mediashare_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Local Video File`
  String get mediashare_media_file_name {
    return Intl.message(
      'Local Video File',
      name: 'mediashare_media_file_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get mediashare_please_input_roomid_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'mediashare_please_input_roomid_userid',
      desc: '',
      args: [],
    );
  }

  /// `Local Video File`
  String get mediashare_please_select_video_file {
    return Intl.message(
      'Local Video File',
      name: 'mediashare_please_select_video_file',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get mediashare_roomid {
    return Intl.message(
      'Room ID',
      name: 'mediashare_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Browse`
  String get mediashare_select_file {
    return Intl.message(
      'Browse',
      name: 'mediashare_select_file',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get mediashare_start_push {
    return Intl.message(
      'Start Push',
      name: 'mediashare_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get mediashare_stop_push {
    return Intl.message(
      'End Push',
      name: 'mediashare_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Local Video Sharing`
  String get mediashare_trtc_set_bgm {
    return Intl.message(
      'Local Video Sharing',
      name: 'mediashare_trtc_set_bgm',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get mediashare_userid {
    return Intl.message(
      'User ID',
      name: 'mediashare_userid',
      desc: '',
      args: [],
    );
  }

  /// `Playback address: http://your playback domain name/stream_id.flv`
  String get pushcdn_anchor_cdn_url_guide {
    return Intl.message(
      'Playback address: http://your playback domain name/stream_id.flv',
      name: 'pushcdn_anchor_cdn_url_guide',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (Required)`
  String get pushcdn_anchor_empty_room_id_tip {
    return Intl.message(
      'Room ID (Required)',
      name: 'pushcdn_anchor_empty_room_id_tip',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get pushcdn_anchor_enter_room {
    return Intl.message(
      'Start Push',
      name: 'pushcdn_anchor_enter_room',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get pushcdn_anchor_exit_room {
    return Intl.message(
      'End Push',
      name: 'pushcdn_anchor_exit_room',
      desc: '',
      args: [],
    );
  }

  /// `On-Cloud Stream Mixing (2 or More Anchors)`
  String get pushcdn_anchor_mixconfig_disabled {
    return Intl.message(
      'On-Cloud Stream Mixing (2 or More Anchors)',
      name: 'pushcdn_anchor_mixconfig_disabled',
      desc: '',
      args: [],
    );
  }

  /// `Picture-in-picture`
  String get pushcdn_anchor_mixconfig_in_picture {
    return Intl.message(
      'Picture-in-picture',
      name: 'pushcdn_anchor_mixconfig_in_picture',
      desc: '',
      args: [],
    );
  }

  /// `Left and right`
  String get pushcdn_anchor_mixconfig_left_right {
    return Intl.message(
      'Left and right',
      name: 'pushcdn_anchor_mixconfig_left_right',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get pushcdn_anchor_mixconfig_manual {
    return Intl.message(
      'Manual',
      name: 'pushcdn_anchor_mixconfig_manual',
      desc: '',
      args: [],
    );
  }

  /// `2 or More Anchors`
  String get pushcdn_anchor_more_anchor_tip {
    return Intl.message(
      '2 or More Anchors',
      name: 'pushcdn_anchor_more_anchor_tip',
      desc: '',
      args: [],
    );
  }

  /// `After Enter Room`
  String get pushcdn_anchor_need_enter_room_tip {
    return Intl.message(
      'After Enter Room',
      name: 'pushcdn_anchor_need_enter_room_tip',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get pushcdn_anchor_room_id_guide {
    return Intl.message(
      'Room ID',
      name: 'pushcdn_anchor_room_id_guide',
      desc: '',
      args: [],
    );
  }

  /// `Room ID：`
  String get pushcdn_anchor_room_title {
    return Intl.message(
      'Room ID：',
      name: 'pushcdn_anchor_room_title',
      desc: '',
      args: [],
    );
  }

  /// `stream id`
  String get pushcdn_anchor_stream_id_input_guide {
    return Intl.message(
      'stream id',
      name: 'pushcdn_anchor_stream_id_input_guide',
      desc: '',
      args: [],
    );
  }

  /// `stream id is not empty`
  String get pushcdn_audience_empty_stream_id_tip {
    return Intl.message(
      'stream id is not empty',
      name: 'pushcdn_audience_empty_stream_id_tip',
      desc: '',
      args: [],
    );
  }

  /// `Playback address: http://your playback domain name/stream_id.flv`
  String get pushcdn_audience_input_guide {
    return Intl.message(
      'Playback address: http://your playback domain name/stream_id.flv',
      name: 'pushcdn_audience_input_guide',
      desc: '',
      args: [],
    );
  }

  /// `Playback via CDN`
  String get pushcdn_audience_start_play {
    return Intl.message(
      'Playback via CDN',
      name: 'pushcdn_audience_start_play',
      desc: '',
      args: [],
    );
  }

  /// `End Playback`
  String get pushcdn_audience_stop_play {
    return Intl.message(
      'End Playback',
      name: 'pushcdn_audience_stop_play',
      desc: '',
      args: [],
    );
  }

  /// `On-Cloud Stream Mixing`
  String get pushcdn_more_cloud_mix {
    return Intl.message(
      'On-Cloud Stream Mixing',
      name: 'pushcdn_more_cloud_mix',
      desc: '',
      args: [],
    );
  }

  /// `Publish via CDN`
  String get pushcdn_page_title {
    return Intl.message(
      'Publish via CDN',
      name: 'pushcdn_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Stream ID`
  String get pushcdn_please_input_streamid {
    return Intl.message(
      'Stream ID',
      name: 'pushcdn_please_input_streamid',
      desc: '',
      args: [],
    );
  }

  /// `Anchor`
  String get pushcdn_select_role_anchor_choice {
    return Intl.message(
      'Anchor',
      name: 'pushcdn_select_role_anchor_choice',
      desc: '',
      args: [],
    );
  }

  /// `Audience`
  String get pushcdn_select_role_audience_choice {
    return Intl.message(
      'Audience',
      name: 'pushcdn_select_role_audience_choice',
      desc: '',
      args: [],
    );
  }

  /// `Select a role:\n- Anchors can publish streams via CDNs upon room entry by specifying the room entry parameter 'streamid'.\n- Anchors can publish streams via CDNs upon room entry by specifying the room entry B2parameter B2\n- If anchors choose to relay streams to CDNs, audience can enter the playback address to watch the streams.`
  String get pushcdn_select_role_guide {
    return Intl.message(
      'Select a role:\n- Anchors can publish streams via CDNs upon room entry by specifying the room entry parameter `streamid`.\n- Anchors can publish streams via CDNs upon room entry by specifying the room entry B2parameter B2\n- If anchors choose to relay streams to CDNs, audience can enter the playback address to watch the streams.',
      name: 'pushcdn_select_role_guide',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get pushcdn_select_role_net_step {
    return Intl.message(
      'Next',
      name: 'pushcdn_select_role_net_step',
      desc: '',
      args: [],
    );
  }

  /// `Before you publish streams to CDNs, do the following:\n1. Enable relayed push in the console. A push address will be generated automatically.\n2. Register a domain name for playback and complete ICP filing.\nDocumentation: CDN Relayed Live Streaming (https://cloud.tencent.com/document/product/647/16826); On-Cloud MixTranscoding (https://cloud.tencent.com/document/product/647/16827)`
  String get pushcdn_select_role_result {
    return Intl.message(
      'Before you publish streams to CDNs, do the following:\n1. Enable relayed push in the console. A push address will be generated automatically.\n2. Register a domain name for playback and complete ICP filing.\nDocumentation: CDN Relayed Live Streaming (https://cloud.tencent.com/document/product/647/16826); On-Cloud MixTranscoding (https://cloud.tencent.com/document/product/647/16827)',
      name: 'pushcdn_select_role_result',
      desc: '',
      args: [],
    );
  }

  /// `Fit`
  String get renderparams_mdoe_fit {
    return Intl.message(
      'Fit',
      name: 'renderparams_mdoe_fit',
      desc: '',
      args: [],
    );
  }

  /// `On for Front Camera`
  String get renderparams_mirror_auto {
    return Intl.message(
      'On for Front Camera',
      name: 'renderparams_mirror_auto',
      desc: '',
      args: [],
    );
  }

  /// `Off for Both Cameras`
  String get renderparams_mirror_disable {
    return Intl.message(
      'Off for Both Cameras',
      name: 'renderparams_mirror_disable',
      desc: '',
      args: [],
    );
  }

  /// `On for Both Cameras`
  String get renderparams_mirror_enable {
    return Intl.message(
      'On for Both Cameras',
      name: 'renderparams_mirror_enable',
      desc: '',
      args: [],
    );
  }

  /// `Fill`
  String get renderparams_mode_fill {
    return Intl.message(
      'Fill',
      name: 'renderparams_mode_fill',
      desc: '',
      args: [],
    );
  }

  /// `No other user in the room now. Please wait.`
  String get renderparams_no_remote_user_list {
    return Intl.message(
      'No other user in the room now. Please wait.',
      name: 'renderparams_no_remote_user_list',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get renderparams_please_input_roomid_and_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'renderparams_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `After Push`
  String get renderparams_please_start_push {
    return Intl.message(
      'After Push',
      name: 'renderparams_please_start_push',
      desc: '',
      args: [],
    );
  }

  /// `No other user in the room now. Please wait.`
  String get renderparams_plsase_ensure_remote_userid {
    return Intl.message(
      'No other user in the room now. Please wait.',
      name: 'renderparams_plsase_ensure_remote_userid',
      desc: '',
      args: [],
    );
  }

  /// `Select a remote user for render control`
  String get renderparams_remote_userid {
    return Intl.message(
      'Select a remote user for render control',
      name: 'renderparams_remote_userid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get renderparams_roomid {
    return Intl.message(
      'Room ID',
      name: 'renderparams_roomid',
      desc: '',
      args: [],
    );
  }

  /// `0`
  String get renderparams_rotate_0 {
    return Intl.message('0', name: 'renderparams_rotate_0', desc: '', args: []);
  }

  /// `180`
  String get renderparams_rotate_180 {
    return Intl.message(
      '180',
      name: 'renderparams_rotate_180',
      desc: '',
      args: [],
    );
  }

  /// `270`
  String get renderparams_rotate_270 {
    return Intl.message(
      '270',
      name: 'renderparams_rotate_270',
      desc: '',
      args: [],
    );
  }

  /// `90`
  String get renderparams_rotate_90 {
    return Intl.message(
      '90',
      name: 'renderparams_rotate_90',
      desc: '',
      args: [],
    );
  }

  /// `Preview Mirror Mode`
  String get renderparams_set_local_mirror {
    return Intl.message(
      'Preview Mirror Mode',
      name: 'renderparams_set_local_mirror',
      desc: '',
      args: [],
    );
  }

  /// `Preview Rendering Mode`
  String get renderparams_set_local_mode {
    return Intl.message(
      'Preview Rendering Mode',
      name: 'renderparams_set_local_mode',
      desc: '',
      args: [],
    );
  }

  /// `Preview Rotation (Clockwise)`
  String get renderparams_set_local_rotate {
    return Intl.message(
      'Preview Rotation (Clockwise)',
      name: 'renderparams_set_local_rotate',
      desc: '',
      args: [],
    );
  }

  /// `Remote Rendering Mode`
  String get renderparams_set_remote_mode {
    return Intl.message(
      'Remote Rendering Mode',
      name: 'renderparams_set_remote_mode',
      desc: '',
      args: [],
    );
  }

  /// `Remote Image Rotation (Clockwise)`
  String get renderparams_set_remote_roate {
    return Intl.message(
      'Remote Image Rotation (Clockwise)',
      name: 'renderparams_set_remote_roate',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get renderparams_start_push {
    return Intl.message(
      'Start Push',
      name: 'renderparams_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get renderparams_stop_push {
    return Intl.message(
      'End Push',
      name: 'renderparams_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Render Control`
  String get renderparams_trtc_set_quality {
    return Intl.message(
      'Render Control',
      name: 'renderparams_trtc_set_quality',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get renderparams_userid {
    return Intl.message(
      'User ID',
      name: 'renderparams_userid',
      desc: '',
      args: [],
    );
  }

  /// `Anchor`
  String get screenshare_anchor {
    return Intl.message(
      'Anchor',
      name: 'screenshare_anchor',
      desc: '',
      args: [],
    );
  }

  /// `Audience`
  String get screenshare_audience {
    return Intl.message(
      'Audience',
      name: 'screenshare_audience',
      desc: '',
      args: [],
    );
  }

  /// `Enter Room`
  String get screenshare_enter_room {
    return Intl.message(
      'Enter Room',
      name: 'screenshare_enter_room',
      desc: '',
      args: [],
    );
  }

  /// `Mic Off`
  String get screenshare_mute_audio {
    return Intl.message(
      'Mic Off',
      name: 'screenshare_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Please open the floating window permissions in Settings-Permission Settings`
  String get screenshare_permission_toast {
    return Intl.message(
      'Please open the floating window permissions in Settings-Permission Settings',
      name: 'screenshare_permission_toast',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (Required)`
  String get screenshare_please_input_roomid {
    return Intl.message(
      'Room ID (Required)',
      name: 'screenshare_please_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `User ID (Required)`
  String get screenshare_please_input_userid {
    return Intl.message(
      'User ID (Required)',
      name: 'screenshare_please_input_userid',
      desc: '',
      args: [],
    );
  }

  /// `Role (Required)`
  String get screenshare_please_select_role {
    return Intl.message(
      'Role (Required)',
      name: 'screenshare_please_select_role',
      desc: '',
      args: [],
    );
  }

  /// `Resolution: 1280 x 720`
  String get screenshare_resolution {
    return Intl.message(
      'Resolution: 1280 x 720',
      name: 'screenshare_resolution',
      desc: '',
      args: [],
    );
  }

  /// `Room ID: `
  String get screenshare_room_id {
    return Intl.message(
      'Room ID: ',
      name: 'screenshare_room_id',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get screenshare_room_input_error_tip {
    return Intl.message(
      'Enter a room ID and username',
      name: 'screenshare_room_input_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `Screen Sharing`
  String get screenshare_screen_share {
    return Intl.message(
      'Screen Sharing',
      name: 'screenshare_screen_share',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get screenshare_start {
    return Intl.message('Start', name: 'screenshare_start', desc: '', args: []);
  }

  /// `Failed`
  String get screenshare_start_failed {
    return Intl.message(
      'Failed',
      name: 'screenshare_start_failed',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get screenshare_stop {
    return Intl.message('End', name: 'screenshare_stop', desc: '', args: []);
  }

  /// `Mic On`
  String get screenshare_stop_mute_audio {
    return Intl.message(
      'Mic On',
      name: 'screenshare_stop_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Screen Sharing`
  String get screenshare_title {
    return Intl.message(
      'Screen Sharing',
      name: 'screenshare_title',
      desc: '',
      args: [],
    );
  }

  /// `Username: `
  String get screenshare_username {
    return Intl.message(
      'Username: ',
      name: 'screenshare_username',
      desc: '',
      args: [],
    );
  }

  /// `To watch the streams, enter the same room as audience using a different device`
  String get screenshare_watch_tips {
    return Intl.message(
      'To watch the streams, enter the same room as audience using a different device',
      name: 'screenshare_watch_tips',
      desc: '',
      args: [],
    );
  }

  /// `TRTC is a useful app.`
  String get seimessage_content {
    return Intl.message(
      'TRTC is a useful app.',
      name: 'seimessage_content',
      desc: '',
      args: [],
    );
  }

  /// `Enter SEI Message`
  String get seimessage_content_empty_toast {
    return Intl.message(
      'Enter SEI Message',
      name: 'seimessage_content_empty_toast',
      desc: '',
      args: [],
    );
  }

  /// `SEI Message`
  String get seimessage_message {
    return Intl.message(
      'SEI Message',
      name: 'seimessage_message',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get seimessage_please_input_roomid_and_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'seimessage_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `Received: (%s) %s`
  String get seimessage_receive_sei_message_toast {
    return Intl.message(
      'Received: (%s) %s',
      name: 'seimessage_receive_sei_message_toast',
      desc: '',
      args: [],
    );
  }

  /// `SEI Exception: %s`
  String get seimessage_receive_sei_message_toast_error {
    return Intl.message(
      'SEI Exception: %s',
      name: 'seimessage_receive_sei_message_toast_error',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get seimessage_room_id {
    return Intl.message(
      'Room ID',
      name: 'seimessage_room_id',
      desc: '',
      args: [],
    );
  }

  /// `Receive/Send SEI Message`
  String get seimessage_send_and_receive {
    return Intl.message(
      'Receive/Send SEI Message',
      name: 'seimessage_send_and_receive',
      desc: '',
      args: [],
    );
  }

  /// `Send Failed`
  String get seimessage_send_message_error_toast {
    return Intl.message(
      'Send Failed',
      name: 'seimessage_send_message_error_toast',
      desc: '',
      args: [],
    );
  }

  /// `Sent:%s`
  String get seimessage_send_message_success_toast {
    return Intl.message(
      'Sent:%s',
      name: 'seimessage_send_message_success_toast',
      desc: '',
      args: [],
    );
  }

  /// `Send SEI Message`
  String get seimessage_send_sei_message {
    return Intl.message(
      'Send SEI Message',
      name: 'seimessage_send_sei_message',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get seimessage_start_push {
    return Intl.message(
      'Start Push',
      name: 'seimessage_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get seimessage_stop_push {
    return Intl.message(
      'End Push',
      name: 'seimessage_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get seimessage_user_id {
    return Intl.message(
      'User ID',
      name: 'seimessage_user_id',
      desc: '',
      args: [],
    );
  }

  /// `Speed test failed`
  String get speedtest_fail {
    return Intl.message(
      'Speed test failed',
      name: 'speedtest_fail',
      desc: '',
      args: [],
    );
  }

  /// `Speed test finished`
  String get speedtest_finish {
    return Intl.message(
      'Speed test finished',
      name: 'speedtest_finish',
      desc: '',
      args: [],
    );
  }

  /// `User ID (Required)`
  String get speedtest_input_error_tip {
    return Intl.message(
      'User ID (Required)',
      name: 'speedtest_input_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `User ID (Required`
  String get speedtest_input_guide {
    return Intl.message(
      'User ID (Required',
      name: 'speedtest_input_guide',
      desc: '',
      args: [],
    );
  }

  /// `Test Result：`
  String get speedtest_result_guide {
    return Intl.message(
      'Test Result：',
      name: 'speedtest_result_guide',
      desc: '',
      args: [],
    );
  }

  /// `Start Test`
  String get speedtest_start {
    return Intl.message(
      'Start Test',
      name: 'speedtest_start',
      desc: '',
      args: [],
    );
  }

  /// `Network Testing`
  String get speedtest_title {
    return Intl.message(
      'Network Testing',
      name: 'speedtest_title',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get stringroomid_please_input_roomid_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'stringroomid_please_input_roomid_userid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get stringroomid_roomid {
    return Intl.message(
      'Room ID',
      name: 'stringroomid_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get stringroomid_start_push {
    return Intl.message(
      'Start Push',
      name: 'stringroomid_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get stringroomid_stop_push {
    return Intl.message(
      'End Push',
      name: 'stringroomid_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `String-type Room ID`
  String get stringroomid_trtc_string_room_id {
    return Intl.message(
      'String-type Room ID',
      name: 'stringroomid_trtc_string_room_id',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get stringroomid_userid {
    return Intl.message(
      'User ID',
      name: 'stringroomid_userid',
      desc: '',
      args: [],
    );
  }

  /// `Enter an 8-digit room ID`
  String get switchroom_please_input_roomid {
    return Intl.message(
      'Enter an 8-digit room ID',
      name: 'switchroom_please_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get switchroom_roomid {
    return Intl.message(
      'Room ID',
      name: 'switchroom_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get switchroom_start_push {
    return Intl.message(
      'Start Push',
      name: 'switchroom_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get switchroom_stop_push {
    return Intl.message(
      'End Push',
      name: 'switchroom_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Switch Room`
  String get switchroom_switch_room {
    return Intl.message(
      'Switch Room',
      name: 'switchroom_switch_room',
      desc: '',
      args: [],
    );
  }

  /// `Fail`
  String get switchroom_toast_switch_failed {
    return Intl.message(
      'Fail',
      name: 'switchroom_toast_switch_failed',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get switchroom_toast_switch_success {
    return Intl.message(
      'Success',
      name: 'switchroom_toast_switch_success',
      desc: '',
      args: [],
    );
  }

  /// `<TRTC>Switch Room</TRTC: `
  String get switchroom_trtc_switch_room {
    return Intl.message(
      '<TRTC>Switch Room</TRTC: ',
      name: 'switchroom_trtc_switch_room',
      desc: '',
      args: [],
    );
  }

  /// `Bytedance Beauty`
  String get thirdbeauty_bytedance {
    return Intl.message(
      'Bytedance Beauty',
      name: 'thirdbeauty_bytedance',
      desc: '',
      args: [],
    );
  }

  /// `Faceunity Beauty`
  String get thirdbeauty_faceunity {
    return Intl.message(
      'Faceunity Beauty',
      name: 'thirdbeauty_faceunity',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get thirdbeauty_please_input_roomid_and_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'thirdbeauty_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get thirdbeauty_room_id {
    return Intl.message(
      'Room ID',
      name: 'thirdbeauty_room_id',
      desc: '',
      args: [],
    );
  }

  /// `Skin Smoothing`
  String get thirdbeauty_set_blur_level {
    return Intl.message(
      'Skin Smoothing',
      name: 'thirdbeauty_set_blur_level',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get thirdbeauty_start_push {
    return Intl.message(
      'Start Push',
      name: 'thirdbeauty_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get thirdbeauty_stop_push {
    return Intl.message(
      'End Push',
      name: 'thirdbeauty_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Third-party Beauty Filter`
  String get thirdbeauty_title {
    return Intl.message(
      'Third-party Beauty Filter',
      name: 'thirdbeauty_title',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get thirdbeauty_user_id {
    return Intl.message(
      'User ID',
      name: 'thirdbeauty_user_id',
      desc: '',
      args: [],
    );
  }

  /// `Video super sub only supports Qualcomm processors and requires more than 660`
  String get thirdbeauty_video_sr_not_support {
    return Intl.message(
      'Video super sub only supports Qualcomm processors and requires more than 660',
      name: 'thirdbeauty_video_sr_not_support',
      desc: '',
      args: [],
    );
  }

  /// `Pixel devices are not supported by video hyperscore`
  String get thirdbeauty_video_sr_pixel_not_support {
    return Intl.message(
      'Pixel devices are not supported by video hyperscore',
      name: 'thirdbeauty_video_sr_pixel_not_support',
      desc: '',
      args: [],
    );
  }

  /// `Super sub currently only supports resolutions of 720p and below`
  String get thirdbeauty_video_sr_resolution_not_support {
    return Intl.message(
      'Super sub currently only supports resolutions of 720p and below',
      name: 'thirdbeauty_video_sr_resolution_not_support',
      desc: '',
      args: [],
    );
  }

  /// `Resources are loading, please wait`
  String get thirdbeauty_wait_tip {
    return Intl.message(
      'Resources are loading, please wait',
      name: 'thirdbeauty_wait_tip',
      desc: '',
      args: [],
    );
  }

  /// `Audio Settings`
  String get videocall_audio_item {
    return Intl.message(
      'Audio Settings',
      name: 'videocall_audio_item',
      desc: '',
      args: [],
    );
  }

  /// `Camera Off`
  String get videocall_close_camera {
    return Intl.message(
      'Camera Off',
      name: 'videocall_close_camera',
      desc: '',
      args: [],
    );
  }

  /// `Mic Off`
  String get videocall_close_mute_audio {
    return Intl.message(
      'Mic Off',
      name: 'videocall_close_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Enter Room`
  String get videocall_enter_room {
    return Intl.message(
      'Enter Room',
      name: 'videocall_enter_room',
      desc: '',
      args: [],
    );
  }

  /// `Mic On`
  String get videocall_mute_audio {
    return Intl.message(
      'Mic On',
      name: 'videocall_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Camera On`
  String get videocall_open_camera {
    return Intl.message(
      'Camera On',
      name: 'videocall_open_camera',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (Required)`
  String get videocall_please_input_roomid {
    return Intl.message(
      'Room ID (Required)',
      name: 'videocall_please_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `User ID (Required)`
  String get videocall_please_input_userid {
    return Intl.message(
      'User ID (Required)',
      name: 'videocall_please_input_userid',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get videocall_room_input_error_tip {
    return Intl.message(
      'Enter a room ID and username',
      name: 'videocall_room_input_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `Room ID: `
  String get videocall_roomid {
    return Intl.message(
      'Room ID: ',
      name: 'videocall_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Video Call`
  String get videocall_title {
    return Intl.message(
      'Video Call',
      name: 'videocall_title',
      desc: '',
      args: [],
    );
  }

  /// `Use Receiver`
  String get videocall_use_receiver {
    return Intl.message(
      'Use Receiver',
      name: 'videocall_use_receiver',
      desc: '',
      args: [],
    );
  }

  /// `Use Speaker`
  String get videocall_use_speaker {
    return Intl.message(
      'Use Speaker',
      name: 'videocall_use_speaker',
      desc: '',
      args: [],
    );
  }

  /// `Use Rear Camera`
  String get videocall_user_back_camera {
    return Intl.message(
      'Use Rear Camera',
      name: 'videocall_user_back_camera',
      desc: '',
      args: [],
    );
  }

  /// `Use Front Camera`
  String get videocall_user_front_camera {
    return Intl.message(
      'Use Front Camera',
      name: 'videocall_user_front_camera',
      desc: '',
      args: [],
    );
  }

  /// `Video Settings`
  String get videocall_video_item {
    return Intl.message(
      'Video Settings',
      name: 'videocall_video_item',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get videoquality_please_input_roomid_and_userid {
    return Intl.message(
      'Enter a room ID and username',
      name: 'videoquality_please_input_roomid_and_userid',
      desc: '',
      args: [],
    );
  }

  /// `Bitrate`
  String get videoquality_please_select_bitrate {
    return Intl.message(
      'Bitrate',
      name: 'videoquality_please_select_bitrate',
      desc: '',
      args: [],
    );
  }

  /// `Frame Rate`
  String get videoquality_please_select_fps {
    return Intl.message(
      'Frame Rate',
      name: 'videoquality_please_select_fps',
      desc: '',
      args: [],
    );
  }

  /// `Resolution`
  String get videoquality_please_select_resolution {
    return Intl.message(
      'Resolution',
      name: 'videoquality_please_select_resolution',
      desc: '',
      args: [],
    );
  }

  /// `Room ID`
  String get videoquality_roomid {
    return Intl.message(
      'Room ID',
      name: 'videoquality_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Start Push`
  String get videoquality_start_push {
    return Intl.message(
      'Start Push',
      name: 'videoquality_start_push',
      desc: '',
      args: [],
    );
  }

  /// `End Push`
  String get videoquality_stop_push {
    return Intl.message(
      'End Push',
      name: 'videoquality_stop_push',
      desc: '',
      args: [],
    );
  }

  /// `Video Quality Setting`
  String get videoquality_trtc_set_quality {
    return Intl.message(
      'Video Quality Setting',
      name: 'videoquality_trtc_set_quality',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get videoquality_userid {
    return Intl.message(
      'User ID',
      name: 'videoquality_userid',
      desc: '',
      args: [],
    );
  }

  /// `Anchor`
  String get voicechatroom_anchor {
    return Intl.message(
      'Anchor',
      name: 'voicechatroom_anchor',
      desc: '',
      args: [],
    );
  }

  /// `Anchor Operation`
  String get voicechatroom_anchor_operator {
    return Intl.message(
      'Anchor Operation',
      name: 'voicechatroom_anchor_operator',
      desc: '',
      args: [],
    );
  }

  /// `Audience`
  String get voicechatroom_audience {
    return Intl.message(
      'Audience',
      name: 'voicechatroom_audience',
      desc: '',
      args: [],
    );
  }

  /// `Audience Operation`
  String get voicechatroom_audience_operator {
    return Intl.message(
      'Audience Operation',
      name: 'voicechatroom_audience_operator',
      desc: '',
      args: [],
    );
  }

  /// `Mic Off`
  String get voicechatroom_close_mic {
    return Intl.message(
      'Mic Off',
      name: 'voicechatroom_close_mic',
      desc: '',
      args: [],
    );
  }

  /// `Mic Off`
  String get voicechatroom_down_mic {
    return Intl.message(
      'Mic Off',
      name: 'voicechatroom_down_mic',
      desc: '',
      args: [],
    );
  }

  /// `Enter Room`
  String get voicechatroom_enter_room {
    return Intl.message(
      'Enter Room',
      name: 'voicechatroom_enter_room',
      desc: '',
      args: [],
    );
  }

  /// `Mute`
  String get voicechatroom_mute_audio {
    return Intl.message(
      'Mute',
      name: 'voicechatroom_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Room ID (Required)`
  String get voicechatroom_please_input_roomid {
    return Intl.message(
      'Room ID (Required)',
      name: 'voicechatroom_please_input_roomid',
      desc: '',
      args: [],
    );
  }

  /// `User ID (Required)`
  String get voicechatroom_please_input_userid {
    return Intl.message(
      'User ID (Required)',
      name: 'voicechatroom_please_input_userid',
      desc: '',
      args: [],
    );
  }

  /// `Role (Required)`
  String get voicechatroom_please_select_role {
    return Intl.message(
      'Role (Required)',
      name: 'voicechatroom_please_select_role',
      desc: '',
      args: [],
    );
  }

  /// `Enter a room ID and username`
  String get voicechatroom_room_input_error_tip {
    return Intl.message(
      'Enter a room ID and username',
      name: 'voicechatroom_room_input_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `Room ID: `
  String get voicechatroom_roomid {
    return Intl.message(
      'Room ID: ',
      name: 'voicechatroom_roomid',
      desc: '',
      args: [],
    );
  }

  /// `Unmute`
  String get voicechatroom_stop_mute_audio {
    return Intl.message(
      'Unmute',
      name: 'voicechatroom_stop_mute_audio',
      desc: '',
      args: [],
    );
  }

  /// `Interactive Live Audio Streaming`
  String get voicechatroom_title {
    return Intl.message(
      'Interactive Live Audio Streaming',
      name: 'voicechatroom_title',
      desc: '',
      args: [],
    );
  }

  /// `Mic On`
  String get voicechatroom_up_mic {
    return Intl.message(
      'Mic On',
      name: 'voicechatroom_up_mic',
      desc: '',
      args: [],
    );
  }

  /// `Use Receiver`
  String get voicechatroom_use_receiver {
    return Intl.message(
      'Use Receiver',
      name: 'voicechatroom_use_receiver',
      desc: '',
      args: [],
    );
  }

  /// `Use Speaker`
  String get voicechatroom_use_speaker {
    return Intl.message(
      'Use Speaker',
      name: 'voicechatroom_use_speaker',
      desc: '',
      args: [],
    );
  }

  /// `Publish Mode`
  String get publish_mode {
    return Intl.message(
      'Publish Mode',
      name: 'publish_mode',
      desc: '',
      args: [],
    );
  }

  /// `Audio-only`
  String get audio_only_mode {
    return Intl.message(
      'Audio-only',
      name: 'audio_only_mode',
      desc: '',
      args: [],
    );
  }

  /// `Mixed RoomID`
  String get mix_room_id {
    return Intl.message(
      'Mixed RoomID',
      name: 'mix_room_id',
      desc: '',
      args: [],
    );
  }

  /// `Mixed UserID`
  String get mix_user_id {
    return Intl.message(
      'Mixed UserID',
      name: 'mix_user_id',
      desc: '',
      args: [],
    );
  }

  /// `Remote RoomID`
  String get remote_room_id {
    return Intl.message(
      'Remote RoomID',
      name: 'remote_room_id',
      desc: '',
      args: [],
    );
  }

  /// `Remote UserID`
  String get remote_user_id {
    return Intl.message(
      'Remote UserID',
      name: 'remote_user_id',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get start_publish_media_stream {
    return Intl.message(
      'Publish',
      name: 'start_publish_media_stream',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get stop_publish_media_stream {
    return Intl.message(
      'Stop',
      name: 'stop_publish_media_stream',
      desc: '',
      args: [],
    );
  }

  /// `Publish media stream (to room)`
  String get publish_stream_to_room {
    return Intl.message(
      'Publish media stream (to room)',
      name: 'publish_stream_to_room',
      desc: '',
      args: [],
    );
  }

  /// `Publish media stream (to CDN)`
  String get publish_stream_to_cdn {
    return Intl.message(
      'Publish media stream (to CDN)',
      name: 'publish_stream_to_cdn',
      desc: '',
      args: [],
    );
  }

  /// `Push address (separate multiple addresses with commas)`
  String get publish_url {
    return Intl.message(
      'Push address (separate multiple addresses with commas)',
      name: 'publish_url',
      desc: '',
      args: [],
    );
  }

  /// `Audio Frame Custom Process`
  String get main_item_audio_frame_process {
    return Intl.message(
      'Audio Frame Custom Process',
      name: 'main_item_audio_frame_process',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<TRTCAPIExampleLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<TRTCAPIExampleLocalizations> load(Locale locale) => TRTCAPIExampleLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
