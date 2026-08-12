// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/chorus_music_player.dart';

/// FFI struct for chorus_external_music_params_t
class chorus_external_music_params_t extends ffi.Struct {
  external ffi.Pointer<ffi.Char> music_id;
  external ffi.Pointer<ffi.Char> music_url;
  external ffi.Pointer<ffi.Char> accompany_url;

  static ffi.Pointer<chorus_external_music_params_t> fromParams(
      ChorusExternalMusicParams param) {
    final params = calloc<chorus_external_music_params_t>();
    params.ref
      ..music_id = (param.musicId ?? '').toNativeUtf8().cast<ffi.Char>()
      ..music_url = (param.musicUrl ?? '').toNativeUtf8().cast<ffi.Char>()
      ..accompany_url =
          (param.accompanyUrl ?? '').toNativeUtf8().cast<ffi.Char>();
    return params;
  }

  static void freeStruct(ffi.Pointer<chorus_external_music_params_t> pointer) {
    calloc.free(pointer.ref.music_id);
    calloc.free(pointer.ref.music_url);
    calloc.free(pointer.ref.accompany_url);
    calloc.free(pointer);
  }
}

/// Opaque pointer type for chorus_music_player
typedef chorus_music_player = ffi.Pointer<ffi.Void>;
