import { BinaryMessenger, MethodCall, MethodCallHandler, MethodResult, PlatformView } from '@ohos/flutter_ohos'
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { DVModel } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicView';

@Component
struct TRTCComponentView {
  @Prop params: Params
  platformView: TRTCPlatformView = this.params.platformView as TRTCPlatformView
  private surfaceId: string = ''
  private xComponentContext: Record<string, () => void> = {}
  xComponentController: XComponentController = new XComponentController()
  @State rect: SurfaceRect | null = null

  build() {
    XComponent({
      id: this.platformView.name,
      type: 'surface',
      libraryname: 'liteavsdk'
    })
      .onLoad(() => {})
  }
}


@Builder
function buildTRTCComponentView(param: Params) {
  TRTCComponentView({ params: param })
}


export class TRTCPlatformView extends PlatformView implements MethodCallHandler {
  static SIGN = "TRTCPlatformView"
  name: string
  messenger: BinaryMessenger
  builder: WrappedBuilder<[Params]> = wrapBuilder(buildTRTCComponentView)

  constructor(name: string, messenger: BinaryMessenger) {
    super();
    this.name = name;
    this.messenger = messenger;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    throw new Error('Method not implemented.');
  }

  getView(): WrappedBuilder<[Params]> {
    return this.builder
  }

  onFlutterViewAttached(dvModel: DVModel): void {
  }

  onFlutterViewDetached(): void {
  }

  dispose(): void {
  }

  onInputConnectionLocked(): void {}

  onInputConnectionUnlocked(): void {}

}


