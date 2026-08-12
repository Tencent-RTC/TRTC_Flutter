package com.tencent.trtcplugin.utils;


import com.tencent.liteav.basic.log.TXCLog;

public class TRTCLogger {
    public static void i(String message) {
        TXCLog.i("TRTCCloudManager", message);
    }

    public static void w(String message) {
        TXCLog.w("TRTCCloudManager", message);
    }

    public static void e(String message) {
        TXCLog.e("TRTCCloudManager", message);
    }
}