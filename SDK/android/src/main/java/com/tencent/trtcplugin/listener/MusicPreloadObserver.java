package com.tencent.trtcplugin.listener;

import com.google.gson.Gson;
import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.basic.log.TXCLog;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class MusicPreloadObserver implements TXAudioEffectManager.TXMusicPreloadObserver {
    private static final String LISTENER_FUNC_NAME = "onMusicPreloadObserver";

    private MethodChannel channel;

    Gson gson = new Gson();

    public MusicPreloadObserver(MethodChannel channel) {
        this.channel = channel;
    }

    @Override
    public void onLoadProgress(int i, int i1) {
        Map<String, Object> params = new HashMap();
        params.put("type", "onLoadProgress");
        params.put("id", i);
        params.put("progress", i1);
        channel.invokeMethod(LISTENER_FUNC_NAME, gson.toJson(params));
    }

    @Override
    public void onLoadError(int i, int i1) {
        Map<String, Object> params = new HashMap();
        params.put("type", "onLoadError");
        params.put("id", i);
        params.put("errCode", i1);
        channel.invokeMethod(LISTENER_FUNC_NAME, gson.toJson(params));
    }
}
