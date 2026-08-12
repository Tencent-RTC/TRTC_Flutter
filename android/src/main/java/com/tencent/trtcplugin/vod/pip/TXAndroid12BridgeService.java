package com.tencent.trtcplugin.vod.pip;


import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import androidx.annotation.Nullable;

/**
 * To solve the problem that starting picture-in-picture multiple times is considered as background startup,
 * resulting in the inability to start.
 * This problem occurs on Android 12 and is currently only found on MIUI's Android 12.
 */
public class TXAndroid12BridgeService extends Service {

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return new Android12BridgeServiceBinder();
    }

    class Android12BridgeServiceBinder extends Binder {
        public TXAndroid12BridgeService getService() {
            return TXAndroid12BridgeService.this;
        }
    }
}
