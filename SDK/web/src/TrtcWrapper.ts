// @ts-nocheck
import ListenerType from './ListenerType';
import TRTCCloud, { TRTCVideoRotation, TRTCVideoFillMode, TRTCVideoMirrorType, TRTCVideoStreamType, TRTCVideoResolution } from 'trtc-cloud-js-sdk';
import { logSuccess, noSupportFunction, getVideoResolution, logInfo, getFlutterArgs } from './common/TXUntils';
declare global {
  interface Window {
    InitLocalStreamCallBack: Function;
    DestoryLocalStreamCallBack: Function;
    LocalBeautyStream: any;
  }
}

export default class TrtcWrapper {
  private handler?: (event: string, data: string) => {};
  private _trtcCloud: TRTCCloud = null;
  private _framework: number = 7; // 罗盘上报
  private _localPlayOptions: any = {
    rotation: TRTCVideoRotation.TRTCVideoRotation0,
    fillMode: TRTCVideoFillMode.TRTCVideoFillMode_Fill,
    mirrorType: TRTCVideoMirrorType.TRTCVideoMirrorType_Enable,
  };
  // 远端预览模式, 所有远端流, 采用相同模式
  private _remotePlayOptions: any = {
    rotation: TRTCVideoRotation.TRTCVideoRotation0,
    fillMode: TRTCVideoFillMode.TRTCVideoFillMode_Fill, // webRtc 播放视频流默认使用 cover 模式(https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html#play)
    mirrorType: TRTCVideoMirrorType.TRTCVideoMirrorType_Disable, // 远端流默认关闭镜像, ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/RemoteStream.html#play
  };
  private _screenShareOptions: any = {
    videoResolution: TRTCVideoResolution.TRTCVideoResolution_1920_1080,
    videoFps: 15,
    videoBitrate: 1500,
    screenAudio: false, // 屏幕分享是否采集系统音频, 默认 false 不采集
  };
  constructor() {
    logSuccess('TrtcWrapper new come');
    this._trtcCloud = TRTCCloud.getTRTCShareInstance({
      frameWorkType: this._framework,
    });
    this._addTRTCEvents();
  }

  
  public getSDKVersion(): string {
    return this._trtcCloud.getSDKVersion();
  }
  public async sharedInstance() {}
  public async destroySharedInstance() {
    try {
      this._removeTRTCEvents();
      await this.exitRoom();
      logSuccess('destroySharedInstance success');
    } catch (error) {
      // ……
    }
  }
  // 房间start
  public async enterRoom(param: any) {
    try {
      logSuccess('begin enterRoom');
      const userId = getFlutterArgs(param, 'userId');
      const sdkAppId = getFlutterArgs(param, 'sdkAppId');
      const userSig = getFlutterArgs(param, 'userSig');
      const roomId = getFlutterArgs(param, 'roomId');
      const strRoomId = getFlutterArgs(param, 'strRoomId');
      const role = getFlutterArgs(param, 'role');
      const streamId = getFlutterArgs(param, 'streamId');
      const userDefineRecordId = getFlutterArgs(param, 'userDefineRecordId');
      const privateMapKey = getFlutterArgs(param, 'privateMapKey');
      const scene = getFlutterArgs(param, 'scene');
      const enterRoomParams = {
        userId,
        sdkAppId,
        userSig,
        roomId: typeof roomId === 'string' ? parseInt(roomId, 10) : roomId,
        strRoomId,
        role,
        streamId,
        userDefineRecordId,
        privateMapKey,
      };
      await this._trtcCloud?.enterRoom(enterRoomParams, scene);
    } catch (error) {
      // ……
    }
  }
  public async exitRoom() {
    try {
      await this.stopLocalPreview();
      await this._trtcCloud.stopLocalAudio();
      await this._trtcCloud.exitRoom();
      window.DestoryLocalStreamCallBack();
      logSuccess('exitRoom success');
    } catch (error) {
      // ……
    }
  }

  // 切换角色
  public async switchRole(_args) {
    try {
      const role = getFlutterArgs(_args, 'role');
      await this._trtcCloud.switchRole(role);
    } catch (error: any) {
      // ……
    }
  }

  public async switchRoom(_args) {
    noSupportFunction('switchRoom');
  }

