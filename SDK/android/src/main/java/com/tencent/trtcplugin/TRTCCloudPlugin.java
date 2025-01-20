package com.tencent.trtcplugin;

import android.content.Context;

import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;

import androidx.annotation.NonNull;

import com.tencent.trtcplugin.view.TRTCCloudVideoPlatformView;
import com.tencent.trtcplugin.view.TRTCCloudVideoSurfaceView;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformViewRegistry;

import io.flutter.view.TextureRegistry;

/**
 * 安卓中间层-腾讯云视频通话功能的主要接口类
 */
public class TRTCCloudPlugin implements FlutterPlugin {
    public static final String TAG = "TRTCCloudPlugin";
    private static final String CHANNEL_SIGN = "trtcCloudChannel";

    public TRTCCloudWrapper mCloudWrapper;

    private static ITXCustomBeautyProcesserFactory sProcesserFactory;

    public TRTCCloudPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Context trtcContext = flutterPluginBinding.getApplicationContext();
        BinaryMessenger binaryMessenger = flutterPluginBinding.getBinaryMessenger();
        FlutterAssets flutterAssets = flutterPluginBinding.getFlutterAssets();
        TextureRegistry textureRegistry = flutterPluginBinding.getTextureRegistry();
        PlatformViewRegistry platformRegistry = flutterPluginBinding.getPlatformViewRegistry();

        mCloudWrapper = new TRTCCloudWrapper(trtcContext, CHANNEL_SIGN,
                platformRegistry, textureRegistry, flutterAssets, binaryMessenger);

        platformRegistry.registerViewFactory(
                TRTCCloudVideoPlatformView.SIGN,
                new TRTCCloudVideoPlatformView(trtcContext, binaryMessenger));
        platformRegistry.registerViewFactory(
                TRTCCloudVideoSurfaceView.SIGN,
                new TRTCCloudVideoSurfaceView(trtcContext, binaryMessenger));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    public static void registerWith(Registrar registrar) {
        if (registrar.activity() == null) {
            return;
        }
        TRTCCloudPlugin plugin = new TRTCCloudPlugin();

    }

    public static void register(ITXCustomBeautyProcesserFactory processerFactory) {
        sProcesserFactory = processerFactory;
    }

    public static ITXCustomBeautyProcesserFactory getBeautyProcesserFactory() {
        return sProcesserFactory;
    }
}