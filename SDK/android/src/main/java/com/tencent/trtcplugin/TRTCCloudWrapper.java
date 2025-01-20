package com.tencent.trtcplugin;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.SurfaceTexture;

import com.google.gson.Gson;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.MethodChannel.Result;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesser;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;
import com.tencent.live.beauty.custom.TXCustomBeautyDef;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtcplugin.listener.AudioFrameListener;
import com.tencent.trtcplugin.listener.CustomTRTCCloudListener;
import com.tencent.trtcplugin.listener.MusicPreloadObserver;
import com.tencent.trtcplugin.listener.ProcessVideoFrame;
import com.tencent.trtcplugin.util.CommonUtil;
import com.tencent.trtcplugin.util.ObjectUtils;
import com.tencent.trtcplugin.view.CustomRenderVideoFrame;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.TextureRegistry;

public class TRTCCloudWrapper {
    public static Map<String, TRTCCloudWrapper> mTRTCManagerMap = new HashMap<>();

    private Context                 mContext;
    private TRTCCloud               mTRTCCloud;
    private MethodChannel           mChannel;
    private String                  mChannelName;
    private CustomTRTCCloudListener mTRTCListener;

    private TXDeviceManager      mTXDeviceManager;
    private TXBeautyManager      mTXBeautyManager;
    private TXAudioEffectManager mTXAudioEffectManager;

    private ITXCustomBeautyProcesser mCustomBeautyProcesser;

    private Map<String, TextureRegistry.SurfaceTextureEntry> mSurfaceMap = new HashMap<>();
    private Map<String, CustomRenderVideoFrame>              mRenderMap  = new HashMap<>();
    private SurfaceTexture                                   mLocalSufaceTexture;
    private CustomRenderVideoFrame                           mLocalCustomRender;
    private AudioFrameListener                               mAudioFrameListener;
    private MusicPreloadObserver                             mMusicPreloadObserver;
    private BasicMessageChannel                              mBasicChannel;

    private PlatformViewRegistry        mPlatformRegistry;
    private TextureRegistry             mTextureRegistry;
    private FlutterPlugin.FlutterAssets mFlutterAssets;
    private BinaryMessenger             mBinaryMessenger;
    
    private Gson gson = new Gson();


    public TRTCCloudWrapper(Context context, String channelName, TRTCCloud cloud,
                            PlatformViewRegistry platformRegistry, TextureRegistry textureRegistry,
                            FlutterPlugin.FlutterAssets flutterAssets, BinaryMessenger binaryMessenger) {
        mTRTCCloud = cloud;

        init(context, channelName, platformRegistry, textureRegistry, flutterAssets, binaryMessenger);

        mTRTCCloud.setListener(mTRTCListener);
    }

    public TRTCCloudWrapper(Context context, String channelName,
                            PlatformViewRegistry platformRegistry, TextureRegistry textureRegistry,
                            FlutterPlugin.FlutterAssets flutterAssets, BinaryMessenger binaryMessenger) {
        init(context, channelName, platformRegistry, textureRegistry, flutterAssets, binaryMessenger);
    }

    private void init(Context context, String channelName,
                      PlatformViewRegistry platformRegistry, TextureRegistry textureRegistry,
                      FlutterPlugin.FlutterAssets flutterAssets, BinaryMessenger binaryMessenger) {
        mContext = context;
        mChannelName = channelName;

        mPlatformRegistry = platformRegistry;
        mTextureRegistry = textureRegistry;
        mFlutterAssets = flutterAssets;
        mBinaryMessenger = binaryMessenger;

        mChannel = new MethodChannel(mBinaryMessenger, mChannelName);
        mBasicChannel = new BasicMessageChannel(mBinaryMessenger,
                mChannelName + "_basic_channel", JSONMessageCodec.INSTANCE);
        mTRTCListener = new CustomTRTCCloudListener(mChannel);


        mChannel.setMethodCallHandler(((call, result) -> {
            TXCLog.i(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|channel=" + mChannelName +
                    "|method=" + call.method + "|arguments=" + call.arguments);
            try {
                Method method = TRTCCloudWrapper.class.getDeclaredMethod(call.method, MethodCall.class, Result.class);
                method.invoke(this, call, result);
            } catch (NoSuchMethodException e) {
                TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|channel=" + mChannelName +
                        "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            } catch (IllegalAccessException e) {
                TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|channel=" + mChannelName +
                        "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            } catch (Exception e) {
                TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|channel=" + mChannelName +
                        "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            }
        }));
    }

    public TRTCCloud getTRTCCloud() {
        return mTRTCCloud;
    }

    private void sharedInstance(MethodCall call, MethodChannel.Result result) {
        // 初始化实例
        mTRTCCloud = TRTCCloud.sharedInstance(mContext);
        mTRTCManagerMap.put(mChannelName, this);
        mTRTCCloud.setListener(mTRTCListener);
        result.success(null);
    }

    /**
     * 销毁 TRTCCloud 单例
     */
    private void destroySharedInstance(MethodCall call, MethodChannel.Result result) {
        TRTCCloud.destroySharedInstance();
        mTRTCManagerMap.remove(mChannelName);
        mTRTCCloud = null;
        mSurfaceMap.clear();
        mRenderMap.clear();
        mLocalCustomRender = null;
        mLocalSufaceTexture = null;
        result.success(null);
    }

    private void createSubCloud(MethodCall call, MethodChannel.Result result) {
        String channelName = CommonUtil.getParam(call, result, "channelName");
        TRTCCloudWrapper manager = new TRTCCloudWrapper(mContext, channelName, mTRTCCloud.createSubCloud(),
                mPlatformRegistry, mTextureRegistry, mFlutterAssets, mBinaryMessenger);
        TRTCCloudWrapper.mTRTCManagerMap.put(channelName, manager);
        result.success(null);
    }

    private void destroySubCloud(MethodCall call, MethodChannel.Result result) {
        String channelName = CommonUtil.getParam(call, result, "channelName");
        mTRTCManagerMap.get(channelName).release(mTRTCCloud);
        mTRTCManagerMap.remove(channelName);
        result.success(null);
    }

    public void release(TRTCCloud cloud) {
        cloud.destroySubCloud(mTRTCCloud);
        mChannel.setMethodCallHandler(null);
        mTRTCCloud = null;
        mSurfaceMap.clear();
        mRenderMap.clear();
        mLocalCustomRender = null;
        mLocalSufaceTexture = null;
        mTRTCListener.release();
        mTRTCListener = null;
        mChannel = null;
        mChannelName = null;
    }

    /**
     * 进入房间
     */
    private void enterRoom(MethodCall call, MethodChannel.Result result) {
        //房间号大于2147483647时，两个人进房互相看不到
        //TRTCCloudDef.TRTCParams trtcP = gson.fromJson(param, TRTCCloudDef.TRTCParams.class);
        TRTCCloudDef.TRTCParams trtcP = new TRTCCloudDef.TRTCParams();
        trtcP.sdkAppId = CommonUtil.getParam(call, result, "sdkAppId");
        trtcP.userId = CommonUtil.getParam(call, result, "userId");
        trtcP.userSig = CommonUtil.getParam(call, result, "userSig");
        String roomId = CommonUtil.getParam(call, result, "roomId");
        trtcP.roomId = (int) (Long.parseLong(roomId) & 0xFFFFFFFF);
        trtcP.strRoomId = CommonUtil.getParam(call, result, "strRoomId");
        trtcP.role = CommonUtil.getParam(call, result, "role");
        trtcP.streamId = CommonUtil.getParam(call, result, "streamId");
        trtcP.userDefineRecordId = CommonUtil.getParam(call, result, "userDefineRecordId");
        trtcP.privateMapKey = CommonUtil.getParam(call, result, "privateMapKey");
        trtcP.businessInfo = CommonUtil.getParam(call, result, "businessInfo");

        int scene = CommonUtil.getParam(call, result, "scene");
        mTRTCCloud.callExperimentalAPI("{\"api\": \"setFramework\", \"params\": {\"framework\": 7}}");
        mTRTCCloud.enterRoom(trtcP, scene);
        result.success(null);
    }

    /**
     * 离开房间
     */
    private void exitRoom(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.exitRoom();
        mSurfaceMap.clear();
        mRenderMap.clear();
        mLocalCustomRender = null;
        mLocalSufaceTexture = null;
        result.success(null);
    }

    /**
     * 跨房通话
     */
    private void connectOtherRoom(MethodCall call, MethodChannel.Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        mTRTCCloud.ConnectOtherRoom(param);
        result.success(null);
    }

    /**
     * 退出跨房通话
     */
    private void disconnectOtherRoom(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.DisconnectOtherRoom();
        result.success(null);
    }

    /**
     * 切换角色，仅适用于直播场景（TRTC_APP_SCENE_LIVE 和 TRTC_APP_SCENE_VOICE_CHATROOM）
     */
    private void switchRole(MethodCall call, MethodChannel.Result result) {
        int role = CommonUtil.getParam(call, result, "role");
        mTRTCCloud.switchRole(role);
        result.success(null);
    }

    /**
     * 设置音视频数据接收模式，需要在进房前设置才能生效
     */
    private void setDefaultStreamRecvMode(MethodCall call, MethodChannel.Result result) {
        boolean autoRecvAudio = CommonUtil.getParam(call, result, "autoRecvAudio");
        boolean autoRecvVideo = CommonUtil.getParam(call, result, "autoRecvVideo");
        mTRTCCloud.setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo);
        result.success(null);
    }

