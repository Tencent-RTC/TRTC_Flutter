package com.tencent.trtcplugin.listener;

/**
 * 回调通知枚举
 */

public enum CallBackNoticeEnum {
    /**
     * 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示
     */
    onError,
    /**
     * 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败。
     */
    onWarning,
    /**
     * 已加入房间的回调
     */
    onEnterRoom,
    /**
     * 离开房间的事件回调
     */
    onExitRoom,
    /**
     * 请求跨房通话（主播 PK）的结果回调
     */
    onConnectOtherRoom,
    /**
     * 结束跨房通话（主播 PK）的结果回调
     */
    onDisConnectOtherRoom,
    /**
     * 切换房间 (switchRoom) 的结果回调
     */
    onSwitchRoom,
    /**
     * 收到自定义消息回调
     */
    onRecvCustomCmdMsg,
    /**
     * 自定义消息丢失回调
     */
    onMissCustomCmdMsg,
    /**
     * 收到 SEI 消息的回调
     */
    onRecvSEIMsg,
    /**
     * 开始向腾讯云的直播 CDN 推流的回调
     */
    onStartPublishing,
    /**
     * 停止向腾讯云的直播 CDN 推流的回调
     */
    onStopPublishing,
    /**
     * 启动旁路推流到 CDN 完成的回调
     */
    onStartPublishCDNStream,
    /**
     * 停止旁路推流到 CDN 完成的回调
     */
    onStopPublishCDNStream,
    /**
     * 切换角色的事件回调
     */
    onSwitchRole,
    /**
     * 有用户加入当前房间。
     */
    onRemoteUserEnterRoom,
    /**
     * 有用户离开当前房间。
     */
    onRemoteUserLeaveRoom,
    /**
     * 远端用户是否存在可播放的主路画面（一般用于摄像头）
     */
    onUserVideoAvailable,
    /**
     * 远端用户是否存在可播放的辅路画面（一般用于屏幕分享）
     */
    onUserSubStreamAvailable,
    /**
     * 远端用户是否存在可播放的音频数据
     */
    onUserAudioAvailable,
    /**
     * 开始渲染本地或远程用户的首帧画面
     */
    onFirstVideoFrame,
    /**
     * 开始播放远程用户的首帧音频（本地声音暂不通知）。
     */
    onFirstAudioFrame,
    /**
     * 首帧本地音频数据已经被送出。
     */
    onSendFirstLocalVideoFrame,
    /**
     * 首帧本地视频数据已经被送出。
     */
    onSendFirstLocalAudioFrame,
    /**
     * 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量。
     */
    onNetworkQuality,
    /**
     * 技术指标统计回调。
     */
    onStatistics,
    /**
     * SDK 跟服务器的连接断开
     */
    onConnectionLost,
    /**
     * SDK 尝试重新连接到服务器。
     */
    onTryToReconnect,
    /**
     * SDK 跟服务器的连接恢复。
     */
    onConnectionRecovery,
    /**
     * 服务器测速的回调，SDK 对多个服务器 IP 做测速，每个 IP 的测速结果通过这个回调通知。
     */
    onSpeedTest,
    onSpeedTestResult,
    /**
     * 摄像头准备就绪。
     */
    onCameraDidReady,
    /**
     * 麦克风准备就绪
     */
    onMicDidReady,
    /**
     * 音频路由发生变化，音频路由即声音由哪里输出（扬声器、听筒）。
     */
    onAudioRouteChanged,
    /**
     * 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量。
     */
    onUserVoiceVolume,
    /**
     * 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口。
     */
    onSetMixTranscodingConfig,
    /**
     * 有日志打印时的回调
     */
    onLog,
    /**
     * 背景音乐开始播放
     */
    onMusicObserverStart,
    /**
     * 背景音乐的播放进度
     */
    onMusicObserverPlayProgress,
    /**
     * 背景音乐已播放完毕
     */
    onMusicObserverComplete,
    /**
     * 截图完成时回调
     */
    onSnapshotComplete,
    /**
     * 当屏幕分享开始时，SDK 会通过此回调通知
     */
    onScreenCaptureStarted,
    /**
     * 当屏幕分享暂停时，SDK 会通过此回调通知
     */
    onScreenCapturePaused,
    /**
     * 当屏幕分享恢复时，SDK 会通过此回调通知
     */
    onScreenCaptureResumed,
    /**
     * 当屏幕分享停止时，SDK 会通过此回调通知
     */
    onScreenCaptureStoped,
    /**
     * 当本地录制任务已经开始时，SDK 会通过此回调通知
     */
    onLocalRecordBegin,

    /**
     * 当本地录制任务进行时，SDK 会周期性通过此回调通知
     * 您可以在 startLocalRecording 时设定本事件回调的抛出间隔。
     */
    onLocalRecording,

    /**
     *  当您开启分片录制时，每完成一个分片，SDK 会通过此回调通知
     */
    onLocalRecordFragment,
    /**
     * 当本地录制任务已经结束，SDK 会通过此回调通知
     */
    onLocalRecordComplete,
    /**
     * 开始CDN推流，SDK 会通过此回调通知
     */
    onStartPublishMediaStream,
    /**
     * 更新CDN推流，SDK 会通过此回调通知
     */
    onUpdatePublishMediaStream,
    /**
     * 停止CDN推流，SDK 会通过此回调通知
     */
    onStopPublishMediaStream
}