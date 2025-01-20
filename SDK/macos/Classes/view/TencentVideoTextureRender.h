//
//  TencentVideoTextureRender.h
//  tencent_trtc_cloud
//
//  Created by gavinwjwang on 2021/3/30.
//

// #import <UIKit/UIKit.h>
#import <FlutterMacOS/FlutterMacOS.h>
#import <TXLiteAVSDK_TRTC_Mac/TRTCCloud.h>
#import <TXLiteAVSDK_TRTC_Mac/TRTCCloudDef.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FrameUpdateCallback)(void);

@interface TencentVideoTextureRender : NSObject<FlutterTexture,FlutterStreamHandler ,TRTCVideoRenderDelegate,TRTCVideoFrameDelegate>


- (instancetype)initWithFrameCallback:(FrameUpdateCallback)calback isLocal:(bool)isLocal;

@end

NS_ASSUME_NONNULL_END
