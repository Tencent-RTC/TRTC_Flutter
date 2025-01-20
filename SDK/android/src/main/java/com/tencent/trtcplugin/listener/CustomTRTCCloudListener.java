package com.tencent.trtcplugin.listener;

import android.os.Bundle;

import com.google.gson.Gson;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.TRTCStatistics;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

/**
 * 腾讯云音视频通信监听器
 */
public class CustomTRTCCloudListener extends TRTCCloudListener {

    /**
     * 监听器回调的方法名
     */
    private static final String LISTENER_FUNC_NAME = "onListener";

    /**
     * 与Flutter的通信管道
     */
    private MethodChannel channel;

    public CustomTRTCCloudListener(MethodChannel channel) {
        this.channel = channel;
    }

    public void release() {
        channel = null;
    }

    /**
     * 调用监听器
     *
     * @param type   类型
     * @param params 参数
     */
    private void invokeListener(CallBackNoticeEnum type, Object params) {
        Gson gson = new Gson();
        Map<String, Object> resultParams = new HashMap();
        resultParams.put("type", type);
        if (params != null) {
            resultParams.put("params", params);
        }
        channel.invokeMethod(LISTENER_FUNC_NAME, gson.toJson(resultParams));
    }

    //背景音乐开始播放
    public void onMusicObserverStart(int i, int i1) {
        Map<String, Object> params = new HashMap();
        params.put("id", i);
        params.put("errCode", i1);
        this.invokeListener(CallBackNoticeEnum.onMusicObserverStart, params);
    }

    //背景音乐的播放进度
    public void onMusicObserverPlayProgress(int i,long l,long l1) {
        Map<String, Object> params = new HashMap();
        params.put("id", i);
        params.put("curPtsMS", l);
        params.put("durationMS", l1);
        this.invokeListener(CallBackNoticeEnum.onMusicObserverPlayProgress, params);
    }

    //背景音乐结束播放
    public void onMusicObserverComplete(int i, int i1) {
        Map<String, Object> params = new HashMap();
        params.put("id", i);
        params.put("errCode", i1);
        this.invokeListener(CallBackNoticeEnum.onMusicObserverComplete, params);
    }

    //截图完成时回调
    public void onSnapshotComplete(int errCode,String errMsg, String path) {
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        params.put("path", path);
        this.invokeListener(CallBackNoticeEnum.onSnapshotComplete, params);
    }

     /**
     * 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示
     */
     @Override
     public void onError(int errCode, String errMsg, Bundle extraInfo) {
         super.onError(errCode, errMsg, extraInfo);
         Map<String, Object> params = new HashMap();
         params.put("errCode", errCode);
         params.put("errMsg", errMsg);
        //  params.put("extraInfo", extraInfo);
         this.invokeListener(CallBackNoticeEnum.onError, params);
     }

    /**
     * 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败。
     */
    @Override
    public void onWarning(int i, String s, Bundle extraInfo) {
        super.onWarning(i, s, extraInfo);
        Map<String, Object> params = new HashMap();
        params.put("warningCode", i);
        params.put("warningMsg", s);
        // params.put("extraInfo", extraInfo);
        this.invokeListener(CallBackNoticeEnum.onWarning, params);
    }

    /**
     * 已加入房间的回调
     */
    @Override
    public void onEnterRoom(long l) {
        super.onEnterRoom(l);
        this.invokeListener(CallBackNoticeEnum.onEnterRoom, l);
    }

    /**
     * 离开房间的事件回调
     */
    @Override
    public void onExitRoom(int i) {
        super.onExitRoom(i);
        this.invokeListener(CallBackNoticeEnum.onExitRoom, i);
    }

    /**
     * 切换角色的事件回调
     */
    @Override
    public void onSwitchRole(int i, String s) {
        super.onSwitchRole(i, s);
        Map<String, Object> params = new HashMap();
        params.put("errCode", i);
        params.put("errMsg", s);
        this.invokeListener(CallBackNoticeEnum.onSwitchRole, params);
    }

    /**
     * 请求跨房通话（主播 PK）的结果回调
     */
    @Override
    public void onConnectOtherRoom(String userId, int errCode, String errMsg) {
        super.onConnectOtherRoom(userId, errCode, errMsg);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        this.invokeListener(CallBackNoticeEnum.onConnectOtherRoom, params);
    }

    /**
     * 退出跨房通话 的结果回调
     */
    @Override
    public void onDisConnectOtherRoom(int errCode, String errMsg) {
        super.onDisConnectOtherRoom(errCode, errMsg);
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        this.invokeListener(CallBackNoticeEnum.onDisConnectOtherRoom, params);
    }