  // 请求跨房通话
  public async connectOtherRoom(_args) {
    noSupportFunction('connectOtherRoom');
  }
  // 退出跨房通话
  public async disconnectOtherRoom(_args) {
    noSupportFunction('disconnectOtherRoom');
  }

   // 设置订阅模式（需要在进入房前设置才能生效）
   public async setDefaultStreamRecvMode(_args) {
    noSupportFunction('setDefaultStreamRecvMode');
  }

   // 创建子房间示例（用于多房间并发观看）
   public async createSubCloud(_args) {
    noSupportFunction('createSubCloud');
  }
  public async destroySubCloud(_args) {
    noSupportFunction('destroySubCloud');
  }

   // 开启本地音频的采集和发布 TODO: 后续支持参数
   public async startLocalAudio() {
    try {
      await this._trtcCloud.startLocalAudio();
    } catch (error) {
      // ……
    }
  }
  // 停止本地音频的采集和发布
  public async stopLocalAudio(_args) {
    try {
      await this._trtcCloud.stopLocalAudio();
    } catch (error) {
      // ……
    }
  }

    // 暂停/恢复发布本地的音频流
  public async muteLocalAudio(_args) {
    try {
      const mute = getFlutterArgs(_args, 'mute');
      await this._trtcCloud.muteLocalAudio(mute);
    } catch (error) {
      // ……
    }
  }


  // 设定本地音频的采集音量
  public async setAudioCaptureVolume(_args) {
    noSupportFunction('setAudioCaptureVolume');
  }
  // 设定SDK音频的播放音量
  public async setAudioPlayoutVolume(_args) {
    noSupportFunction('setAudioPlayoutVolume');
  }
  // 获取SDK音频的播放音量
  public getAudioPlayoutVolume(_args): Number {
    noSupportFunction('getAudioPlayoutVolume');
  }
  
   
  // 设置音频路由
  public async setAudioRoute(_args) {
    noSupportFunction('setAudioRoute');
  }

  // 开启本地摄像头的预览画面
  public async startLocalPreview(_element, viewId, _args) {
    try {
      await this._trtcCloud?.startLocalPreview(viewId);
      await this._trtcCloud?.setLocalRenderParams(this.getLocalPlayOptions());
    } catch (error) {
      // ……
    }
  }
  // 停止摄像头预览
  public async stopLocalPreview(_args) {
    try {
      await this._trtcCloud?.stopLocalPreview();
    } catch (error) {
      // ……
    }
  }
 
  // 暂停/恢复发布本地的视频流
  public async muteLocalVideo(_args) {
    try {
      const mute = getFlutterArgs(_args, 'mute');
      await this._trtcCloud.muteLocalVideo(mute);
    } catch (error) {
      // ……
    }
  }

  public async switchCamera(_args) {
    noSupportFunction('switchCamera');
  }
 
