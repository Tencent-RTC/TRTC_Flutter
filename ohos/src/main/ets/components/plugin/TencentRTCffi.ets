import {
  FlutterPlugin,
  FlutterPluginBinding,
  PlatformViewRegistry,
  StandardMessageCodec,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TRTCPlatformView } from '../view/TRTCPlatformView'
import { TRTCPlatformViewFactory } from '../view/TRTCPlatformViewFactory'
import { LiteAVBase } from "@tencentcloud/liteavsdk_professional"
import { TextureRegistry } from '@ohos/flutter_ohos/src/main/ets/view/TextureRegistry';

/** FfipluginPlugin **/
export default class TencentRTCOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private static isInitialize: boolean = false;

  private channel: MethodChannel | null = null;
  private videoViewChannel: MethodChannel | null = null;
  private textureRegistry: TextureRegistry | null = null;
  private textureToSurfaceMap: Map<number, number> = new Map();

  constructor() {
  }

  getUniqueClassName(): string {
    return "TencentRTCOhosPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "TencentRTCffi");
    this.channel.setMethodCallHandler(this);
    this.videoViewChannel = new MethodChannel(binding.getBinaryMessenger(), "TXCloudVideoViewChannel");
    this.videoViewChannel.setMethodCallHandler(this);
    this.textureRegistry = binding.getTextureRegistry();

    let registry: PlatformViewRegistry = binding.getPlatformViewRegistry();
    registry.registerViewFactory(TRTCPlatformView.SIGN, new TRTCPlatformViewFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE))
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
      this.channel = null
    }
    if (this.videoViewChannel != null) {
      this.videoViewChannel.setMethodCallHandler(null)
      this.videoViewChannel = null
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "initialize") {
      if (!TencentRTCOhosPlugin.isInitialize) {
        TencentRTCOhosPlugin.isInitialize = true
        LiteAVBase.setContext(getContext())
      }
      result.success(null)
    } else if (call.method == "trtcLog") {
      result.success(null)
    } else if (call.method == "getTextureId") {
      let textureId = this.textureRegistry!.getTextureId();
      hilog.info(0, "TencentRTCOhosPlugin", "getTextureId, textureId: %d", textureId)
      result.success(textureId);
    } else if (call.method == "getSurfaceId") {
      let textureId: number = call.argument("textureId");
      if (this.textureToSurfaceMap.has(textureId)) {
        let surfaceId = this.textureToSurfaceMap.get(textureId);
        hilog.info(0, "TencentRTCOhosPlugin", "getSurfaceId (cached), textureId: %d, surfaceId: %d", textureId, surfaceId)
        result.success(surfaceId);
        return;
      }
      let surfaceId = this.textureRegistry!.registerTexture(textureId).getSurfaceId();
      this.textureToSurfaceMap.set(textureId, surfaceId);
      hilog.info(0, "TencentRTCOhosPlugin", "getSurfaceId (new), textureId: %d, surfaceId: %d", textureId, surfaceId)
      result.success(surfaceId);
    } else if (call.method == "unregisterTexture") {
      let textureId: number = call.argument("textureId");
      hilog.info(0, "TencentRTCOhosPlugin", "unregisterTexture, textureId: %d", textureId)
      this.textureToSurfaceMap.delete(textureId);
      this.textureRegistry!.unregisterTexture(textureId);
      result.success(null);
    } else if (call.method == "setRenderSize") {
      let textureId: number = call.argument("textureId");
      let width: number = call.argument("width");
      let height: number = call.argument("height");
      hilog.info(0, "TencentRTCOhosPlugin", "setRenderSize, textureId: %d, width: %d, height: %d", textureId, width, height)
      this.textureRegistry!.setTextureBufferSize(textureId, width, height);
      result.success(null);
    } else {
      result.notImplemented()
    }
  }

}