    /**
     * 切换房间 (switchRoom) 的结果回调
     */
    @Override
    public void onSwitchRoom(int errCode, String errMsg) {
        super.onSwitchRoom(errCode, errMsg);
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        this.invokeListener(CallBackNoticeEnum.onSwitchRoom, params);
    }

    /**
     * 开始向腾讯云的直播 CDN 推流的回调
     */
    @Override
    public void onStartPublishing(int errCode, String errMsg) {
        super.onStartPublishing(errCode, errMsg);
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        this.invokeListener(CallBackNoticeEnum.onStartPublishing, params);
    }

    /**
     * 停止向腾讯云的直播 CDN 推流的回调
     */
    @Override
    public void onStopPublishing(int errCode, String errMsg) {
        super.onStopPublishing(errCode, errMsg);
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        this.invokeListener(CallBackNoticeEnum.onStopPublishing, params);
    }

    /**
     * 启动旁路推流到 CDN 完成的回调
     */
    @Override
    public void onStartPublishCDNStream(int errCode, String errMsg) {
        super.onStartPublishCDNStream(errCode, errMsg);
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        this.invokeListener(CallBackNoticeEnum.onStartPublishCDNStream, params);
    }

    /**
     * 停止旁路推流到 CDN 完成的回调
     */
    @Override
    public void onStopPublishCDNStream(int errCode, String errMsg) {
        super.onStopPublishCDNStream(errCode, errMsg);
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("errMsg", errMsg);
        this.invokeListener(CallBackNoticeEnum.onStopPublishCDNStream, params);
    }

    /**
     * 有用户加入当前房间。
     */
    @Override
    public void onRemoteUserEnterRoom(String s) {
        super.onRemoteUserEnterRoom(s);
        this.invokeListener(CallBackNoticeEnum.onRemoteUserEnterRoom, s);
    }

    /**
     * 有用户离开当前房间。
     */
    @Override
    public void onRemoteUserLeaveRoom(String s, int i) {
        super.onRemoteUserLeaveRoom(s, i);
        Map<String, Object> params = new HashMap();
        params.put("userId", s);
        params.put("reason", i);
        this.invokeListener(CallBackNoticeEnum.onRemoteUserLeaveRoom, params);
    }

    /**
     * 远端用户是否存在可播放的主路画面（一般用于摄像头）
     */
    @Override
    public void onUserVideoAvailable(String userId, boolean available) {
        super.onUserVideoAvailable(userId, available);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("available", available);
        this.invokeListener(CallBackNoticeEnum.onUserVideoAvailable, params);
    }

    /**
     * 远端用户是否存在可播放的辅路画面（一般用于屏幕分享）
     */
    @Override
    public void onUserSubStreamAvailable(String userId, boolean available) {
        super.onUserSubStreamAvailable(userId, available);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("available", available);
        this.invokeListener(CallBackNoticeEnum.onUserSubStreamAvailable, params);
    }

    /**
     * 远端用户是否存在可播放的音频数据
     */
    @Override
    public void onUserAudioAvailable(String userId, boolean available) {
        super.onUserAudioAvailable(userId, available);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("available", available);
        this.invokeListener(CallBackNoticeEnum.onUserAudioAvailable, params);
    }

    /**
     * 开始渲染本地或远程用户的首帧画面
     */
    @Override
    public void onFirstVideoFrame(String userId, int i, int i1, int i2) {
        super.onFirstVideoFrame(userId, i, i1, i2);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("streamType", i);
        params.put("width", i1);
        params.put("height", i2);
        this.invokeListener(CallBackNoticeEnum.onFirstVideoFrame, params);
    }

    /**
     * 开始播放远程用户的首帧音频（本地声音暂不通知）。
     */
    @Override
    public void onFirstAudioFrame(String s) {
        super.onFirstAudioFrame(s);
        this.invokeListener(CallBackNoticeEnum.onFirstAudioFrame, s);
    }

    /**
     * 首帧本地视频数据已经被送出。
     */
    @Override
    public void onSendFirstLocalVideoFrame(int i) {
        super.onSendFirstLocalVideoFrame(i);
        this.invokeListener(CallBackNoticeEnum.onSendFirstLocalVideoFrame, i);
    }

    /**
     * 首帧本地音频数据已经被送出。
     */
    @Override
    public void onSendFirstLocalAudioFrame() {
        super.onSendFirstLocalAudioFrame();
        this.invokeListener(CallBackNoticeEnum.onSendFirstLocalAudioFrame, null);
    }