    /**
     * 切换房间
     */
    private void switchRoom(MethodCall call, MethodChannel.Result result) {
        String config = CommonUtil.getParam(call, result, "config");
        mTRTCCloud.switchRoom(gson.fromJson(config, TRTCCloudDef.TRTCSwitchRoomConfig.class));
        result.success(null);
    }

    /**
     * 开始向腾讯云的直播 CDN 推流
     */
    private void startPublishing(MethodCall call, MethodChannel.Result result) {
        String streamId = CommonUtil.getParam(call, result, "streamId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        mTRTCCloud.startPublishing(streamId, streamType);
        result.success(null);
    }

    /**
     * 停止向腾讯云的直播 CDN 推流
     */
    private void stopPublishing(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopPublishing();
        result.success(null);
    }

    private void startSystemAudioLoopback(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.startSystemAudioLoopback();
        result.success(null);
    }

    private void stopSystemAudioLoopback(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopSystemAudioLoopback();
        result.success(null);
    }

    /**
     * 开始向腾讯云的直播 CDN 推流
     */
    private void startPublishCDNStream(MethodCall call, MethodChannel.Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        mTRTCCloud.startPublishCDNStream(gson.fromJson(param, TRTCCloudDef.TRTCPublishCDNParam.class));
        result.success(null);
    }

    /**
     * 停止向非腾讯云地址转推
     */
    private void stopPublishCDNStream(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopPublishCDNStream();
        result.success(null);
    }

    /**
     * 设置云端的混流转码参数
     */
    private void setMixTranscodingConfig(MethodCall call, MethodChannel.Result result) {
        String config = CommonUtil.getParam(call, result, "config");
        if (config == "null") {
            mTRTCCloud.setMixTranscodingConfig(null);
        } else {
            mTRTCCloud.setMixTranscodingConfig(gson.fromJson(config, TRTCCloudDef.TRTCTranscodingConfig.class));
        }
        result.success(null);
    }

    /**
     * 停止本地视频采集及预览
     */
    private void stopLocalPreview(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopLocalPreview();
        result.success(null);
    }

    /**
     * 停止显示远端视频画面，同时不再拉取该远端用户的视频数据流
     */
    private void stopRemoteView(MethodCall call, MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        mTRTCCloud.stopRemoteView(userId, streamType);
        result.success(null);
    }

    /**
     * 停止显示所有远端视频画面，同时不再拉取远端用户的视频数据流
     */
    private void stopAllRemoteView(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopAllRemoteView();
        result.success(null);
    }

    /**
     * 静音/取消静音指定的远端用户的声音
     */
    private void muteRemoteAudio(MethodCall call, MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        boolean mute = CommonUtil.getParam(call, result, "mute");
        mTRTCCloud.muteRemoteAudio(userId, mute);
        result.success(null);
    }

    /**
     * 静音/取消静音所有用户的声音
     */
    private void muteAllRemoteAudio(MethodCall call, MethodChannel.Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        mTRTCCloud.muteAllRemoteAudio(mute);
        result.success(null);
    }

    /**
     * 设置某个远程用户的播放音量
     */
    private void setRemoteAudioVolume(MethodCall call, MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int volume = CommonUtil.getParam(call, result, "volume");
        mTRTCCloud.setRemoteAudioVolume(userId, volume);
        result.success(null);
    }

    /**
     * 设置 SDK 采集音量。
     */
    private void setAudioCaptureVolume(MethodCall call, MethodChannel.Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        mTRTCCloud.setAudioCaptureVolume(volume);
        result.success(null);
    }

    /**
     * 获取 SDK 采集音量。
     */
    private void getAudioCaptureVolume(MethodCall call, MethodChannel.Result result) {
        result.success(mTRTCCloud.getAudioCaptureVolume());
    }

    /**
     * 设置 SDK 播放音量。
     */
    private void setAudioPlayoutVolume(MethodCall call, MethodChannel.Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        mTRTCCloud.setAudioPlayoutVolume(volume);
        result.success(null);
    }

    /**
     * 获取 SDK 播放音量。
     */
    private void getAudioPlayoutVolume(MethodCall call, MethodChannel.Result result) {
        result.success(mTRTCCloud.getAudioPlayoutVolume());
    }

    /**
     * 开启本地音频的采集和上行
     */
    private void startLocalAudio(MethodCall call, MethodChannel.Result result) {
        int quality = CommonUtil.getParam(call, result, "quality");
        mTRTCCloud.startLocalAudio(quality);
        result.success(null);
    }

    /**
     * 关闭本地音频的采集和上行
     */
    private void stopLocalAudio(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopLocalAudio();
        result.success(null);
    }

    /**
     * 暂停/恢复接收指定的远端视频流
     */
    private void muteRemoteVideoStream(MethodCall call, MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        boolean mute = CommonUtil.getParam(call, result, "mute");
        mTRTCCloud.muteRemoteVideoStream(userId, mute);
        result.success(null);
    }

    /**
     * 暂停/恢复接收所有远端视频流
     */
    private void muteAllRemoteVideoStreams(MethodCall call, MethodChannel.Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        mTRTCCloud.muteAllRemoteVideoStreams(mute);
        result.success(null);
    }

    /**
     * 设置视频编码器相关参数
     * 该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
     */
    private void setVideoEncoderParam(MethodCall call, MethodChannel.Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        mTRTCCloud.setVideoEncoderParam(gson.fromJson(param, TRTCCloudDef.TRTCVideoEncParam.class));
        result.success(null);
    }

    private static int convertTRTCPixelFormat(TXCustomBeautyDef.TXCustomBeautyPixelFormat format) {
        switch (format) {
            case TXCustomBeautyPixelFormatUnknown:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN;
            case TXCustomBeautyPixelFormatI420:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420;
            case TXCustomBeautyPixelFormatTexture2D:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
            default:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN;
        }
    }

    private static int convertTRTCBufferType(TXCustomBeautyDef.TXCustomBeautyBufferType type) {
        switch (type) {
            case TXCustomBeautyBufferTypeUnknown:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_UNKNOWN;
            case TXCustomBeautyBufferTypeByteBuffer:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_BUFFER;
            case TXCustomBeautyBufferTypeByteArray:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY;
            case TXCustomBeautyBufferTypeTexture:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
            default:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_UNKNOWN;
        }
    }

    /**
     * 开启/关闭自定义视频处理。
     * enable true: 开启; false: 关闭。【默认值】: false
     *
     * @return 返回值
     */
    public void enableCustomVideoProcess(MethodCall call, MethodChannel.Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        ITXCustomBeautyProcesserFactory processerFactory = TRTCCloudPlugin.getBeautyProcesserFactory();
        if (mCustomBeautyProcesser == null) {
            mCustomBeautyProcesser = processerFactory.createCustomBeautyProcesser();
        }
        TXCustomBeautyDef.TXCustomBeautyBufferType bufferType = mCustomBeautyProcesser.getSupportedBufferType();
        TXCustomBeautyDef.TXCustomBeautyPixelFormat pixelFormat = mCustomBeautyProcesser.getSupportedPixelFormat();
        if (enable) {
            ProcessVideoFrame processVideo = new ProcessVideoFrame(mCustomBeautyProcesser);
            int ret = mTRTCCloud.setLocalVideoProcessListener(convertTRTCPixelFormat(pixelFormat),
                    convertTRTCBufferType(bufferType), processVideo);
            result.success(ret);
        } else {
            int ret = mTRTCCloud.setLocalVideoProcessListener(convertTRTCPixelFormat(pixelFormat),
                    convertTRTCBufferType(bufferType), null);
            processerFactory.destroyCustomBeautyProcesser();
            mCustomBeautyProcesser = null;
            result.success(ret);
        }
    }

    /**
     * 设置网络流控相关参数。
     * 该设置决定 SDK 在各种网络环境下的调控策略（例如弱网下选择“保清晰”或“保流畅”）
     */
    private void setNetworkQosParam(MethodCall call, MethodChannel.Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        mTRTCCloud.setNetworkQosParam(gson.fromJson(param, TRTCCloudDef.TRTCNetworkQosParam.class));
        result.success(null);
    }

    /**
     * 设置本地图像的渲染模式。
     */
    private void setLocalRenderParams(MethodCall call, MethodChannel.Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        mTRTCCloud.setLocalRenderParams(gson.fromJson(param, TRTCCloudDef.TRTCRenderParams.class));
        result.success(null);
    }

    /**
     * 设置远端图像的渲染模式。
     */
    private void setRemoteRenderParams(MethodCall call, MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        String param = CommonUtil.getParam(call, result, "param");
        mTRTCCloud.setRemoteRenderParams(
                userId,
                streamType,
                gson.fromJson(param, TRTCCloudDef.TRTCRenderParams.class));
        result.success(null);
    }

    /**
     * 设置视频编码输出的画面方向，即设置远端用户观看到的和服务器录制的画面方向
     */
    private void setVideoEncoderRotation(MethodCall call, MethodChannel.Result result) {
        int rotation = CommonUtil.getParam(call, result, "rotation");
        mTRTCCloud.setVideoEncoderRotation(rotation);
        result.success(null);
    }

    /**
     * 设置编码器输出的画面镜像模式。
     */
    private void setVideoEncoderMirror(MethodCall call, MethodChannel.Result result) {
        boolean mirror = CommonUtil.getParam(call, result, "mirror");
        mTRTCCloud.setVideoEncoderMirror(mirror);
        result.success(null);
    }

    /**
     * 设置重力感应的适应模式。
     */
    private void setGSensorMode(MethodCall call, MethodChannel.Result result) {
        int mode = CommonUtil.getParam(call, result, "mode");
        mTRTCCloud.setGSensorMode(mode);
        result.success(null);
    }

    /**
     * 开启大小画面双路编码模式。
     */
    private void enableEncSmallVideoStream(MethodCall call, MethodChannel.Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        String smallVideoEncParam = CommonUtil.getParam(call, result, "smallVideoEncParam");
        int value = mTRTCCloud.enableEncSmallVideoStream(
                enable,
                gson.fromJson(smallVideoEncParam, TRTCCloudDef.TRTCVideoEncParam.class));
        result.success(value);
    }

    /**
     * 选定观看指定 uid 的大画面或小画面。
     */
    private void setRemoteVideoStreamType(MethodCall call, MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        int value = mTRTCCloud.setRemoteVideoStreamType(userId, streamType);
        result.success(value);
    }

//    private Integer getBitmapPixelDataMemoryPtr(JNIEnv *env, jclass clazz, jobject bitmap) {
//        AndroidBitmapInfo bitmapInfo;
//        int ret;
//        if ((ret = AndroidBitmap_getInfo(env, bitmap, &bitmapInfo)) < 0) {
//            LOGE("AndroidBitmap_getInfo() failed ! error=%d", ret);
//            return 0;
//        }
//        // 读取 bitmap 的像素数据块到 native 内存地址
//        void *addPtr;
//        if ((ret = AndroidBitmap_lockPixels(env, bitmap, &addPtr)) < 0) {
//            LOGE("AndroidBitmap_lockPixels() failed ! error=%d", ret);
//            return 0;
//        }
//        //unlock，保证不因这里获取地址导致bitmap被锁定
//        AndroidBitmap_unlockPixels(env, bitmap);
//        return (jlong)addPtr;
//    }

    /**
     * 视频画面截图
     */
    private void snapshotVideo(MethodCall call, final MethodChannel.Result result) {
        String userId = CommonUtil.getParamCanBeNull(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        int sourceType = CommonUtil.getParam(call, result, "sourceType");
        final String path = CommonUtil.getParam(call, result, "path");

        mTRTCCloud.snapshotVideo(userId, streamType, new TRTCCloudListener.TRTCSnapshotListener() {
            @Override
            public void onSnapshotComplete(Bitmap bitmap) {
                try {
                    String[] pathArr = path.split("\\.");
                    Bitmap.CompressFormat bitComp = Bitmap.CompressFormat.PNG;
                    if (pathArr[pathArr.length - 1].equals("jpg")) {
                        bitComp = Bitmap.CompressFormat.JPEG;
                    } else if (pathArr[pathArr.length - 1].equals("webp")) {
                        bitComp = Bitmap.CompressFormat.WEBP;
                    }
                    FileOutputStream fos = new FileOutputStream(path);
                    boolean isSuccess = bitmap.compress(bitComp, 100, fos);
                    if (isSuccess) {
                        mTRTCListener.onSnapshotComplete(0, "success", path);
                    } else {
                        mTRTCListener.onSnapshotComplete(-101, "bitmap compress failed", null);
                    }

                } catch (FileNotFoundException e) {
                    TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=snapshotVideo|error=" + e);
                    mTRTCListener.onSnapshotComplete(-102, e.toString(), null);
                } catch (Exception e) {
                    TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=snapshotVideo|error=" + e);
                    mTRTCListener.onSnapshotComplete(-103, e.toString(), null);
                }
            }
        });

        result.success(null);
    }

    // 设置本地视频的自定义渲染回调
    private void setLocalVideoRenderListener(MethodCall call, final MethodChannel.Result result) {
        boolean isFront = CommonUtil.getParam(call, result, "isFront");
        mTRTCCloud.startLocalPreview(isFront, null);
        TextureRegistry.SurfaceTextureEntry surfaceEntry = mTextureRegistry.createSurfaceTexture();
        SurfaceTexture surfaceTexture = surfaceEntry.surfaceTexture();
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        int width = CommonUtil.getParam(call, result, "width");
        int height = CommonUtil.getParam(call, result, "height");
        surfaceTexture.setDefaultBufferSize(width, height);
        CustomRenderVideoFrame customRender = new CustomRenderVideoFrame(userId, streamType);
        int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
        int bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
        mTRTCCloud.setLocalVideoRenderListener(pixelFormat, bufferType, customRender);
        customRender.start(surfaceTexture, width, height);
        mSurfaceMap.put(Long.toString(surfaceEntry.id()), surfaceEntry);
        mRenderMap.put(Long.toString(surfaceEntry.id()), customRender);
        mLocalSufaceTexture = surfaceTexture;
        mLocalCustomRender = customRender;
        result.success(surfaceEntry.id());
    }

    private void updateLocalVideoRender(MethodCall call, final MethodChannel.Result result) {
        int width = CommonUtil.getParam(call, result, "width");
        int height = CommonUtil.getParam(call, result, "height");
        mLocalSufaceTexture.setDefaultBufferSize(width, height);
        mLocalCustomRender.updateSize(width, height);
        result.success(null);
    }

    // 开启视频采集
    private void startLocalPreview(MethodCall call, final MethodChannel.Result result) {
        boolean isFront = CommonUtil.getParam(call, result, "isFront");
        mTRTCCloud.startLocalPreview(isFront, null);
        result.success(null);
    }

    // 开启远端视频拉取
    private void startRemoteView(MethodCall call, final MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        mTRTCCloud.startRemoteView(userId, streamType, null);
        result.success(null);
    }

    // 设置远端视频的自定义渲染回调
    private void setRemoteVideoRenderListener(MethodCall call, final MethodChannel.Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        int width = CommonUtil.getParam(call, result, "width");
        int height = CommonUtil.getParam(call, result, "height");
        mTRTCCloud.startRemoteView(userId, streamType, null);
        TextureRegistry.SurfaceTextureEntry surfaceEntry = mTextureRegistry.createSurfaceTexture();
        SurfaceTexture surfaceTexture = surfaceEntry.surfaceTexture();
        surfaceTexture.setDefaultBufferSize(width, height);
        CustomRenderVideoFrame customRender = new CustomRenderVideoFrame(userId, streamType);
        int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
        int bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
        mTRTCCloud.setRemoteVideoRenderListener(userId, pixelFormat, bufferType, customRender);
        customRender.start(surfaceTexture, width, height);
        mSurfaceMap.put(Long.toString(surfaceEntry.id()), surfaceEntry);
        mRenderMap.put(Long.toString(surfaceEntry.id()), customRender);
        result.success(surfaceEntry.id());
    }

    private void updateRemoteVideoRender(MethodCall call, final MethodChannel.Result result) {
        int width = CommonUtil.getParam(call, result, "width");
        int height = CommonUtil.getParam(call, result, "height");
        int textureID = CommonUtil.getParam(call, result, "textureID");
        TextureRegistry.SurfaceTextureEntry surfaceEntry = mSurfaceMap.get(String.valueOf(textureID));
        CustomRenderVideoFrame surfaceRender = mRenderMap.get(String.valueOf(textureID));
        mLocalSufaceTexture.setDefaultBufferSize(width, height);
        if (surfaceEntry != null) {
            surfaceEntry.surfaceTexture().setDefaultBufferSize(width, height);
        }
        if (surfaceRender != null) {
            surfaceRender.updateSize(width, height);
        }
        result.success(null);
    }

    private void unregisterTexture(MethodCall call, final MethodChannel.Result result) {
        int textureID = CommonUtil.getParam(call, result, "textureID");
        TextureRegistry.SurfaceTextureEntry surfaceEntry = mSurfaceMap.get(String.valueOf(textureID));
        CustomRenderVideoFrame surfaceRender = mRenderMap.get(String.valueOf(textureID));
        if (surfaceEntry != null) {
            surfaceEntry.release();
            mSurfaceMap.remove(String.valueOf(textureID));
        }
        if (surfaceRender != null) {
            surfaceRender.stop();
            mRenderMap.remove(String.valueOf(textureID));
        }
        result.success(null);
    }

    /**
     * 静音/取消静音本地的音频
     */
    private void muteLocalAudio(MethodCall call, MethodChannel.Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        mTRTCCloud.muteLocalAudio(mute);
        result.success(null);
    }

    /**
     * 暂停/恢复推送本地的视频数据
     */
    private void muteLocalVideo(MethodCall call, MethodChannel.Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        mTRTCCloud.muteLocalVideo(mute);
        result.success(null);
    }

    /**
     * 设置暂停推送本地视频时要推送的图片
     */
    private void setVideoMuteImage(MethodCall call, final MethodChannel.Result result) {
        String type = CommonUtil.getParam(call, result, "type");
        final String imageUrl = CommonUtil.getParamCanBeNull(call, result, "imageUrl");
        final int fps = CommonUtil.getParam(call, result, "fps");
        if (imageUrl == null) {
            mTRTCCloud.setVideoMuteImage(null, fps);
        } else {
            if (type.equals("network")) {
                new Thread() {
                    @Override
                    public void run() {
                        try {
                            URL url = new URL(imageUrl);
                            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                            connection.setDoInput(true);
                            connection.connect();
                            InputStream input = connection.getInputStream();
                            Bitmap myBitmap = BitmapFactory.decodeStream(input);
                            mTRTCCloud.setVideoMuteImage(myBitmap, fps);
                        } catch (IOException e) {
                            TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=setVideoMuteImage|error=" + e);
                        }
                    }
                }.start();
            } else {
                try {
                    String path = mFlutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = mContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    Bitmap myBitmap = BitmapFactory.decodeStream(mystream);
                    mTRTCCloud.setVideoMuteImage(myBitmap, fps);
                } catch (Exception e) {
                    TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=setVideoMuteImage|error=" + e);
                }
            }
        }
        result.success(null);
    }

    /**
     * 设置音频路由。
     */
    private void setAudioRoute(MethodCall call, MethodChannel.Result result) {
        int route = CommonUtil.getParam(call, result, "route");
        mTRTCCloud.setAudioRoute(route);
        result.success(null);
    }

    /**
     * 启用音量大小提示。
     */
    private void enableAudioVolumeEvaluation(MethodCall call, MethodChannel.Result result) {
        int intervalMs = CommonUtil.getParam(call, result, "intervalMs");
        mTRTCCloud.enableAudioVolumeEvaluation(intervalMs);
        result.success(null);
    }

    /**
     * 开始录音。
     */
    private void startAudioRecording(MethodCall call, MethodChannel.Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        int value = mTRTCCloud.startAudioRecording(
                gson.fromJson(param, TRTCCloudDef.TRTCAudioRecordingParams.class));
        result.success(value);
    }

    /**
     * 停止录音。
     */
    private void stopAudioRecording(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopAudioRecording();
        result.success(null);
    }

    /**
     * 开启本地媒体录制。
     */
    private void startLocalRecording(MethodCall call, MethodChannel.Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        mTRTCCloud.startLocalRecording(
                gson.fromJson(param, TRTCCloudDef.TRTCLocalRecordingParams.class));
        result.success(null);
    }

    /**
     * 停止录制。
     */
    private void stopLocalRecording(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopLocalRecording();
        result.success(null);
    }

    /**
     * 设置通话时使用的系统音量类型。
     */
    private void setSystemVolumeType(MethodCall call, MethodChannel.Result result) {
        int type = CommonUtil.getParam(call, result, "type");
        mTRTCCloud.setSystemVolumeType(type);
        result.success(null);
    }

    /**
     * 查询是否是前置摄像头
     */
    private void isFrontCamera(MethodCall call, MethodChannel.Result result) {
        result.success(mTXDeviceManager.isFrontCamera());
    }

    /**
     * 切换摄像头。
     */
    private void switchCamera(MethodCall call, MethodChannel.Result result) {
        boolean isFrontCamera = CommonUtil.getParam(call, result, "isFrontCamera");
        result.success(mTXDeviceManager.switchCamera(isFrontCamera));
    }

    /**
     * 获取摄像头的缩放因子。
     */
    private void getCameraZoomMaxRatio(MethodCall call, MethodChannel.Result result) {
        result.success(mTXDeviceManager.getCameraZoomMaxRatio());
    }

    /**
     * 设置摄像头缩放因子（焦距）。
     */
    private void setCameraZoomRatio(MethodCall call, MethodChannel.Result result) {
        Double ratioValue = CommonUtil.getParam(call, result, "value");
        result.success(mTXDeviceManager.setCameraZoomRatio(ratioValue.floatValue()));
    }

    /**
     * 设置是否自动识别人脸位置
     */
    private void enableCameraAutoFocus(MethodCall call, MethodChannel.Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        result.success(mTXDeviceManager.enableCameraAutoFocus(enable));
    }

    /**
     * 查询是否支持自动识别人脸位置。
     */
    private void isAutoFocusEnabled(MethodCall call, MethodChannel.Result result) {
        result.success(mTXDeviceManager.isAutoFocusEnabled());
    }

    /**
     * 开启闪光灯
     */
    private void enableCameraTorch(MethodCall call, MethodChannel.Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        result.success(mTXDeviceManager.enableCameraTorch(enable));
    }

    /**
     * 设置摄像头焦点。
     */
    private void setCameraFocusPosition(MethodCall call, MethodChannel.Result result) {
        int x = CommonUtil.getParam(call, result, "x");
        int y = CommonUtil.getParam(call, result, "y");
        mTXDeviceManager.setCameraFocusPosition(x, y);
        result.success(null);
    }

    //获取设备管理对象
    private void getDeviceManager(MethodCall call, MethodChannel.Result result) {
        mTXDeviceManager = mTRTCCloud.getDeviceManager();
    }

    //获取美颜管理对象
    private void getBeautyManager(MethodCall call, MethodChannel.Result result) {
        mTXBeautyManager = mTRTCCloud.getBeautyManager();
    }

    //获取音效管理类 TXAudioEffectManager
    private void getAudioEffectManager(MethodCall call, MethodChannel.Result result) {
        mTXAudioEffectManager = mTRTCCloud.getAudioEffectManager();
    }

    //启动屏幕分享
    private void startScreenCapture(MethodCall call, MethodChannel.Result result) {
        int streamType = CommonUtil.getParam(call, result, "streamType");
        String encParams = CommonUtil.getParam(call, result, "encParams");
        mTRTCCloud.startScreenCapture(streamType, gson.fromJson(encParams, TRTCCloudDef.TRTCVideoEncParam.class)
                , null);
        result.success(null);
    }

    //停止屏幕采集
    private void stopScreenCapture(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopScreenCapture();
        result.success(null);
    }

    //暂停屏幕分享
    private void pauseScreenCapture(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.pauseScreenCapture();
        result.success(null);
    }

    //恢复屏幕分享
    private void resumeScreenCapture(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.resumeScreenCapture();
        result.success(null);
    }

    /**
     * 添加水印
     */
    private void setWatermark(MethodCall call, MethodChannel.Result result) {
        final String imageUrl = CommonUtil.getParam(call, result, "imageUrl");
        String type = CommonUtil.getParam(call, result, "type");
        final int streamType = CommonUtil.getParam(call, result, "streamType");
        String xStr = CommonUtil.getParam(call, result, "x");
        final float x = Float.parseFloat(xStr);
        String yStr = CommonUtil.getParam(call, result, "y");
        final float y = Float.parseFloat(yStr);
        String widthStr = CommonUtil.getParam(call, result, "width");
        final float width = Float.parseFloat(widthStr);
        if (imageUrl.isEmpty()) {
            mTRTCCloud.setWatermark(null, streamType, x, y, width);
            result.success(null);
            return;
        }
        if (type.equals("network")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream input = connection.getInputStream();
                        Bitmap myBitmap = BitmapFactory.decodeStream(input);
                        mTRTCCloud.setWatermark(myBitmap, streamType, x, y, width);
                    } catch (IOException e) {
                        TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=setWatermark|error=" + e);
                    }
                }
            }.start();
        } else {
            try {
                Bitmap myBitmap;
                //文档目录或sdcard图片
                if (imageUrl.startsWith("/")) {
                    myBitmap = BitmapFactory.decodeFile(imageUrl);
                } else {
                    String path = mFlutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = mContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    myBitmap = BitmapFactory.decodeStream(mystream);
                }
                mTRTCCloud.setWatermark(myBitmap, streamType, x, y, width);
            } catch (Exception e) {
                TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=setWatermark|error=" + e);
            }
        }
        result.success(null);
    }

    /**
     * 发送自定义消息给房间内所有用户
     */
    private void sendCustomCmdMsg(MethodCall call, MethodChannel.Result result) {
        int cmdID = CommonUtil.getParam(call, result, "cmdID");
        String data = CommonUtil.getParam(call, result, "data");
        boolean reliable = CommonUtil.getParam(call, result, "reliable");
        boolean ordered = CommonUtil.getParam(call, result, "ordered");
        boolean value = mTRTCCloud.sendCustomCmdMsg(cmdID, data.getBytes(), reliable, ordered);
        result.success(value);
    }

    /**
     * 将小数据量的自定义数据嵌入视频帧中
     */
    private void sendSEIMsg(MethodCall call, MethodChannel.Result result) {
        String data = CommonUtil.getParam(call, result, "data");
        int repeatCount = CommonUtil.getParam(call, result, "repeatCount");
        boolean value = mTRTCCloud.sendSEIMsg(data.getBytes(), repeatCount);
        result.success(value);
    }

    /**
     * 开始进行网络测速（视频通话期间请勿测试，以免影响通话质量）
     */
    private void startSpeedTest(MethodCall call, MethodChannel.Result result) {
        int sdkAppId = CommonUtil.getParam(call, result, "sdkAppId");
        String userId = CommonUtil.getParam(call, result, "userId");
        String userSig = CommonUtil.getParam(call, result, "userSig");
        mTRTCCloud.startSpeedTest(sdkAppId, userId, userSig);
        result.success(null);
    }

    private void startSpeedTestWithParams(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> paramsMap = CommonUtil.getParam(call, result, "params");

        TRTCCloudDef.TRTCSpeedTestParams params = new TRTCCloudDef.TRTCSpeedTestParams();
        params.sdkAppId = paramsMap.get("sdkAppId") != null ? (int) paramsMap.get("sdkAppId") : 0;
        params.userId = paramsMap.get("userId") != null ? (String) paramsMap.get("userId") : "";
        params.userSig = paramsMap.get("userSig") != null ? (String) paramsMap.get("userSig") : "";
        params.expectedUpBandwidth = paramsMap.get("expectedUpBandwidth") != null ? (int) paramsMap.get("expectedUpBandwidth") : 0;
        params.expectedDownBandwidth = paramsMap.get("expectedDownBandwidth") != null ? (int) paramsMap.get("expectedDownBandwidth") : 0;
        params.scene = paramsMap.get("scene") != null ? (int) paramsMap.get("scene") : 0;

        int returnValue = mTRTCCloud.startSpeedTest(params);

        result.success(returnValue);
    }

    /**
     * 停止服务器测速
     */
    private void stopSpeedTest(MethodCall call, MethodChannel.Result result) {
        mTRTCCloud.stopSpeedTest();
        result.success(null);
    }

    /**
     * 获取 SDK 版本信息
     */
    private void getSDKVersion(MethodCall call, MethodChannel.Result result) {
        result.success(mTRTCCloud.getSDKVersion());
    }

    /**
     * 设置 Log 输出级别
     */
    private void setLogLevel(MethodCall call, MethodChannel.Result result) {
        int level = CommonUtil.getParam(call, result, "level");
        mTRTCCloud.setLogLevel(level);
        result.success(null);
    }

    /**
     * 启用或禁用控制台日志打印
     */
    private void setConsoleEnabled(MethodCall call, MethodChannel.Result result) {
        boolean enabled = CommonUtil.getParam(call, result, "enabled");
        TRTCCloud.setConsoleEnabled(enabled);
        result.success(null);
    }

    /**
     * 修改日志保存路径
     */
    private void setLogDirPath(MethodCall call, MethodChannel.Result result) {
        String path = CommonUtil.getParam(call, result, "path");
        TRTCCloud.setLogDirPath(path);
        result.success(null);
    }

    /**
     * 启用或禁用 Log 的本地压缩。
     */
    private void setLogCompressEnabled(MethodCall call, MethodChannel.Result result) {
        boolean enabled = CommonUtil.getParam(call, result, "enabled");
        TRTCCloud.setLogCompressEnabled(enabled);
        result.success(null);
    }

    /**
     * 显示仪表盘
     * 仪表盘是状态统计和事件消息浮层　view，方便调试
     */
    private void showDebugView(MethodCall call, MethodChannel.Result result) {
        int mode = CommonUtil.getParam(call, result, "mode");
        mTRTCCloud.showDebugView(mode);
        result.success(null);
    }

    // 调用实验性 API 接口
    private void callExperimentalAPI(MethodCall call, MethodChannel.Result result) {
        String jsonStr = CommonUtil.getParam(call, result, "jsonStr");
        mTRTCCloud.callExperimentalAPI(jsonStr);
        result.success(null);
    }

    /**
     * 设置美颜类型
     */
    private void setBeautyStyle(MethodCall call, MethodChannel.Result result) {
        int beautyStyle = CommonUtil.getParam(call, result, "beautyStyle");
        mTXBeautyManager.setBeautyStyle(beautyStyle);
        result.success(null);
    }

    /**
     * 设置指定素材滤镜特效
     */
    private void setFilter(MethodCall call, final MethodChannel.Result result) {
        String type = CommonUtil.getParam(call, result, "type");
        final String imageUrl = CommonUtil.getParam(call, result, "imageUrl");
        if (type.equals("network")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream input = connection.getInputStream();
                        Bitmap myBitmap = BitmapFactory.decodeStream(input);
                        mTXBeautyManager.setFilter(myBitmap);
                    } catch (IOException e) {
                        TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=setFilter|error=" + e);
                    }
                }
            }.start();
        } else {
            try {
                Bitmap myBitmap;
                //文档目录或sdcard图片
                if (imageUrl.startsWith("/")) {
                    myBitmap = BitmapFactory.decodeFile(imageUrl);
                } else {
                    String path = mFlutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = mContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    myBitmap = BitmapFactory.decodeStream(mystream);
                }
                mTXBeautyManager.setFilter(myBitmap);

            } catch (Exception e) {
                TXCLog.e(TRTCCloudPlugin.TAG, "TRTCCloudWrapper|method=setFilter|error=" + e);
            }
        }
        result.success(null);
    }

    /**
     * 设置滤镜浓度
     */
    private void setFilterStrength(MethodCall call, MethodChannel.Result result) {
        String strength = CommonUtil.getParam(call, result, "strength");
        float strengthFloat = Float.parseFloat(strength);
        mTXBeautyManager.setFilterStrength(strengthFloat);
        result.success(null);
    }

    /**
     * 设置美颜级别
     */
    private void setBeautyLevel(MethodCall call, MethodChannel.Result result) {
        int beautyLevel = CommonUtil.getParam(call, result, "beautyLevel");
        mTXBeautyManager.setBeautyLevel(beautyLevel);
        result.success(null);
    }

    /**
     * 设置美白级别
     */
    private void setWhitenessLevel(MethodCall call, MethodChannel.Result result) {
        int whitenessLevel = CommonUtil.getParam(call, result, "whitenessLevel");
        mTXBeautyManager.setWhitenessLevel(whitenessLevel);
        result.success(null);
    }

    /**
     * 开启清晰度增强
     */
    private void enableSharpnessEnhancement(MethodCall call, MethodChannel.Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        mTXBeautyManager.enableSharpnessEnhancement(enable);
        result.success(null);
    }

    /**
     * 设置红润级别
     */
    private void setRuddyLevel(MethodCall call, MethodChannel.Result result) {
        int ruddyLevel = CommonUtil.getParam(call, result, "ruddyLevel");
        mTXBeautyManager.setRuddyLevel(ruddyLevel);
        result.success(null);
    }

    /**
     * 开启耳返
     */
    private void enableVoiceEarMonitor(MethodCall call, MethodChannel.Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        mTXAudioEffectManager.enableVoiceEarMonitor(enable);
        result.success(null);
    }

    /**
     * 设置耳返音量。
     */
    private void setVoiceEarMonitorVolume(MethodCall call, MethodChannel.Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        mTXAudioEffectManager.setVoiceEarMonitorVolume(volume);
        result.success(null);
    }

    /**
     * 设置人声的混响效果（KTV、小房间、大会堂、低沉、洪亮...）
     */
    private void setVoiceReverbType(MethodCall call, MethodChannel.Result result) {
        int type = CommonUtil.getParam(call, result, "type");
        TXAudioEffectManager.TXVoiceReverbType reverbType =
                TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
        switch (type) {
            case 0:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
                break;
            case 1:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1;
                break;
            case 2:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2;
                break;
            case 3:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3;
                break;
            case 4:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4;
                break;
            case 5:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_5;
                break;
            case 6:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_6;
                break;
            case 7:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_7;
                break;
            case 8:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_8;
                break;
            case 9:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_9;
                break;
            case 10:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_10;
                break;
            case 11:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_11;
                break;
            default:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
                break;
        }
        mTXAudioEffectManager.setVoiceReverbType(reverbType);
        result.success(null);
    }

    /**
     * 设置人声的变声特效（萝莉、大叔、重金属、外国人...）
     */
    private void setVoiceChangerType(MethodCall call, MethodChannel.Result result) {
        int type = CommonUtil.getParam(call, result, "type");
        TXAudioEffectManager.TXVoiceChangerType changerType =
                TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
        switch (type) {
            case 0:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
                break;
            case 1:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1;
                break;
            case 2:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2;
                break;
            case 3:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3;
                break;
            case 4:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4;
                break;
            case 5:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_5;
                break;
            case 6:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_6;
                break;
            case 7:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_7;
                break;
            case 8:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_8;
                break;
            case 9:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_9;
                break;
            case 10:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_10;
                break;
            case 11:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_11;
                break;
            default:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
                break;
        }
        mTXAudioEffectManager.setVoiceChangerType(changerType);
        result.success(null);
    }

    /**
     * 设置麦克风采集人声的音量
     */
    private void setVoiceCaptureVolume(MethodCall call, MethodChannel.Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        mTXAudioEffectManager.setVoiceCaptureVolume(volume);
        result.success(null);
    }

    /**
     * 设置背景音乐的播放进度回调接口
     */
    private void setMusicObserver(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        mTXAudioEffectManager.setMusicObserver(id, new TXAudioEffectManager.TXMusicPlayObserver() {
            @Override
            public void onStart(int i, int i1) {
                mTRTCListener.onMusicObserverStart(i, i1);
            }

            @Override
            public void onPlayProgress(int i, long l, long l1) {
                mTRTCListener.onMusicObserverPlayProgress(i, l, l1);
            }

            @Override
            public void onComplete(int i, int i1) {
                mTRTCListener.onMusicObserverComplete(i, i1);
            }
        });
        result.success(null);
    }


    /**
     * 开始播放背景音乐
     */
    private void startPlayMusic(MethodCall call, MethodChannel.Result result) {
        String musicParam = CommonUtil.getParam(call, result, "musicParam");
        TXAudioEffectManager.AudioMusicParam audioMusicParam =
                gson.fromJson(musicParam, TXAudioEffectManager.AudioMusicParam.class);
        boolean isSuccess = mTXAudioEffectManager.startPlayMusic(audioMusicParam);
        result.success(isSuccess);
        mTXAudioEffectManager.setMusicObserver(audioMusicParam.id, new TXAudioEffectManager.TXMusicPlayObserver() {
            @Override
            public void onStart(int i, int i1) {
                mTRTCListener.onMusicObserverStart(i, i1);
            }

            @Override
            public void onPlayProgress(int i, long l, long l1) {
                mTRTCListener.onMusicObserverPlayProgress(i, l, l1);
            }

            @Override
            public void onComplete(int i, int i1) {
                mTRTCListener.onMusicObserverComplete(i, i1);
            }
        });
    }

    /**
     * 停止播放背景音乐
     */
    private void stopPlayMusic(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        mTXAudioEffectManager.stopPlayMusic(id);
        result.success(null);
    }

    /**
     * 暂停播放背景音乐
     */
    private void pausePlayMusic(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        mTXAudioEffectManager.pausePlayMusic(id);
        result.success(null);
    }

    /**
     * 恢复播放背景音乐
     */
    private void resumePlayMusic(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        mTXAudioEffectManager.resumePlayMusic(id);
        result.success(null);
    }

    /**
     * 设置背景音乐的远端音量大小，即主播可以通过此接口设置远端观众能听到的背景音乐的音量大小。
     */
    private void setMusicPublishVolume(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        int volume = CommonUtil.getParam(call, result, "volume");
        mTXAudioEffectManager.setMusicPublishVolume(id, volume);
        result.success(null);
    }

    /**
     * 设置背景音乐的本地音量大小，即主播可以通过此接口设置主播自己本地的背景音乐的音量大小。
     */
    private void setMusicPlayoutVolume(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        int volume = CommonUtil.getParam(call, result, "volume");
        mTXAudioEffectManager.setMusicPlayoutVolume(id, volume);
        result.success(null);
    }

    /**
     * 设置全局背景音乐的本地和远端音量的大小
     */
    private void setAllMusicVolume(MethodCall call, MethodChannel.Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        mTXAudioEffectManager.setAllMusicVolume(volume);
        result.success(null);
    }

    /**
     * 调整背景音乐的音调高低
     */
    private void setMusicPitch(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        String pitchParam = CommonUtil.getParam(call, result, "pitch");
        float pitch = Float.parseFloat(pitchParam);
        mTXAudioEffectManager.setMusicPitch(id, pitch);
        result.success(null);
    }

    /**
     * 调整背景音乐的变速效果
     */
    private void setMusicSpeedRate(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        String speedRateParam = CommonUtil.getParam(call, result, "speedRate");
        float speedRate = Float.parseFloat(speedRateParam);
        mTXAudioEffectManager.setMusicSpeedRate(id, speedRate);
        result.success(null);
    }

    /**
     * 获取背景音乐当前的播放进度（单位：毫秒）
     */
    private void getMusicCurrentPosInMS(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        result.success(mTXAudioEffectManager.getMusicCurrentPosInMS(id));
    }

    /**
     * 设置背景音乐的播放进度（单位：毫秒）
     */
    private void seekMusicToPosInMS(MethodCall call, MethodChannel.Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        int pts = CommonUtil.getParam(call, result, "pts");
        mTXAudioEffectManager.seekMusicToPosInMS(id, pts);
        result.success(null);
    }

    /**
     * 获取景音乐文件的总时长（单位：毫秒）
     */
    private void getMusicDurationInMS(MethodCall call, MethodChannel.Result result) {
        String path = CommonUtil.getParamCanBeNull(call, result, "path");
        result.success(mTXAudioEffectManager.getMusicDurationInMS(path));
    }

    /**
     * 开始CDN推流
     */
    private void startPublishMediaStream(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> targetMap = CommonUtil.getParamCanBeNull(call, result, "target");
        Map<String, Object> paramMap = CommonUtil.getParamCanBeNull(call, result, "param");
        Map<String, Object> configMap = CommonUtil.getParamCanBeNull(call, result, "config");

        mTRTCCloud.startPublishMediaStream(ObjectUtils.getTRTCPublishTargetFromMap(targetMap),
                ObjectUtils.getTRTCStreamEncoderParamFromMap(paramMap),
                ObjectUtils.getTRTCStreamMixingConfigFromMap(configMap));
        result.success(null);
    }

    /**
     * 更新CDN流
     */
    private void updatePublishMediaStream(MethodCall call, MethodChannel.Result result) {
        String taskId = CommonUtil.getParamCanBeNull(call, result, "taskId");
        Map<String, Object> targetMap = CommonUtil.getParamCanBeNull(call, result, "target");
        Map<String, Object> paramMap = CommonUtil.getParamCanBeNull(call, result, "encoderParam");
        Map<String, Object> configMap = CommonUtil.getParamCanBeNull(call, result, "mixingConfig");

        mTRTCCloud.updatePublishMediaStream(taskId,
                ObjectUtils.getTRTCPublishTargetFromMap(targetMap),
                ObjectUtils.getTRTCStreamEncoderParamFromMap(paramMap),
                ObjectUtils.getTRTCStreamMixingConfigFromMap(configMap));
        result.success(null);
    }

    /**
     * 停止CDN推流
     */
    private void stopPublishMediaStream(MethodCall call, MethodChannel.Result result) {
        String taskId = CommonUtil.getParamCanBeNull(call, result, "taskId");
        mTRTCCloud.stopPublishMediaStream(taskId);
        result.success(null);
    }

    /**
     * 设置音频数据回调
     */
    private void setAudioFrameListener(MethodCall call, MethodChannel.Result result) {
        boolean isNullListener = CommonUtil.getParamCanBeNull(call, result, "isNullListener");
        if (!isNullListener) {
            mAudioFrameListener = new AudioFrameListener(mBasicChannel);
            mTRTCCloud.setAudioFrameListener(mAudioFrameListener);
        } else {
            mAudioFrameListener = null;
            mTRTCCloud.setAudioFrameListener(mAudioFrameListener);
        }
        result.success(null);
    }

    private void setVoicePitch(MethodCall call, MethodChannel.Result result) {
        double pitch = CommonUtil.getParam(call, result, "pitch");
        mTXAudioEffectManager.setVoicePitch(pitch);
        result.success(null);
    }

    private void preloadMusic(MethodCall call, MethodChannel.Result result) {
        String preloadParam = CommonUtil.getParam(call, result, "preloadParam");

        if (mMusicPreloadObserver == null) {
            mMusicPreloadObserver = new MusicPreloadObserver(mChannel);
            mTXAudioEffectManager.setPreloadObserver(mMusicPreloadObserver);
        }

        TXAudioEffectManager.AudioMusicParam audioMusicParam =
                gson.fromJson(preloadParam, TXAudioEffectManager.AudioMusicParam.class);
        mTXAudioEffectManager.preloadMusic(audioMusicParam);

        result.success(null);
    }
}
