package com.tencent.trtcplugin.view;

import android.content.Context;
import android.view.View;

import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtcplugin.TRTCCloudPlugin;
import com.tencent.trtcplugin.TRTCCloudWrapper;
import com.tencent.trtcplugin.util.CommonUtil;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * 视频视图
 */
public class TRTCCloudVideoSurfaceView extends PlatformViewFactory
        implements PlatformView, MethodChannel.MethodCallHandler {
    public static final String SIGN = "trtcCloudChannelSurfaceView";

    private BinaryMessenger  mMessenger;
    private TRTCCloud        mTRTCCloud;
    private TXCloudVideoView mRemoteView;
    // private SurfaceView mSurfaceView;
    private MethodChannel    mChannel;

    /**
     * 初始化工厂信息，此处的域是 PlatformViewFactory
     */
    public TRTCCloudVideoSurfaceView(Context context, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);

        this.mMessenger = messenger;
        // mSurfaceView = new SurfaceView(context);
        mRemoteView = new TXCloudVideoView(context);
    }

    @Override
    public View getView() {
        return mRemoteView;
    }

    @Override
    public void dispose() {}

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        // 每次实例化对象，保证界面上每一个组件的独立性
        TRTCCloudVideoSurfaceView view = new TRTCCloudVideoSurfaceView(context, mMessenger);
        mChannel = new MethodChannel(mMessenger, SIGN + "_" + viewId);
        mChannel.setMethodCallHandler(view);
        return view;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String channelName = CommonUtil.getParam(call, result, "channelName");
        TXCLog.i(TRTCCloudPlugin.TAG, "TRTCCloudVideoSurfaceView|channel=" + channelName +
                "|method=" + call.method + "|arguments=" + call.arguments);
        mTRTCCloud = TRTCCloudWrapper.mTRTCManagerMap.get(channelName).getTRTCCloud();
        switch (call.method) {
            case "startRemoteView":
                this.startRemoteView(call, result);
                break;
            case "startLocalPreview":
                this.startLocalPreview(call, result);
                break;
            case "updateLocalView":
                this.updateLocalView(call, result);
                break;
            case "updateRemoteView":
                this.updateRemoteView(call, result);
                break;
            default:
                result.notImplemented();
        }

    }

    /**
     * 开始显示远端视频画面
     */
    private void startRemoteView(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        mTRTCCloud.startRemoteView(userId, streamType, this.mRemoteView);
        result.success(null);
    }

    /**
     * 开启本地视频的预览画面
     */
    private void startLocalPreview(MethodCall call, Result result) {
        boolean frontCamera = CommonUtil.getParam(call, result, "frontCamera");
        mTRTCCloud.startLocalPreview(frontCamera, this.mRemoteView);
        result.success(null);
    }

    /**
     * 更新本地视频的预览画面
     */
    private void updateLocalView(MethodCall call, Result result) {
        mTRTCCloud.updateLocalView(this.mRemoteView);
        result.success(null);
    }

    /**
     * 更新远端视频画面
     */
    private void updateRemoteView(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        mTRTCCloud.updateRemoteView(userId, streamType, this.mRemoteView);
        result.success(null);
    }
}