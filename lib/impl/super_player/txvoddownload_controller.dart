// Copyright (c) 2022 Tencent. All rights reserved.
// ignore_for_file: constant_identifier_names
part of 'super_player.dart';

/// include features:
/// 1. Video predownlaod
/// 2. Video download
class TXVodDownloadController {
  static const String TAG = 'TXVodDownloadController';
  static TXVodDownloadController? _instance;

  static TXVodDownloadController get instance => _sharedInstance();

  final Map<int, _PreloadListener> _preloadListeners = {};
  final Map<int, _PreloadListener> _fileIdBeforeStartListeners = {};
  FTXDownlodOnStateChangeListener? _downlodOnStateChangeListener;
  FTXDownlodOnErrorListener? _downlodOnErrorListener;
  // Dart is single-isolate; synchronous increment is inherently atomic.
  int _preloadTaskIdCounter = 0;

  static TXVodDownloadController _sharedInstance() {
    _instance ??= TXVodDownloadController._createInstance();
    return _instance!;
  }

  TXVodDownloadController._createInstance() {
    // Register download / pre-download event dispatch.
    VodEventDispatcher.instance
        .registerDownloadListener(_onDownloadChannelEvent);
  }

  /// Unified entry for download / pre-download events dispatched by [VodEventDispatcher].
  void _onDownloadChannelEvent(Map<String, Object> event, bool isPreDownload) {
    if (isPreDownload) {
      _onPreDownloadEvent(event);
    } else {
      _onDownloadEvent(event);
    }
  }

  /// Start pre-downloading.
  /// [Important] Before starting pre-download, please set the cache directory [SuperPlayerPlugin.setGlobalCacheFolderPath] and cache size [SuperPlayerPlugin.setGlobalMaxCacheSize] of the playback engine first. This setting is a global configuration and needs to be consistent with the player to avoid invalidation of playback cache.
  /// playUrl: The URL to be pre-downloaded.
  /// preloadSizeMB: The pre-downloaded size (unit: MB).
  /// preferredResolution: The expected resolution, long type, value is height x width. For example, 720*1080. If multiple resolutions are not supported or not specified, pass -1.
  /// onCompleteListener: Pre-download successful callback.
  /// onErrorListener: Pre-download failed callback.
  /// Return value: Task ID, which can be used to stop pre-download [stopPreload].
  Future<int> startPreLoad(
    final String playUrl,
    final double preloadSizeMB,
    final int preferredResolution, {
    FTXPredownlodOnCompleteListener? onCompleteListener,
    FTXPredownlodOnErrorListener? onErrorListener,
  }) async {
    final int? value = await VodGlobalChannel.download.invoke<int>(
      'startPreLoad',
      {
        'playUrl': playUrl,
        'preloadSizeMB': preloadSizeMB,
        'preferredResolution': preferredResolution,
      },
    );
    int taskId = value ?? -1;
    if (taskId >= 0) {
      _preloadListeners[taskId] = _PreloadListener(
          onCompleteListener: onCompleteListener,
          onErrorListener: onErrorListener);
    }
    return taskId;
  }

  Future<void> startPreload(
    TXPlayInfoParams txPlayInfoParams,
    final double preloadSizeMB,
    final int preferredResolution, {
    FTXPredownlodOnCompleteListener? onCompleteListener,
    FTXPredownlodOnErrorListener? onErrorListener,
    FTXPredownlodOnStartListener? onStartListener,
  }) async {
    final int tmpPreloadTaskId = ++_preloadTaskIdCounter;
    await VodGlobalChannel.download.invoke<void>(
      'startPreLoadByParams',
      {
        'tmpPreloadTaskId': tmpPreloadTaskId,
        'playUrl': txPlayInfoParams.url,
        'fileId': txPlayInfoParams.fileId,
        'appId': txPlayInfoParams.appId,
        'pSign': txPlayInfoParams.psign,
        'preloadSizeMB': preloadSizeMB,
        'preferredResolution': preferredResolution,
        'httpHeader': txPlayInfoParams.httpHeader,
      },
    );
    _fileIdBeforeStartListeners[tmpPreloadTaskId] = _PreloadListener(
        onCompleteListener: onCompleteListener,
        onErrorListener: onErrorListener,
        onStartListener: onStartListener);
  }

