package com.tencent.trtcplugin;

import android.content.Context;
import androidx.annotation.NonNull;

import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;
import com.tencent.trtcplugin.trtc.TRTCCloudManager;
import com.tencent.trtcplugin.view.TRTCPlatformViewFactory;
import com.tencent.trtcplugin.vod.VodMethodChannelHandler;
import com.tencent.trtcplugin.view.TXCloudVideoViewChannel;
import com.tencent.live2.V2TXLivePusherObserver;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformViewRegistry;

public class TRTCPlugin implements FlutterPlugin {
    public static final String TAG = "trtc-flutter";
    
    private static ITXCustomBeautyProcesserFactory sProcessFactory;
    
    private static V2TXLivePusherObserver sObserver;

    public static ITXCustomBeautyProcesserFactory getBeautyProcesserFactory() {
        return sProcessFactory;
    }
    
    public static void setBeautyProcesserFactory(ITXCustomBeautyProcesserFactory factory) {
        sProcessFactory = factory;
    }

    public static void registerObserver(V2TXLivePusherObserver observer) {
        sObserver = observer;
    }

    public static V2TXLivePusherObserver getCustomVideoProcessObserver() {
        return sObserver;
    }

    private TRTCCloudManager mCloudManager;
    private TXCloudVideoViewChannel mVideoViewChannel;
    // Vod module entry: owns the TencentVodPlugin / TencentVodPlayer / TencentVodDownload MethodChannels.
    private VodMethodChannelHandler mVodHandler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Context context = flutterPluginBinding.getApplicationContext();
        MethodChannel methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "TencentRTCffi");
        mVideoViewChannel = new TXCloudVideoViewChannel(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getTextureRegistry());
        mCloudManager = new TRTCCloudManager(context, methodChannel, mVideoViewChannel, flutterPluginBinding.getBinaryMessenger());  // CHECKSTYLE:SUPPRESS LineLength

        PlatformViewRegistry registry = flutterPluginBinding.getPlatformViewRegistry();
        registry.registerViewFactory("TXCloudVideoViewPlatformView", new TRTCPlatformViewFactory(flutterPluginBinding.getBinaryMessenger()));  // CHECKSTYLE:SUPPRESS LineLength
        System.loadLibrary("liteavsdk");

        // Mount the Vod module. It registers the RenderView factory, binds the engine lifecycle
        // and initializes the download manager internally.
        mVodHandler = new VodMethodChannelHandler(flutterPluginBinding);
        mVodHandler.attach();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        if (mVodHandler != null) {
            mVodHandler.detach();
            mVodHandler = null;
        }
        mCloudManager.release();
        if (mVideoViewChannel != null) {
            mVideoViewChannel.release();
            mVideoViewChannel = null;
        }
    }
}