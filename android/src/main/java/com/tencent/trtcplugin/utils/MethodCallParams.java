package com.tencent.trtcplugin.utils;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public class MethodCallParams {
    public static <T> T getParam(MethodCall methodCall, Result result, String param) {
        T parameter = methodCall.argument(param);
        if (parameter == null) {
            result.error("Missing parameter", "Cannot find parameter `" + param + "` or `" + param + "` is null!", 5);
            TRTCLogger.e("MethodCallParams|method=" + methodCall.method + "|arguments=null");
        }
        return parameter;
    }

    public static <T> T getParamCanBeNull(MethodCall methodCall, Result result, String param) {
        T parameter = methodCall.argument(param);
        return parameter;
    }
}
