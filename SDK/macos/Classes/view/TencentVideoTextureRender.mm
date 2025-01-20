//
//  TencentVideoTextureRender.m
//  tencent_trtc_cloud
//
//  Created by gavinwjwang on 2021/3/30.
//

#import "TencentVideoTextureRender.h"
#import "libkern/OSAtomic.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@implementation TencentVideoTextureRender
{
    CGSize _frameSize;
    CGSize _renderSize;
    bool _isLocal;
    CVPixelBufferRef _localBuffer;
    CVPixelBufferRef _target;
    CVPixelBufferRef _latestPixelBuffer;
    FrameUpdateCallback _callback;
}


- (instancetype)initWithFrameCallback:(FrameUpdateCallback)calback isLocal:(bool)isLocal{
    if(self = [super init]) {
        _frameSize = CGSizeZero;
        _renderSize = CGSizeZero;
        _callback = calback;
        _isLocal = isLocal;
    }
    return self;
}
- (void)dealloc {
  if (_latestPixelBuffer) {
    CFRelease(_latestPixelBuffer);
  }
}
- (CVPixelBufferRef)copyPixelBuffer {
    if(_isLocal){
//        if(_localBuffer != NULL){
//            CVBufferRetain(_localBuffer);
//            return  _localBuffer;
//        }
        @synchronized(self){
            if(_localBuffer != NULL){
                CVBufferRetain(_localBuffer);
                return _localBuffer;
            }
        }
        return  NULL;
    }else{
        @synchronized(self){
            if(_latestPixelBuffer != NULL){
                CVBufferRetain(_latestPixelBuffer);
                return _latestPixelBuffer;
            }
        }
//        if(_latestPixelBuffer != NULL){
//            CVBufferRetain(_latestPixelBuffer);
//            return _latestPixelBuffer;
//        }
        return  NULL;
    }
}

- (void)setSize:(CGSize)size {
    if(_localBuffer == nil || (size.width != _frameSize.width || size.height != _frameSize.height))
    {
        if(_localBuffer){
            CVBufferRelease(_localBuffer);
        }
        NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
        CVPixelBufferCreate(kCFAllocatorDefault,
                            size.width, size.height,
                            kCVPixelFormatType_32BGRA,
                            (__bridge CFDictionaryRef)(pixelAttributes), &_localBuffer);
        
        _frameSize = size;
    }
}

- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType {
    if (frame.pixelBuffer != NULL) {
        __weak TencentVideoTextureRender *weakSelf = self;
        CVPixelBufferRef nv12Buffer = frame.pixelBuffer;
        
        //创建 _latestPixelBuffer
//        if(_latestPixelBuffer){
//            CVBufferRelease(_latestPixelBuffer);
//        }
        if(_latestPixelBuffer == NULL){
            NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
            CVPixelBufferCreate(kCFAllocatorDefault,
                                frame.width, frame.height,
                                kCVPixelFormatType_32BGRA,
                                (__bridge CFDictionaryRef)(pixelAttributes), &_latestPixelBuffer);
        }
        
    
        // 将nv12Buffer 转为 bgraBuffer
        CVPixelBufferLockBaseAddress(_latestPixelBuffer, 0);
        CVPixelBufferLockBaseAddress(nv12Buffer, 0);
        size_t width = CVPixelBufferGetWidth(nv12Buffer);
        size_t height = CVPixelBufferGetHeight(nv12Buffer);
        
        static vImage_YpCbCrToARGB outInfo;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            vImage_YpCbCrPixelRange pixelRange = (vImage_YpCbCrPixelRange){0, 128, 255, 255, 255, 1, 255, 0};
            vImage_Error error = vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &pixelRange, &outInfo, kvImage420Yp8_CbCr8, kvImageARGB8888, kvImageNoFlags);
            if (error != kvImageNoError) {
    //            LOGE("vImageConvert_YpCbCrToARGB_GenerateConversion error:%ld", error);
            }
        });
       
        vImage_Buffer srcYp = {
            CVPixelBufferGetBaseAddressOfPlane(nv12Buffer, 0),
            CVPixelBufferGetHeightOfPlane(nv12Buffer, 0),
            CVPixelBufferGetWidthOfPlane(nv12Buffer, 0),
            CVPixelBufferGetBytesPerRowOfPlane(nv12Buffer, 0)
        };
        
        vImage_Buffer srcCbCr = {
            CVPixelBufferGetBaseAddressOfPlane(nv12Buffer, 1),
            CVPixelBufferGetHeightOfPlane(nv12Buffer, 1),
            CVPixelBufferGetWidthOfPlane(nv12Buffer, 1),
            CVPixelBufferGetBytesPerRowOfPlane(nv12Buffer, 1)
        };
        
        vImage_Buffer destBuffer = {
            CVPixelBufferGetBaseAddress(_latestPixelBuffer),
            height,
            width,
            CVPixelBufferGetBytesPerRow(_latestPixelBuffer)
        };
            
        const uint8_t map[4] = {3, 2, 1, 0};
        
        vImage_Error convertError = vImageConvert_420Yp8_CbCr8ToARGB8888(&srcYp, &srcCbCr, &destBuffer, &outInfo, map, 255, kvImageNoFlags);
        if (convertError != kvImageNoError) {
            //LOGE("vImageConvert_420Yp8_CbCr8ToARGB8888 error:%ld", convertError);
        }
        
        CVPixelBufferUnlockBaseAddress(_latestPixelBuffer, 0);
        CVPixelBufferUnlockBaseAddress(nv12Buffer, 0);
        
        //_callback();
        //Notify the Flutter new pixelBufferRef to be ready.
        dispatch_async(dispatch_get_main_queue(), ^{
            TencentVideoTextureRender *strongSelf = weakSelf;
            strongSelf->_callback();
        });
    }
}
//flutter macos 只支持BGRA，这里需要把nv12格式转为BGRA
- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame *)srcFrame
                       dstFrame:(TRTCVideoFrame *)dstFrame {
    __weak TencentVideoTextureRender *weakSelf = self;
    dstFrame.pixelBuffer = srcFrame.pixelBuffer;
      if (srcFrame.pixelBuffer != NULL) {
          CVPixelBufferRef nv12Buffer = srcFrame.pixelBuffer;
          //创建 _localBuffer
//          if(_localBuffer){
//              CVBufferRelease(_localBuffer);
//          }
          if(_localBuffer == NULL){
              NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
              CVPixelBufferCreate(kCFAllocatorDefault,
                                  srcFrame.width, srcFrame.height,
                                  kCVPixelFormatType_32BGRA,
                                  (__bridge CFDictionaryRef)(pixelAttributes), &_localBuffer);
          }
          
          // 将nv12Buffer 转为 bgraBuffer
          CVPixelBufferLockBaseAddress(_localBuffer, 0);
          CVPixelBufferLockBaseAddress(nv12Buffer, 0);
          size_t width = CVPixelBufferGetWidth(nv12Buffer);
          size_t height = CVPixelBufferGetHeight(nv12Buffer);
          
          static vImage_YpCbCrToARGB outInfo;
          static dispatch_once_t onceToken;
          dispatch_once(&onceToken, ^{
              vImage_YpCbCrPixelRange pixelRange = (vImage_YpCbCrPixelRange){0, 128, 255, 255, 255, 1, 255, 0};
              vImage_Error error = vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &pixelRange, &outInfo, kvImage420Yp8_CbCr8, kvImageARGB8888, kvImageNoFlags);
              if (error != kvImageNoError) {
      //            LOGE("vImageConvert_YpCbCrToARGB_GenerateConversion error:%ld", error);
              }
          });
          vImage_Buffer srcYp = {
              CVPixelBufferGetBaseAddressOfPlane(nv12Buffer, 0),
              CVPixelBufferGetHeightOfPlane(nv12Buffer, 0),
              CVPixelBufferGetWidthOfPlane(nv12Buffer, 0),
              CVPixelBufferGetBytesPerRowOfPlane(nv12Buffer, 0)
          };
          
          vImage_Buffer srcCbCr = {
              CVPixelBufferGetBaseAddressOfPlane(nv12Buffer, 1),
              CVPixelBufferGetHeightOfPlane(nv12Buffer, 1),
              CVPixelBufferGetWidthOfPlane(nv12Buffer, 1),
              CVPixelBufferGetBytesPerRowOfPlane(nv12Buffer, 1)
          };
          
          vImage_Buffer destBuffer = {
              CVPixelBufferGetBaseAddress(_localBuffer),
              height,
              width,
              CVPixelBufferGetBytesPerRow(_localBuffer)
          };
              
          const uint8_t map[4] = {3, 2, 1, 0};
          
          vImage_Error convertError = vImageConvert_420Yp8_CbCr8ToARGB8888(&srcYp, &srcCbCr, &destBuffer, &outInfo, map, 255, kvImageNoFlags);
          if (convertError != kvImageNoError) {
              //LOGE("vImageConvert_420Yp8_CbCr8ToARGB8888 error:%ld", convertError);
          }
          
          CVPixelBufferUnlockBaseAddress(_localBuffer, 0);
          CVPixelBufferUnlockBaseAddress(nv12Buffer, 0);
          
//          _callback();
          //Notify the Flutter new pixelBufferRef to be ready.
          dispatch_async(dispatch_get_main_queue(), ^{
              __strong TencentVideoTextureRender *strongSelf = weakSelf;
              if (strongSelf != NULL && strongSelf->_callback != NULL) {
                  strongSelf->_callback();
              }
          });
      }
    return 0;
}
@end
