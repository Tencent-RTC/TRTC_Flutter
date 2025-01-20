package com.tencent.trtcplugin.listener;

import android.os.Handler;
import android.os.Looper;

import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BasicMessageChannel;

public class AudioFrameListener implements TRTCCloudListener.TRTCAudioFrameListener {
    private BasicMessageChannel mBasicChannel;
    private Handler             mUIHandler;

    public AudioFrameListener(BasicMessageChannel basicChannel) {
        this.mBasicChannel = basicChannel;
        mUIHandler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void onCapturedAudioFrame(TRTCCloudDef.TRTCAudioFrame trtcAudioFrame) {
        mUIHandler.post(() -> {
            Map<String, Object> params = new HashMap();
            params.put("data", trtcAudioFrame.data);
            params.put("sampleRate", trtcAudioFrame.sampleRate);
            params.put("channels", trtcAudioFrame.channel);
            params.put("timestamp", trtcAudioFrame.timestamp);
            params.put("extraData", trtcAudioFrame.extraData);

            Map<String, Object> message = new HashMap();
            message.put("method", "onCapturedAudioFrame");
            message.put("params", params);

            mBasicChannel.send(message);
        });
    }

    @Override
    public void onLocalProcessedAudioFrame(TRTCCloudDef.TRTCAudioFrame trtcAudioFrame) {
        //TODO
    }

    @Override
    public void onRemoteUserAudioFrame(TRTCCloudDef.TRTCAudioFrame trtcAudioFrame, String s) {
        //TODO
    }

    @Override
    public void onMixedPlayAudioFrame(TRTCCloudDef.TRTCAudioFrame trtcAudioFrame) {
        //TODO
    }

    @Override
    public void onMixedAllAudioFrame(TRTCCloudDef.TRTCAudioFrame trtcAudioFrame) {
        //TODO
    }

    @Override
    public void onVoiceEarMonitorAudioFrame(TRTCCloudDef.TRTCAudioFrame trtcAudioFrame) {
        //TODO
    }
}