  /// Stop pre-downloading.
  /// taskId: Task ID, returned by [startPreLoad].
  Future<void> stopPreLoad(final int taskId) async {
    await VodGlobalChannel.download
        .invoke<void>('stopPreLoad', {'value': taskId});
  }

  /// Start downloading.
  /// videoDownloadModel: Download constructor [TXVodDownloadMediaInfo].
  Future<void> startDownload(TXVodDownloadMediaInfo mediaInfo) async {
    await VodGlobalChannel.download
        .invoke<void>('startDownload', mediaInfo.toMap());
  }

  /// Resume downloading. This interface is different from the start downloading interface.
  /// This interface will find the corresponding cache and reuse the previous cache to resume downloading,
  /// while the start downloading interface will start a brand new download.
  /// videoDownloadModel: Download constructor [TXVodDownloadMediaInfo].
  Future<void> resumeDownload(TXVodDownloadMediaInfo mediaInfo) async {
    await VodGlobalChannel.download
        .invoke<void>('resumeDownload', mediaInfo.toMap());
  }

  /// Stop downloading.
  /// videoDownloadModel: Download constructor [TXVodDownloadMediaInfo].
  Future<void> stopDownload(TXVodDownloadMediaInfo mediaInfo) async {
    await VodGlobalChannel.download
        .invoke<void>('stopDownload', mediaInfo.toMap());
  }

  /// Set download request headers.
  Future<void> setDownloadHeaders(Map<String, String> headers) async {
    await VodGlobalChannel.download
        .invoke<void>('setDownloadHeaders', {'map': headers});
  }

  /// Get all video download lists.
  /// return [TXVodDownloadMediaInfo].
  Future<List<TXVodDownloadMediaInfo>> getDownloadList() async {
    final List<dynamic>? list =
        await VodGlobalChannel.download.invokeList('getDownloadList');
    final List<TXVodDownloadMediaInfo> outputList = [];
    if (list != null) {
      for (final dynamic item in list) {
        if (item is Map) {
          outputList.add(TXVodDownloadMediaInfo.fromMap(item));
        }
      }
    }
    return outputList;
  }

  /// Get the download information of the specified video.
  /// return [TXVodDownloadMediaInfo].
  Future<TXVodDownloadMediaInfo> getDownloadInfo(
      TXVodDownloadMediaInfo mediaInfo) async {
    final Map<dynamic, dynamic>? map = await VodGlobalChannel.download
        .invokeMap('getDownloadInfo', mediaInfo.toMap());
    if (map == null) {
      return TXVodDownloadMediaInfo();
    }
    return TXVodDownloadMediaInfo.fromMap(map);
  }

  /// Set the download event listener. This listener is a global download listener configuration and can be called repeatedly.
  void setDownloadObserver(
      FTXDownlodOnStateChangeListener? downlodOnStateChangeListener,
      FTXDownlodOnErrorListener? downlodOnErrorListener) {
    _downlodOnStateChangeListener = downlodOnStateChangeListener;
    _downlodOnErrorListener = downlodOnErrorListener;
  }

  /// Delete download task.
  Future<bool> deleteDownloadMediaInfo(TXVodDownloadMediaInfo mediaInfo) async {
    final bool? value = await VodGlobalChannel.download
        .invoke<bool>('deleteDownloadMediaInfo', mediaInfo.toMap());
    return value ?? false;
  }