  // 订阅远端用户的视频流，并绑定视频渲染控件, streamType 视频流类型, 0 - 大流; 1 - 小流; 2 - 屏幕分享流
  public async startRemoteView(_element, _viewId, _args) {
    const userId = getFlutterArgs(_args, 'userId');
    const streamType = getFlutterArgs(_args, 'streamType');
    try {
      // ref: https://tapd.woa.com/20396022/prong/stories/view/1020396022883872355
      await this._trtcCloud?.startRemoteView(userId, _viewId, streamType);
      // const videoRenderParams = this._tuiCallEngine.getRemotePlayOptions();
      // await this._trtcCloud?.setRemoteRenderParams(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, videoRenderParams);
    } catch (error) {
      // ……
    }
  }
  // 停止订阅远端用户的视频流，并释放渲染控件
  public async stopRemoteView(_args) {
    const userId = getFlutterArgs(_args, 'userId');
    try {
      await this._trtcCloud?.stopRemoteView(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
    } catch (error) {
      // ……
    }
  }
  // 停止订阅所有远端用户的视频流，并释放全部渲染资源
  public async stopAllRemoteView(_args) {
    try {
      this._trtcCloud.stopAllRemoteView();
    } catch (error) {
      // ……
    }
  }
  // 设置视频编码器的编码参数 // TODO: 确认: 入参需要调整
  public async setVideoEncoderParam(_args) {
    try {
      const config = JSON.parse(_args); // TODO: 参数格式是否符合？
      config && (await this._trtcCloud?.setVideoEncoderParam(config));
    } catch (error) {
      // ……
    }
  }


  // 暂停/恢复订阅远端用户的视频流
  // TODO: 上个版本实现
  public async muteRemoteVideoStream(_args) {
    noSupportFunction('muteRemoteVideoStream'); // trtcCloud 无接口
  }
  // 暂停/恢复订阅所有远端用户的视频流
    // TODO: 上个版本实现
  public async muteAllRemoteVideoStreams(_args) {
    noSupportFunction('muteAllRemoteVideoStreams'); // trtcCloud 无接口
  }
  // 暂停/恢复播放远端的音频流
  public async muteRemoteAudio(_args) {
    try {
      const mute = getFlutterArgs(_args, 'mute');
      const userId = getFlutterArgs(_args, 'userId');
      await this._trtcCloud.muteRemoteAudio(userId, mute);
    } catch (error) {
      // ……
    }
  }
  // 暂停/恢复播放所有远端用户的音频流
  public async muteAllRemoteAudio(_args) {
    try {
      const mute = getFlutterArgs(_args, 'mute');
      await this._trtcCloud.muteAllRemoteAudio(mute);
    } catch (error) {
      // ……
    }
  }
  // 启用音量大小提示
  public enableAudioVolumeEvaluation(_args): Number {
    try {
      const intervalMs = getFlutterArgs(_args, 'intervalMs');
      this._trtcCloud.enableAudioVolumeEvaluation(intervalMs);
      return 0;
    } catch (error) {
      // ……
    }
  }
  // 设定某一个远端用户的声音播放音量
  public setRemoteAudioVolume(_args) {
    try {
      const userId = getFlutterArgs(_args, 'userId');
      const volume = getFlutterArgs(_args, 'volume');  
      this._trtcCloud.setRemoteAudioVolume(userId, volume);
    } catch (error) {
      // ……
    }
  }
  // 开启大小画面双路编码模式. 请在 enterRoom 之后，开启摄像头之前调用
  public async enableEncSmallVideoStream(_args): Number {
    try {
      const enable = getFlutterArgs(_args, 'enable');
      const params = getFlutterArgs(_args, 'params'); // videoResolution, videoFps, videoBitrate
      await this._trtcCloud.enableSmallVideoStream(enable, params);
    } catch (error) {
      // ……
    }
  }
  public async setLogLevel(_args) {
    noSupportFunction('setLogLevel'); // trtcCloud 无接口
  }
  // 开始向腾讯云直播 CDN 上发布音视频流
  public async startPublishing(_args) {
    noSupportFunction('startPublishing'); // trtcCloud 无接口
  }
  // 停止向腾讯云直播 CDN 上发布音视频流
  // TODO:上个版本有实现
  public async stopPublishing(_args) {
    noSupportFunction('stopPublishing'); // trtcCloud 无接口
  }
  // 开始向非腾讯云 CDN 上发布音视频流
  // TODO:上个版本有实现
  public async startPublishCDNStream(_args) {
    noSupportFunction('startPublishCDNStream'); // trtcCloud 无接口
  }
  // 停止向非腾讯云 CDN 上发布音视频流
  // TODO:上个版本有实现
  public async stopPublishCDNStream(_args) {
    noSupportFunction('stopPublishCDNStream'); // trtcCloud 无接口
  }
  // 设置云端混流的排版布局和转码参数
  // TODO:上个版本有实现
  public async setMixTranscodingConfig(_args) {
    noSupportFunction('setMixTranscodingConfig'); // trtcCloud 无接口
  }
  // TODO: 确认: 参数需要调整
  public async startScreenCapture(_args) {
    try {
      const viewId = getFlutterArgs(_args, 'viewId');
      const streamType = getFlutterArgs(_args, 'streamType');
      const screenShareParams = this.getScreenShareOptions();
      await this._trtcCloud.startScreenShare(viewId, streamType, screenShareParams);
    } catch (error) {
      // ……
    }
  }
  // 停止屏幕分享
  public async stopScreenCapture(_args) {
    try {
      await this._trtcCloud.stopScreenShare();
    } catch (error) {
      // ……
    }
  }
  // 暂停屏幕分享
  // TODO:上个版本有实现
  public async pauseScreenCapture(_args) {
    noSupportFunction('pauseScreenCapture'); // trtcCloud 无接口
  }
  // 恢复屏幕分享
  public async resumeScreenCapture(_args) {
    noSupportFunction('resumeScreenCapture'); // trtcCloud 无接口
  }
  // ==============================【设备接口】==================================
  public async getDevicesList(_args) {
    try {
      const type = getFlutterArgs(_args, 'type');
      var deviceList = [];
      switch (type) {
        case 0: {
          deviceList = await this._trtcCloud.getMicDevicesList();
          break;
        }
        case 1: {
          deviceList = await this._trtcCloud.getSpeakerDevicesList();
          break;
        }
        case 2: {
          deviceList = await this._trtcCloud.getCameraDevicesList();
          break;
        }
      }
      const map = { deviceList, count: deviceList.length };
      return JSON.stringify(map);
    } catch (error) {
      // ……
    }
  }
  public async setCurrentDevice(_args) {
    try {
      const type = getFlutterArgs(_args, 'type');
      const deviceId = getFlutterArgs(_args, 'deviceId');
      if (type === 1) {
        deviceId && await this._trtcCloud.setCurrentMicDevice(deviceId);
      }
      if (type === 2) {
        deviceId && await this._trtcCloud.setCurrentCameraDevice(deviceId);
      }
    } catch (error) {
      // ……
    }
  }
  public async getCurrentDevice(_args) {
    const type = getFlutterArgs(_args, 'type');
    let deviceInfo = {};
    try {
      switch (type) {
        case 0: {
          deviceInfo = await this._trtcCloud.getCurrentMicDevice();
          break;
        }
        case 1: {
          deviceInfo = await this._trtcCloud.getCurrentSpeakerDevice();
          break;
        }
        case 2: {
          deviceInfo = await this._trtcCloud.getCurrentCameraDevice();
          break;
        }
      }
      return JSON.stringify(deviceInfo);
    } catch (error) {
      // ……
    }
  }
  
  // TODO: 确认: 下面这些还需要返回 0 吗
  public async setCurrentDeviceVolume(_args) {
    noSupportFunction('setCurrentDeviceVolume');
  }
  public async getCurrentDeviceVolume(_args) {
    noSupportFunction('getCurrentDeviceVolume');
  }
  public async setCurrentDeviceMute(_args) {
    noSupportFunction('setCurrentDeviceMute');
  }
  public async getCurrentDeviceMute(_args) {
    noSupportFunction('getCurrentDeviceMute');
  }
  public async startCameraDeviceTest(_args) {
    noSupportFunction('startCameraDeviceTest');
  }
  public async stopCameraDeviceTest(_args) {
    noSupportFunction('stopCameraDeviceTest');
  }
  public async startMicDeviceTest(_args) {
    noSupportFunction('startMicDeviceTest');
  }
  public async stopMicDeviceTest(_args) {
    noSupportFunction('stopMicDeviceTest');
  }
  public async startSpeakerDeviceTest(_args) {
    noSupportFunction('startSpeakerDeviceTest');
  }
  public async stopSpeakerDeviceTest(_args) {
    noSupportFunction('stopSpeakerDeviceTest');
  }
  // ==============================【not Support】==================================
  // 设置本地画面的渲染参数
  public async setLocalRenderParams(_args) {
    noSupportFunction('setLocalRenderParams');
  }
 
  public async updateLocalView(_element, _viewId, _args) {
    noSupportFunction('updateLocalView');
  }
  public async updateRemoteView(_element, _viewId, _args) {
    noSupportFunction('updateLocalView');
  }
  public async setWatermark(_args) {
    noSupportFunction('setWatermark');
  }
  // 获取本地音频的采集音量
  public getAudioCaptureVolume(_args): Number {
    noSupportFunction('getAudioCaptureVolume'); // 通过音量事件获取即可
  }
  // 切换指定远端用户的大小画面
  // TODO: 上个版本有实现
  public setRemoteVideoStreamType(_args): Number {
    noSupportFunction('setAudioCaptureVolume');
  }
  // ==============================【录音相关】==================================
  public async startAudioRecording(_args) {}
  public async stopAudioRecording(_args) {}
  public async startLocalRecording(_args) {}
  public async stopLocalRecording(_args) {}
  // ==============================【背景音相关】==================================
  // TODO:上个版本有实现
  public async startPlayMusic(_args) {
    noSupportFunction('startPlayMusic'); // trtcCloud 无接口
    resumeScreenCapture
  }
  public async stopPlayMusic() {
    noSupportFunction('stopPlayMusic'); // trtcCloud 无接口
  }
  public async resumePlayMusic(_args) {
    noSupportFunction('resumePlayMusic'); // trtcCloud 无接口
  }
  public async pausePlayMusic(_args) {
    noSupportFunction('pausePlayMusic'); // trtcCloud 无接口
  }
  // ==============================【日志相关】==================================
  // 	启用/禁用控制台日志打印
  public async setConsoleEnabled(_args) {
    const enabled = getFlutterArgs(_args, 'enabled');
    enabled ? TRTC.Logger.enableUploadLog() : TRTC.Logger.disableUploadLog();
  }
  // 	启用/禁用日志的本地压缩
  public async setLogCompressEnabled(_args) {}
  // 设置本地日志的保存路径
  public async setLogDirPath(_args) {}
  // 	设置日志回调
  public async setLogDelegate(_args) {}
  // 	显示仪表盘
  public async showDebugView(_args) {}
  // 	设置仪表盘的边距
  public async setDebugViewMargin(_args) {}
  // 调用实验性接口
  public async callExperimentalAPI(_args) {}
  // ==============================【set、get】==================================
  public setLocalPlayOptions(playOption): void {
    this._localPlayOptions = {
      ...this._localPlayOptions,
      ...playOption,
    };
  }
  public getLocalPlayOptions() {
    return this._localPlayOptions;
  }
  public setRemotePlayOptions(playOption = {}) {
    this._remotePlayOptions = {
      ...this._remotePlayOptions,
      ...playOption,
    };
  }
  public getRemotePlayOptions() {
    return this._remotePlayOptions || {};
  }
  public setScreenShareOptions(screenShareOption = {}) {
    this._screenShareOptions = {
      ...this._screenShareOptions,
      ...screenShareOption,
    };
  }
  public getScreenShareOptions() {
    return this._screenShareOptions;
  }
  // ==============================【事件相关】==================================
  public setEventHandler(handler: (event: string) => {}) {
    this.handler = handler;
  }
  private _emitEvent(methodName: ListenerType, data: any) {
    if (data instanceof Array || typeof data === 'object') {
      data = JSON.stringify(data);
    }
    this.handler?.call(this, methodName.toString(), data);
  }
  private _addTRTCEvents() {
    this._trtcCloud?.on('onEnterRoom', async (result: number) => {
      result > 0 && logInfo(`enter room success, time consuming: ${result}`);
    });
    this._trtcCloud?.on('onExitRoom', async (reason: number) => {
      // 离开房间原因，0：主动调用 exitRoom 退房；1：被服务器踢出当前房间；2：当前房间整个被解散
      logInfo(`exit room, reason: ${reason}`);
    });
    this._trtcCloud?.on('onRemoteUserEnterRoom', async (userId: string) => {
      this._emitEvent(ListenerType.onRemoteUserEnterRoom, userId);
    });
    this._trtcCloud?.on('onRemoteUserLeaveRoom', async (userId: string, reason: number) => {
      this._emitEvent(ListenerType.onRemoteUserLeaveRoom, { userId, reason });
    });
    this._trtcCloud?.on('onUserVideoAvailable', (userId: string, available: boolean) => {
      this._emitEvent(ListenerType.onUserVideoAvailable, { userId, available });
    });
    this._trtcCloud?.on('onUserAudioAvailable', (userId: string, available: boolean) => {
      this._emitEvent(ListenerType.onUserAudioAvailable, { userId, available });
    });
    this._trtcCloud?.on('onUserSubStreamAvailable', (userId: string, available: boolean) => {
      this._emitEvent(ListenerType.onUserSubStreamAvailable, { userId, available });
    });
    this._trtcCloud?.on('onUserVoiceVolume', (userVolumes: any[]) => {
      this._emitEvent(ListenerType.onUserVoiceVolume, {
        userVolumes: userVolumes,
        totalVolume: 0,
      });
    });
    this._trtcCloud?.on('onError', (errCode: number, errMsg: string) => {
      this._emitEvent(ListenerType.onError, { errCode, errMsg });
    });
  }
  private _removeTRTCEvents() {
    this._trtcCloud?.removeAllListeners(); // TRTCCloud 继承 eventemitter3
  }
}
