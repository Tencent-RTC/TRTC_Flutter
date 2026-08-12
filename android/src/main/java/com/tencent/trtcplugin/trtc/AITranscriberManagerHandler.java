package com.tencent.trtcplugin.trtc;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.tencent.liteav.transcriber.AITranscriberManager;
import com.tencent.liteav.transcriber.AITranscriberManager.TranscriberParams;
import com.tencent.liteav.transcriber.AITranscriberManager.TranscriberMessage;
import com.tencent.liteav.transcriber.AITranscriberManager.AITranscriberListener;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtcplugin.utils.MethodCallParams;
import com.tencent.trtcplugin.utils.TRTCLogger;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AITranscriberManagerHandler implements AITranscriberListener {
    private static final String TAG = "AITranscriberManagerHandler";

    private Context mContext;
    private MethodChannel mChannel;
    private Handler mMainHandler = new Handler(Looper.getMainLooper());

    private AITranscriberManager mTranscriberManager;
    private boolean mIsListenerAdded = false;

    public AITranscriberManagerHandler(Context context, MethodChannel channel) {
        mContext = context;
        mChannel = channel;
    }

    public void release() {
        if (mTranscriberManager != null && mIsListenerAdded) {
            mTranscriberManager.removeListener(this);
            mIsListenerAdded = false;
        }
        mTranscriberManager = null;
        mMainHandler.removeCallbacksAndMessages(null);
    }

    private AITranscriberManager getTranscriberManager() {
        if (mTranscriberManager == null) {
            TRTCCloud trtcCloud = TRTCCloud.sharedInstance(mContext);
            mTranscriberManager = trtcCloud.getAITranscriberManager();
        }
        return mTranscriberManager;
    }

    private void ensureListenerAdded() {
        if (!mIsListenerAdded) {
            AITranscriberManager manager = getTranscriberManager();
            if (manager != null) {
                manager.addListener(this);
                mIsListenerAdded = true;
            }
        }
    }

    public boolean handleMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            Method method = AITranscriberManagerHandler.class.getDeclaredMethod(call.method, MethodCall.class, MethodChannel.Result.class);  // CHECKSTYLE:SUPPRESS LineLength
            method.invoke(this, call, result);
            return true;
        } catch (NoSuchMethodException e) {
            return false;
        } catch (Exception e) {
            TRTCLogger.e(TAG + " | method=" + call.method + " | error=" + e);
            return false;
        }
    }

    @SuppressWarnings("unused")
    private void startRealtimeTranscriber(MethodCall call, MethodChannel.Result result) {
        ensureListenerAdded();

        TranscriberParams params = new TranscriberParams();
        params.transcriberRobotId = MethodCallParams.getParamCanBeNull(call, result, "transcriberRobotId");
        params.sourceLanguage = MethodCallParams.getParamCanBeNull(call, result, "sourceLanguage");

        List<String> userIds = MethodCallParams.getParamCanBeNull(call, result, "userIdsToTranscribe");
        if (userIds != null) {
            params.userIdsToTranscribe = userIds;
        }

        List<String> translationLanguages = MethodCallParams.getParamCanBeNull(call, result, "translationLanguages");
        if (translationLanguages != null) {
            params.translationLanguages = translationLanguages;
        }

        AITranscriberManager manager = getTranscriberManager();
        if (manager != null) {
            manager.startRealtimeTranscriber(params);
        }
        result.success(null);
    }

    @SuppressWarnings("unused")
    private void stopRealtimeTranscriber(MethodCall call, MethodChannel.Result result) {
        String transcriberRobotId = MethodCallParams.getParamCanBeNull(call, result, "transcriberRobotId");

        AITranscriberManager manager = getTranscriberManager();
        if (manager != null) {
            manager.stopRealtimeTranscriber(transcriberRobotId != null ? transcriberRobotId : "");
        }
        result.success(null);
    }

    @SuppressWarnings("unused")
    private void pauseReceivingTranscriberMessage(MethodCall call, MethodChannel.Result result) {
        AITranscriberManager manager = getTranscriberManager();
        if (manager != null) {
            manager.pauseReceivingMessage();
        }
        result.success(null);
    }

    @SuppressWarnings("unused")
    private void resumeReceivingTranscriberMessage(MethodCall call, MethodChannel.Result result) {
        AITranscriberManager manager = getTranscriberManager();
        if (manager != null) {
            manager.resumeReceivingMessage();
        }
        result.success(null);
    }

    @SuppressWarnings("unused")
    private void addTranscriberListener(MethodCall call, MethodChannel.Result result) {
        ensureListenerAdded();
        result.success(null);
    }

    @SuppressWarnings("unused")
    private void removeTranscriberListener(MethodCall call, MethodChannel.Result result) {
        AITranscriberManager manager = getTranscriberManager();
        if (manager != null && mIsListenerAdded) {
            manager.removeListener(this);
            mIsListenerAdded = false;
        }
        result.success(null);
    }

    @Override
    public void onRealtimeTranscriberStarted(String roomId, String transcriberRobotId) {
        mMainHandler.post(() -> {
            Map<String, Object> params = new HashMap<>();
            params.put("roomId", roomId);
            params.put("transcriberRobotId", transcriberRobotId);
            mChannel.invokeMethod("onRealtimeTranscriberStarted", params);
        });
    }

    @Override
    public void onReceiveTranscriberMessage(String roomId, TranscriberMessage message) {
        mMainHandler.post(() -> {
            Map<String, Object> params = new HashMap<>();
            params.put("roomId", roomId);

            Map<String, Object> messageMap = new HashMap<>();
            messageMap.put("segmentId", message.segmentId);
            messageMap.put("speakerUserId", message.speakerUserId);
            messageMap.put("sourceText", message.sourceText);
            messageMap.put("translationTexts", message.translationTexts != null ? message.translationTexts : new HashMap<>());  // CHECKSTYLE:SUPPRESS LineLength
            messageMap.put("timestamp", message.timestamp);
            messageMap.put("isCompleted", message.isCompleted);

            params.put("message", messageMap);
            mChannel.invokeMethod("onReceiveTranscriberMessage", params);
        });
    }

    @Override
    public void onRealtimeTranscriberStopped(String roomId, String transcriberRobotId, int reason) {
        mMainHandler.post(() -> {
            Map<String, Object> params = new HashMap<>();
            params.put("roomId", roomId);
            params.put("transcriberRobotId", transcriberRobotId);
            params.put("reason", reason);
            mChannel.invokeMethod("onRealtimeTranscriberStopped", params);
        });
    }

    @Override
    public void onRealtimeTranscriberError(String roomId, String transcriberRobotId, int error, String errorInfo) {
        mMainHandler.post(() -> {
            Map<String, Object> params = new HashMap<>();
            params.put("roomId", roomId);
            params.put("transcriberRobotId", transcriberRobotId);
            params.put("error", error);
            params.put("errorInfo", errorInfo);
            mChannel.invokeMethod("onRealtimeTranscriberError", params);
        });
    }
}