  /// Dispatch download state events (matches legacy `onDownloadEvent`).
  void _onDownloadEvent(Map<String, Object> event) {
    LogUtils.d(TAG, 'onDownloadEvent _eventHandler, event= $event');
    final Map<dynamic, dynamic> map = event;
    int eventCode = map["event"];
    switch (eventCode) {
      case TXVodPlayEvent.EVENT_DOWNLOAD_START:
      case TXVodPlayEvent.EVENT_DOWNLOAD_PROGRESS:
      case TXVodPlayEvent.EVENT_DOWNLOAD_STOP:
      case TXVodPlayEvent.EVENT_DOWNLOAD_FINISH:
        _downlodOnStateChangeListener?.call(
            eventCode, TXVodDownloadMediaInfo.fromMap(map));
        break;
      case TXVodPlayEvent.EVENT_DOWNLOAD_ERROR:
        final TXVodDownloadMediaInfo info = TXVodDownloadMediaInfo.fromMap(map);
        final int errorCode = map["errorCode"];
        final String errorMsg = map["errorMsg"];
        _downlodOnErrorListener?.call(errorCode, errorMsg, info);
        break;
      default:
        break;
    }
  }

  /// Dispatch pre-download events (matches legacy `onPreDownloadEvent`).
  void _onPreDownloadEvent(Map<String, Object> event) {
    LogUtils.d(TAG, 'onPreDownloadEvent _eventHandler, event= $event');
    final Map<dynamic, dynamic> map = event;
    int eventCode = map["event"];
    switch (eventCode) {
      case TXVodPlayEvent.EVENT_PREDOWNLOAD_ON_COMPLETE:
        int taskId = map['taskId'];
        String url = map['url'];
        LogUtils.d(TAG,
            'receive EVENT_PREDOWNLOAD_ON_COMPLETE, taskID=$taskId ,url=$url');
        _preloadListeners[taskId]?.onCompleteListener?.call(taskId, url);
        _preloadListeners.remove(taskId);
        break;
      case TXVodPlayEvent.EVENT_PREDOWNLOAD_ON_ERROR:
        int tmpTaskId = map['tmpTaskId'] ?? -1;
        int taskId = map['taskId'];
        String url = map['url'];
        int code = map['code'] ?? 0;
        String msg = map['msg'] ?? '';
        LogUtils.d(TAG,
            'receive EVENT_PREDOWNLOAD_ON_ERROR, taskID=$taskId ,url=$url, code=$code , msg=$msg');
        if (tmpTaskId >= 0) {
          _fileIdBeforeStartListeners[tmpTaskId]!
              .onErrorListener
              ?.call(taskId, url, code, msg);
          _fileIdBeforeStartListeners.remove(tmpTaskId);
        } else {
          _preloadListeners[taskId]
              ?.onErrorListener
              ?.call(taskId, url, code, msg);
          _preloadListeners.remove(taskId);
        }
        break;
      case TXVodPlayEvent.EVENT_PREDOWNLOAD_ON_START:
        int tmpTaskId = map['tmpTaskId'];
        int taskId = map['taskId'];
        String fileId = map['fileId'] ?? '';
        String url = map['url'] ?? '';
        Map<dynamic, dynamic> bundle = map['params'] ?? {};
        LogUtils.d(
            TAG,
            'receive EVENT_PREDOWNLOAD_ON_START, tmpTaskId=$tmpTaskId, '
            'taskID=$taskId ,fileId=$fileId, url=$url , bundle=$bundle');
        if (_fileIdBeforeStartListeners[tmpTaskId] != null) {
          _preloadListeners[taskId] = _fileIdBeforeStartListeners[tmpTaskId]!;
          _preloadListeners[taskId]!
              .onStartListener
              ?.call(taskId, fileId, url, bundle);
          _fileIdBeforeStartListeners.remove(tmpTaskId);
        }
        break;
      default:
        break;
    }
  }
}

class _PreloadListener {
  FTXPredownlodOnCompleteListener? onCompleteListener;
  FTXPredownlodOnErrorListener? onErrorListener;
  FTXPredownlodOnStartListener? onStartListener;
  _PreloadListener(
      {this.onCompleteListener, this.onErrorListener, this.onStartListener});
}
