import { BinaryMessenger, MessageCodec, PlatformView, PlatformViewFactory } from '@ohos/flutter_ohos';
import { TRTCPlatformView } from './TRTCPlatformView'


export class TRTCPlatformViewFactory extends PlatformViewFactory {
  message: BinaryMessenger;

  constructor(message: BinaryMessenger, createArgsCodes: MessageCodec<Object>) {
    super(createArgsCodes);
    this.message = message;
  }


  public create(context: Context, viewId: number, args: ESObject): PlatformView {
    let viewName = viewId.toString()
    return new TRTCPlatformView(viewName, this.message);
  }

}