    /**
     * 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量。
     */
    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality trtcQuality, ArrayList<TRTCCloudDef.TRTCQuality> arrayList) {
        super.onNetworkQuality(trtcQuality, arrayList);
        Map<String, Object> params = new HashMap();
        params.put("localQuality", trtcQuality);
        params.put("remoteQuality", arrayList);
        this.invokeListener(CallBackNoticeEnum.onNetworkQuality, params);
    }

    /**
     * 技术指标统计回调。
     */
    @Override
    public void onStatistics(TRTCStatistics trtcStatistics) {
        super.onStatistics(trtcStatistics);
        this.invokeListener(CallBackNoticeEnum.onStatistics, trtcStatistics);
    }

    /**
     * SDK 跟服务器的连接断开
     */
    @Override
    public void onConnectionLost() {
        super.onConnectionLost();
        this.invokeListener(CallBackNoticeEnum.onConnectionLost, null);
    }

    /**
     * SDK 尝试重新连接到服务器。
     */
    @Override
    public void onTryToReconnect() {
        super.onTryToReconnect();
        this.invokeListener(CallBackNoticeEnum.onTryToReconnect, null);
    }

    /**
     * SDK 跟服务器的连接恢复。
     */
    @Override
    public void onConnectionRecovery() {
        super.onConnectionRecovery();
        this.invokeListener(CallBackNoticeEnum.onConnectionRecovery, null);
    }

    /**
     * 服务器测速的回调，SDK 对多个服务器 IP 做测速，每个 IP 的测速结果通过这个回调通知。【仅Android】
     */
    @Override
    public void onSpeedTest(TRTCCloudDef.TRTCSpeedTestResult trtcSpeedTestResult, int i, int i1) {
        super.onSpeedTest(trtcSpeedTestResult, i, i1);
        Map<String, Object> params = new HashMap();
        params.put("currentResult", trtcSpeedTestResult);
        params.put("finishedCount", i);
        params.put("totalCount", i1);
        this.invokeListener(CallBackNoticeEnum.onSpeedTest, params);
    }

    @Override
    public void onSpeedTestResult(TRTCCloudDef.TRTCSpeedTestResult result) {
        super.onSpeedTestResult(result);
        Map<String, Object> params = new HashMap();
        params.put("result", result);
        this.invokeListener(CallBackNoticeEnum.onSpeedTestResult, params);
    }

    /**
     * 摄像头准备就绪。
     */
    @Override
    public void onCameraDidReady() {
        super.onCameraDidReady();
        this.invokeListener(CallBackNoticeEnum.onCameraDidReady, null);
    }

    /**
     * 麦克风准备就绪。
     */
    @Override
    public void onMicDidReady() {
        super.onMicDidReady();
        this.invokeListener(CallBackNoticeEnum.onMicDidReady, null);
    }

    /**
     * 音频路由发生变化，音频路由即声音由哪里输出（扬声器、听筒）。
     */
    @Override
    public void onAudioRouteChanged(int i, int i1) {
        super.onAudioRouteChanged(i, i1);
        Map<String, Object> params = new HashMap();
        params.put("route", i);
        params.put("fromRoute", i1);
        this.invokeListener(CallBackNoticeEnum.onAudioRouteChanged, params);
    }

    /**
     * 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量。
     */
    @Override
    public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> arrayList, int i) {
        super.onUserVoiceVolume(arrayList, i);
        Map<String, Object> params = new HashMap();
        params.put("userVolumes", arrayList);
        params.put("totalVolume", i);
        this.invokeListener(CallBackNoticeEnum.onUserVoiceVolume, params);
    }

    /**
     * 收到自定义消息回调
     */
    @Override
    public void onRecvCustomCmdMsg(String userId, int cmdID, int seq, byte[] message) {
        super.onRecvCustomCmdMsg(userId, cmdID, seq, message);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("cmdID", cmdID);
        params.put("seq", seq);
        params.put("message", new String(message));
        this.invokeListener(CallBackNoticeEnum.onRecvCustomCmdMsg, params);
    }

    /**
     * 自定义消息丢失回调
     */
    @Override
    public void onMissCustomCmdMsg(String userId, int cmdID, int errCode, int missed) {
        super.onMissCustomCmdMsg(userId, cmdID, errCode, missed);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("cmdID", cmdID);
        params.put("errCode", errCode);
        params.put("missed", missed);
        this.invokeListener(CallBackNoticeEnum.onMissCustomCmdMsg, params);
    }

    /**
     * 收到 SEI 消息的回调
     */
    @Override
    public void onRecvSEIMsg(String userId, byte[] data) {
        super.onRecvSEIMsg(userId, data);
        Map<String, Object> params = new HashMap();
        params.put("userId", userId);
        params.put("message", new String(data));
        this.invokeListener(CallBackNoticeEnum.onRecvSEIMsg, params);
    }

    /**
     * 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口。
     */
    @Override
    public void onSetMixTranscodingConfig(int i, String s) {
        super.onSetMixTranscodingConfig(i, s);
        Map<String, Object> params = new HashMap();
        params.put("errCode", i);
        params.put("errMsg", s);
        this.invokeListener(CallBackNoticeEnum.onSetMixTranscodingConfig, params);
    }

    /**
     * 当屏幕分享开始时，SDK 会通过此回调通知
     */
    @Override
    public void onScreenCaptureStarted() {
        super.onScreenCaptureStarted();
        this.invokeListener(CallBackNoticeEnum.onScreenCaptureStarted, 0);
    }

    /**
     * 当屏幕分享暂停时，SDK 会通过此回调通知
     */
    @Override
    public void onScreenCapturePaused() {
        super.onScreenCapturePaused();
        this.invokeListener(CallBackNoticeEnum.onScreenCapturePaused, 0);
    }

    /**
     * 当屏幕分享恢复时，SDK 会通过此回调通知
     */
    @Override
    public void onScreenCaptureResumed() {
        super.onScreenCaptureResumed();
        this.invokeListener(CallBackNoticeEnum.onScreenCaptureResumed, 0);
    }

    /**
     * 当屏幕分享停止时，SDK 会通过此回调通知
     */
    @Override
    public void onScreenCaptureStopped(int reason) {
        super.onScreenCaptureStopped(reason);
        this.invokeListener(CallBackNoticeEnum.onScreenCaptureStoped, reason);
    }

    /**
     * 当本地录制任务已经开始时，SDK 会通过此回调通知
     */
    @Override
    public void onLocalRecordBegin(int errCode, String storagePath) {
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("storagePath", storagePath);
        this.invokeListener(CallBackNoticeEnum.onLocalRecordBegin, params);
    }

    /**
     * 当本地录制任务进行时，SDK 会周期性通过此回调通知
     * 您可以在 startLocalRecording 时设定本事件回调的抛出间隔。
     */
    @Override
    public void onLocalRecording(long duration, String storagePath) {
        Map<String, Object> params = new HashMap();
        params.put("duration", duration);
        params.put("storagePath", storagePath);
        this.invokeListener(CallBackNoticeEnum.onLocalRecording, params);
    }

    /**
     *  当您开启分片录制时，每完成一个分片，SDK 会通过此回调通知
     */
    @Override
    public void onLocalRecordFragment(String storagePath) {
        Map<String, Object> params = new HashMap();
        params.put("storagePath", storagePath);
        this.invokeListener(CallBackNoticeEnum.onLocalRecordFragment, params);
    }

    /**
     * 当本地录制任务已经结束，SDK 会通过此回调通知
     */
    @Override
    public void onLocalRecordComplete(int errCode, String storagePath) {
        Map<String, Object> params = new HashMap();
        params.put("errCode", errCode);
        params.put("storagePath", storagePath);
        this.invokeListener(CallBackNoticeEnum.onLocalRecordComplete, params);
    }

    @Override
    public void onStartPublishMediaStream(String taskId, int code, String message, Bundle extraInfo) {
        super.onStartPublishMediaStream(taskId, code, message, extraInfo);
        Map<String, Object> params = new HashMap();
        params.put("taskId", taskId);
        params.put("code", code);
        params.put("message", message);
        this.invokeListener(CallBackNoticeEnum.onStartPublishMediaStream, params);
    }

    @Override
    public void onUpdatePublishMediaStream(String taskId, int code, String message, Bundle extraInfo) {
        super.onUpdatePublishMediaStream(taskId, code, message, extraInfo);
        Map<String, Object> params = new HashMap();
        params.put("taskId", taskId);
        params.put("code", code);
        params.put("message", message);
        this.invokeListener(CallBackNoticeEnum.onUpdatePublishMediaStream, params);
    }

    @Override
    public void onStopPublishMediaStream(String taskId, int code, String message, Bundle extraInfo) {
        super.onStopPublishMediaStream(taskId, code, message, extraInfo);
        Map<String, Object> params = new HashMap();
        params.put("taskId", taskId);
        params.put("code", code);
        params.put("message", message);
        this.invokeListener(CallBackNoticeEnum.onStopPublishMediaStream, params);
    }
}