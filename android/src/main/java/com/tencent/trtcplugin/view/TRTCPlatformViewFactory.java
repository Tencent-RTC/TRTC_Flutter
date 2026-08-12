package com.tencent.trtcplugin.view;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.liteav.basic.log.TXCLog;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class TRTCPlatformViewFactory extends PlatformViewFactory {
    private BinaryMessenger messenger;
    public TRTCPlatformViewFactory(BinaryMessenger messenger) {  // CHECKSTYLE:SUPPRESS EmptyLineSeparator
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int i, @Nullable Object o) {
        TXCLog.i("TRTCPlatformViewFactory", "trtcFlutter onOhosViewCreate | viewId: " + i);
        return new TRTCPlatformView(context, messenger, i);
    }
}
