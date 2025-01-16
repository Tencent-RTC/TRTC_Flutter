enum ListenerType {
  /// 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示
  ///
  /// 参数param：
  ///
  /// errCode	错误码
  ///
  /// errMsg	错误信息
  ///
  /// extraInfo	扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
  onError = 'onError',

  /// 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败。
  ///
  /// 参数param：
  ///
  /// warningCode	错误码
  ///
  /// warningMsg	警告信息
  ///
  /// extraInfo	扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
  onWarning = 'onWarning',

  /// 已加入房间的回调
  ///
  /// 调用 TRTCCloud 中的 enterRoom() 接口执行进房操作后，会收到来自 SDK 的 onEnterRoom(result) 回调：
  ///
  /// 如果加入成功，result 会是一个正数（result > 0），代表加入房间的时间消耗，单位是毫秒（ms）。
  ///
  /// 如果加入失败，result 会是一个负数（result < 0），代表进房失败的错误码。
  ///
  /// 参数param：
  ///
  /// result > 0 时为进房耗时（ms），result < 0 时为进房错误码
  onEnterRoom = 'onEnterRoom',

  /// 离开房间的事件回调
  ///
  /// 调用 TRTCCloud 中的 exitRoom() 接口会执行退出房间的相关逻辑，例如释放音视频设备资源和编解码器资源等。 待资源释放完毕，SDK 会通过 onExitRoom() 回调通知到您。
  ///
  /// 如果您要再次调用 enterRoom() 或者切换到其他的音视频 SDK，请等待 onExitRoom() 回调到来之后再执行相关操作。 否则可能会遇到音频设备被占用等各种异常问题。
  ///
  /// 参数param：
  ///
  /// reason	离开房间原因，0：主动调用 exitRoom 退房；1：被服务器踢出当前房间；2：当前房间整个被解散。
  onExitRoom = 'onExitRoom',

  /// 切换角色的事件回调
  ///
  /// 调用 TRTCCloud 中的 switchRole() 接口会切换主播和观众的角色，该操作会伴随一个线路切换的过程， 待 SDK 切换完成后，会抛出 onSwitchRole() 事件回调。
  ///
  /// 参数param：
  ///
  /// errCode	错误码，0代表切换成功
  ///
  /// errMsg	错误信息。
  onSwitchRole = 'onSwitchRole',

  /// 有用户加入当前房间。
  ///
  /// 出于性能方面的考虑，在两种不同的应用场景下，该通知的行为会有差别：
  ///
  /// 通话场景（TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL 和 TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL）：该场景下用户没有角色的区别，任何用户进入房间都会触发该通知。
  ///
  /// 直播场景（TRTCCloudDef.TRTC_APP_SCENE_LIVE 和 TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM）：该场景不限制观众的数量，如果任何用户进出都抛出回调会引起很大的性能损耗，所以该场景下只有主播进入房间时才会触发该通知，观众进入房间不会触发该通知。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  onRemoteUserEnterRoom = 'onRemoteUserEnterRoom',

  /// 有用户离开当前房间。
  ///
  /// 与 onRemoteUserEnterRoom 相对应，在两种不同的应用场景下，该通知的行为会有差别：
  ///
  /// 通话场景（TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL 和 TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL）：该场景下用户没有角色的区别，任何用户的离开都会触发该通知。
  ///
  /// 直播场景（TRTCCloudDef.TRTC_APP_SCENE_LIVE 和 TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM）：只有主播离开房间时才会触发该通知，观众离开房间不会触发该通知。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// reason	离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
  onRemoteUserLeaveRoom = 'onRemoteUserLeaveRoom',

  /// 请求跨房通话（主播 PK）的结果回调
  ///
  /// 调用 TRTCCloud 中的 connectOtherRoom() 接口会将两个不同房间中的主播拉通视频通话，也就是所谓的“主播PK”功能。 调用者会收到 onConnectOtherRoom() 回调来获知跨房通话是否成功， 如果成功，两个房间中的所有用户都会收到 PK 主播的 onUserVideoAvailable() 回调。
  ///
  /// 参数param：
  ///
  /// userId	要 PK 的目标主播 userid。
  ///
  /// errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
  ///
  /// errMsg 错误信息
  onConnectOtherRoom = 'onConnectOtherRoom',

  /// 结束跨房通话（主播 PK）的结果回调
  onDisConnectOtherRoom = 'onDisConnectOtherRoom',

  /// 切换房间 (switchRoom) 的结果回调
  ///
  /// 参数param：
  ///
  /// errCode 错误码
  ///
  /// errMsg 错误信息
  onSwitchRoom = 'onSwitchRoom',

  /// 远端用户是否存在可播放的主路画面（一般用于摄像头）
  ///
  /// 当您收到 onUserVideoAvailable(userId, true) 通知时，表示该路画面已经有可用的视频数据帧到达。 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
  ///
  /// 当您收到 onUserVideoAvailable(userId, false) 通知时，表示该路远程画面已经被关闭，可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// available	画面是否开启
  onUserVideoAvailable = 'onUserVideoAvailable',

  /// 远端用户是否存在可播放的辅路画面（一般用于屏幕分享）
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// available	屏幕分享是否开启
  onUserSubStreamAvailable = 'onUserSubStreamAvailable',

  /// 远端用户是否存在可播放的音频数据
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// available	声音是否开启
  onUserAudioAvailable = 'onUserAudioAvailable',

  /// 开始渲染本地或远程用户的首帧画面
  ///
  /// 如果 userId 为 null，代表开始渲染本地采集的摄像头画面，需要您先调用 startLocalPreview 触发。 如果 userId 不为 null，代表开始渲染远程用户的首帧画面，需要您先调用 startRemoteView 触发。
  ///
  /// 只有当您调用 startLocalPreview()、startRemoteView() 或 startRemoteSubStreamView() 之后，才会触发该回调。
  ///
  /// 参数param：
  ///
  /// userId	本地或远程用户 ID，如果 userId == null 代表本地，userId != null 代表远程。
  ///
  /// streamType	视频流类型：摄像头或屏幕分享。
  ///
  /// width	画面宽度
  ///
  /// height	画面高度
  onFirstVideoFrame = 'onFirstVideoFrame',

  /// 开始播放远程用户的首帧音频（本地声音暂不通知）。
  ///
  /// 参数param：
  ///
  /// userId	远程用户 ID。
  onFirstAudioFrame = 'onFirstAudioFrame',

  /// 首帧本地音频数据已经被送出。
  ///
  /// SDK 会在 enterRoom() 并 startLocalPreview() 成功后开始摄像头采集，并将采集到的画面进行编码。 当 SDK 成功向云端送出第一帧视频数据后，会抛出这个回调事件。
  ///
  /// 参数param：
  ///
  /// streamType	视频流类型，大画面、小画面或辅流画面（屏幕分享）
  onSendFirstLocalVideoFrame = 'onSendFirstLocalVideoFrame',

  /// 首帧本地音频数据已经被送出
  ///
  /// SDK 会在 enterRoom() 并 startLocalAudio() 成功后开始麦克风采集，并将采集到的声音进行编码。 当 SDK 成功向云端送出第一帧音频数据后，会抛出这个回调事件。
  onSendFirstLocalAudioFrame = 'onSendFirstLocalAudioFrame',

  /// 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量。
  ///
  /// userId 为本地用户 ID 代表自己当前的视频质量
  ///
  /// 参数param：
  ///
  /// localQuality	上行网络质量
  ///
  /// remoteQuality	下行网络质量
  onNetworkQuality = 'onNetworkQuality',

  /// 技术指标统计回调
  ///
  /// 如果您是熟悉音视频领域相关术语，可以通过这个回调获取 SDK 的所有技术指标。 如果您是首次开发音视频相关项目，可以只关注 onNetworkQuality 回调。
  ///
  /// 注意：每2秒回调一次
  ///
  /// 参数param：
  ///
  /// statics	状态数据
  onStatistics = 'onStatistics',

  /// SDK 跟服务器的连接断开
  onConnectionLost = 'onConnectionLost',

  /// SDK 尝试重新连接到服务器。
  onTryToReconnect = 'onTryToReconnect',

  /// SDK 跟服务器的连接恢复。
  onConnectionRecovery = 'onConnectionRecovery',

  /// 服务器测速的回调，SDK 对多个服务器 IP 做测速，每个 IP 的测速结果通过这个回调通知。
  ///
  /// 参数param：
  ///
  /// currentResult	当前完成的测速结果
  ///
  /// finishedCount	已完成测速的服务器数量
  ///
  /// totalCount	需要测速的服务器总数量
  onSpeedTest = 'onSpeedTest',

  /// 摄像头准备就绪。
  onCameraDidReady = 'onCameraDidReady',

  /// 麦克风准备就绪
  onMicDidReady = 'onMicDidReady',

  /// 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量。
  ///
  /// 您可以通过调用 TRTCCloud 中的 enableAudioVolumeEvaluation 接口来开关这个回调或者设置它的触发间隔。 需要注意的是，调用 enableAudioVolumeEvaluation 开启音量回调后，无论频道内是否有人说话，都会按设置的时间间隔调用这个回调; 如果没有人说话，则 userVolumes 为空，totalVolume 为0。
  ///
  /// 注意：userId 为本地用户 ID 时表示自己的音量，userVolumes 内仅包含正在说话（音量不为0）的用户音量信息。
  ///
  /// 参数param：
  ///
  /// userVolumes	所有正在说话的房间成员的音量，取值范围0 - 100。
  ///
  /// totalVolume	所有远端成员的总音量, 取值范围0 - 100。
  onUserVoiceVolume = 'onUserVoiceVolume',

  /// 收到自定义消息回调
  ///
  /// 当房间中的某个用户使用 sendCustomCmdMsg 发送自定义消息时，房间中的其它用户可以通过 onRecvCustomCmdMsg 接口接收消息
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// cmdID	命令 ID
  ///
  /// seq	消息序号
  ///
  /// message	消息数据
  onRecvCustomCmdMsg = 'onRecvCustomCmdMsg',

  /// 自定义消息丢失回调
  ///
  /// 实时音视频使用 UDP 通道，即使设置了可靠传输（reliable）也无法确保100%不丢失，只是丢消息概率极低，能满足常规可靠性要求。 在发送端设置了可靠传输（reliable）后，SDK 都会通过此回调通知过去时间段内（通常为5s）传输途中丢失的自定义消息数量统计信息。
  ///
  /// 注意：
  ///
  /// 只有在发送端设置了可靠传输（reliable），接收方才能收到消息的丢失回调
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// cmdID	数据流 ID
  ///
  /// errCode	错误码，当前版本为-1
  ///
  /// missed	丢失的消息数量
  onMissCustomCmdMsg = 'onMissCustomCmdMsg',

  /// 收到 SEI 消息的回调
  ///
  /// 当房间中的某个用户使用 sendSEIMsg 发送数据时，房间中的其它用户可以通过 onRecvSEIMsg 接口接收数据。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// message	数据
  onRecvSEIMsg = 'onRecvSEIMsg',

  /// 开始向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 startPublishing() 接口
  ///
  /// 参数param：
  ///
  /// errCode	0表示成功，其余值表示失败
  ///
  /// errMsg	具体错误原因
  onStartPublishing = 'onStartPublishing',

  /// 停止向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 stopPublishing() 接口
  ///
  /// 参数param：
  ///
  /// errCode	0表示成功，其余值表示失败
  ///
  /// errMsg	具体错误原因
  onStopPublishing = 'onStopPublishing',

  /// 启动旁路推流到 CDN 完成的回调
  ///
  /// 对应于 TRTCCloud 中的 startPublishCDNStream() 接口
  ///
  /// 注意：Start 回调如果成功，只能说明转推请求已经成功告知给腾讯云，如果目标 CDN 有异常，还是有可能会转推失败。
  ///
  /// 参数param：
  ///
  /// errCode	0表示成功，其余值表示失败
  ///
  /// errMsg	具体错误原因
  onStartPublishCDNStream = 'onStartPublishCDNStream',

  /// 停止旁路推流到 CDN 完成的回调
  ///
  /// 对应于 TRTCCloud 中的 stopPublishCDNStream() 接口
  ///
  /// 参数param：
  ///
  /// errCode	0表示成功，其余值表示失败
  ///
  /// errMsg	具体错误原因
  onStopPublishCDNStream = 'onStopPublishCDNStream',

  /// 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口。
  ///
  /// 参数param：
  ///
  /// errCode	0表示成功，其余值表示失败
  ///
  /// errMsg	具体错误原因
  onSetMixTranscodingConfig = 'onSetMixTranscodingConfig',

  /// 背景音乐开始播放
  onMusicObserverStart = 'onMusicObserverStart',

  /// 背景音乐的播放进度
  onMusicObserverPlayProgress = 'onMusicObserverPlayProgress',

  /// 背景音乐已播放完毕
  onMusicObserverComplete = 'onMusicObserverComplete',

  /// 截图完成时回调
  ///
  /// 参数
  ///
  /// errorCode为0表示截图成功，其他值表示失败
  onSnapshotComplete = 'onSnapshotComplete',

  ///当屏幕分享开始时，SDK 会通过此回调通知
  onScreenCaptureStarted = 'onScreenCaptureStarted',

  ///当屏幕分享暂停时，SDK 会通过此回调通知
  ///
  ///参数
  ///
  /// reason	原因，0：用户主动暂停；1：屏幕窗口不可见暂停
  ///
  /// 注意：回调的值只针对ios生效
  onScreenCapturePaused = 'onScreenCapturePaused',

  ///当屏幕分享恢复时，SDK 会通过此回调通知
  ///
  ///参数
  ///
  /// reason	恢复原因，0：用户主动恢复；1：屏幕窗口恢复可见从而恢复分享
  ///
  /// 注意：回调的值只针对ios生效
  onScreenCaptureResumed = 'onScreenCaptureResumed',

  ///当屏幕分享停止时，SDK 会通过此回调通知
  ///
  ///参数
  ///
  ///reason	停止原因，0：用户主动停止；1：屏幕窗口关闭导致停止
  onScreenCaptureStoped = 'onScreenCaptureStoped',

  /// 本地设备通断回调
  ///
  /// 注意：该回调仅支持windows和Mac平台
  ///
  /// 参数
  ///
  /// deviceId	设备 ID
  ///
  /// type 设备类型
  ///
  /// state 事件类型
  onDeviceChange = 'onDeviceChange',

  /// 麦克风测试音量回调
  ///
  /// 麦克风测试接口 startMicDeviceTest 会触发这个回调
  ///
  /// 注意：该回调仅支持windows和Mac平台
  ///
  /// 参数：
  ///
  /// volume 音量值，取值范围0 - 100
  onTestMicVolume = 'onTestMicVolume',

  /// 扬声器测试音量回调
  ///
  /// 扬声器测试接口 startSpeakerDeviceTest 会触发这个回调
  ///
  /// 注意：该回调仅支持windows和Mac平台
  ///
  /// 参数：
  ///
  /// volume 音量值，取值范围0 - 100
  onTestSpeakerVolume = 'onTestSpeakerVolume',
}
export default ListenerType;
