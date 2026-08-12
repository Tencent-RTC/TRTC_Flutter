package com.tencent.trtcplugin.view;

import android.content.Context;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.live.V2TXLivePremierJni;
import com.tencent.rtmp.ui.TXCloudVideoView;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class TRTCPlatformView implements PlatformView, MethodChannel.MethodCallHandler {
    static final String SIGN = "TRTCPlatformView";
    private Context mContext;
    private int mViewId;
    private long mViewPtr;
    private MethodChannel mChannel;
    private final TXCloudVideoView mRemoteView;

    TRTCPlatformView(Context context, BinaryMessenger messenger, int viewId) {
        super();
        this.mViewId = viewId;
        mContext = context;
        mChannel = new MethodChannel(messenger, SIGN + "_" + viewId);
        mChannel.setMethodCallHandler(this);

        mRemoteView = new TXCloudVideoView(context);
        mRemoteView.addVideoView(new TextureView(context));
        mViewPtr = V2TXLivePremierJni.getObjectAddress(mRemoteView);
    }

    @Nullable
    @Override
    public View getView() {
        return mRemoteView;
    }

    @Override
    public void dispose() {
        V2TXLivePremierJni.releaseObjectAddress(mViewPtr);
        mChannel.setMethodCallHandler(null);
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
        TXCLog.i(SIGN, "trtcFlutter onFlutterViewAttached | viewId: " + mViewId);
    }

    @Override
    public void onFlutterViewDetached() {
        PlatformView.super.onFlutterViewDetached();
        TXCLog.i(SIGN, "trtcFlutter onFlutterViewDetached | viewId: " + mViewId);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        TXCLog.i(SIGN, "TRTCCloudVideoPlatformView|viewId=" + mViewId +  // CHECKSTYLE:SUPPRESS OperatorWrap
                "|method=" + call.method + "|arguments=" + call.arguments);
        switch (call.method) {
            case "getTXView":
                result.success(mViewPtr);
                break;
            case "deleteTXView":
                result.success(null);
                break;
            case "getViewId":
                result.success(mViewPtr);
                break;
            default:
                result.notImplemented();
        }
    }

}
