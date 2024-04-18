/*
 * Module:   TXReplayKitExt @ TXLiteAVSDK
 *
 * Function: Tencent Cloud ReplayKit screen recording function in Extension
 *
 * Version: <:Version:>
 */

/// @defgroup TXReplayKitExt_ios TXReplayKitExt
/// Tencent Cloud ReplayKit screen recording function in Extension
/// @{

#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TXReplayKitExtReason) {
  /// The main process request ends
  TXReplayKitExtReasonRequestedByMain,
  /// Link disconnect, the main process exits
  TXReplayKitExtReasonDisconnected,
  /// The version number does not match the main process SDK
  TXReplayKitExtReasonVersionMismatch
};

@protocol TXReplayKitExtDelegate;

/// Screen sharing the main entrance class
API_AVAILABLE(ios(11.0))
__attribute__((visibility("default"))) @interface TXReplayKitExt : NSObject

/// Obtain a single example
+ (instancetype)sharedInstance;

/// Initialization method
///
/// You need to call the BroadCastStartEdWithSetupinfo method in the implementation class of the RPBroidSamplehandler implementation class
/// @param appGroup App group ID
/// @param delegate Callback object
- (void)setupWithAppGroup:(NSString *)appGroup delegate:(id<TXReplayKitExtDelegate>)delegate;

/// Method of Display Screen Disposal
///
/// When the screen recording is stopped through the system control center, it will call back RPBroidCastSamplehandler.broadcastPaused, 
/// and call it in the broadcastPaused method
- (void)broadcastPaused;

/// Method of recording screen recovery
///
/// When the screen recording is stopped through the system control center, the RPBroidCastSamplehandler.BroadCastResumed will be called back.
- (void)broadcastResumed;

/// Screen recording completion method
///
/// When the screen recording is stopped through the system control center, it will call back RPBroidCastSamplehandler.BroadCastfinished 
/// and call in the BroadcastFinished method
- (void)broadcastFinished;

/// Media data (audio and video) sending method
///
/// You need to call the processsAmpleBuffer: method in the implementation class of RPBroidSamplehandler.
///
/// @param sampleBuffer System callback video or audio frame
/// @param sampleBufferType Media input type
/// @note  
/// - sampleBufferType Currently supports RPSampleBufferTypeVideo and RPSampleBufferTypeAudioApp data frame processing.
/// - RPSampleBufferTypeAudioMic Not supported, please process the microphone collection data in the main APP
- (void)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer
                withType:(RPSampleBufferType)sampleBufferType;

/// Video sending method
/// For abandoned, please use - (void)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType; instead instead
/// You need to call the processsAmpleBuffer: method in the implementation class of RPBroidSamplehandler.
///
/// @param sampleBuffer System recovery video frame
- (void)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
    __attribute__((deprecated("use sendSampleBuffer:withType instead")));

@end

API_AVAILABLE(ios(11.0))
@protocol TXReplayKitExtDelegate <NSObject>

/// Screen recording complete callback
///
/// @param broadcast Examples of callback
/// @param reason End the cause code, see TXReplayKitExtReason
- (void)broadcastFinished:(TXReplayKitExt *)broadcast reason:(TXReplayKitExtReason)reason;

@end

NS_ASSUME_NONNULL_END
/// @}
