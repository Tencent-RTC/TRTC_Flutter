// Copyright (c) 2026 Tencent. All rights reserved.

#import "VodGlobalResource.h"
#import "VodMethodChannelHandler.h"
#import "FTXEvent.h"
#import "FTXLog.h"
#import "FTXLiteAVSDKHeader.h"
#import <UIKit/UIKit.h>

@interface VodGlobalResource () <TXLiveBaseDelegate>

@property (nonatomic, strong) NSHashTable<VodMethodChannelHandler *> *attachedHandlers;  // weak
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) int currentOrientation;

@end

@implementation VodGlobalResource

+ (instancetype)sharedInstance {
    static VodGlobalResource *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VodGlobalResource alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _attachedHandlers = [NSHashTable weakObjectsHashTable];
        _lock = [[NSLock alloc] init];
        _currentOrientation = ORIENTATION_PORTRAIT_UP;
    }
    return self;
}

- (void)acquire:(VodMethodChannelHandler *)handler {
    if (!handler) return;
    [self.lock lock];
    BOOL wasEmpty = (self.attachedHandlers.count == 0);
    [self.attachedHandlers addObject:handler];
    NSUInteger size = self.attachedHandlers.count;
    [self.lock unlock];

    FTXLOGI(@"VodGlobalResource acquire handler=%p, size=%lu, firstAttach=%d",
            handler, (unsigned long)size, wasEmpty);
    if (wasEmpty) {
        // Wire up process-level hooks on first attach.
        [TXLiveBase sharedInstance].delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}

- (void)release:(VodMethodChannelHandler *)handler {
    if (!handler) return;
    [self.lock lock];
    [self.attachedHandlers removeObject:handler];
    NSUInteger size = self.attachedHandlers.count;
    BOOL nowEmpty = (size == 0);
    [self.lock unlock];

    FTXLOGI(@"VodGlobalResource release handler=%p, size=%lu, lastDetach=%d",
            handler, (unsigned long)size, nowEmpty);
    if (nowEmpty) {
        // Tear down process-level hooks on last detach.
        if ([TXLiveBase sharedInstance].delegate == self) {
            [TXLiveBase sharedInstance].delegate = nil;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (NSArray<VodMethodChannelHandler *> *)snapshotHandlers {
    [self.lock lock];
    NSArray *snapshot = self.attachedHandlers.allObjects;
    [self.lock unlock];
    return snapshot;
}

#pragma mark - TXLiveBaseDelegate (fan-out)

- (void)onLicenceLoaded:(int)result Reason:(NSString *)reason {
    FTXLOGV(@"VodGlobalResource onLicenceLoaded,result:%d, reason:%@", result, reason);
    NSArray *snapshot = [self snapshotHandlers];
    for (VodMethodChannelHandler *h in snapshot) {
        [h dispatchLicenceLoadedWithResult:result reason:reason];
    }
}

#pragma mark - UIDeviceOrientationDidChangeNotification (fan-out)

- (void)onDeviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    int next = self.currentOrientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:           next = ORIENTATION_PORTRAIT_UP;     break;
        case UIInterfaceOrientationLandscapeLeft:      next = ORIENTATION_LANDSCAPE_LEFT;  break;
        case UIInterfaceOrientationPortraitUpsideDown: next = ORIENTATION_PORTRAIT_DOWN;   break;
        case UIInterfaceOrientationLandscapeRight:     next = ORIENTATION_LANDSCAPE_RIGHT; break;
        default: break;
    }
    if (next != self.currentOrientation) {
        self.currentOrientation = next;
        NSArray *snapshot = [self snapshotHandlers];
        for (VodMethodChannelHandler *h in snapshot) {
            [h dispatchOrientationChanged:next];
        }
    }
}

@end
