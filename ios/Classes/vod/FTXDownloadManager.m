// Copyright (c) 2022 Tencent. All rights reserved.

#import "FTXDownloadManager.h"
#import "FTXEvent.h"
#import "TXCommonUtil.h"
#import "VodMethodChannelHandler.h"
#import "TXPredownloadFileHelperDelegate.h"
#import "FTXLog.h"

#if __has_include(<TXLiteAVSDK_Player/TXVodPreloadManager.h>)
#import <TXLiteAVSDK_Player/TXVodPreloadManager.h>
#import <TXLiteAVSDK_Player/TXVodDownloadManager.h>
#elif __has_include(<TXLiteAVSDK_Player_Premium/TXVodPreloadManager.h>)
#import <TXLiteAVSDK_Player_Premium/TXVodPreloadManager.h>
#import <TXLiteAVSDK_Player_Premium/TXVodDownloadManager.h>
#elif __has_include(<TXLiteAVSDK_Professional/TXVodPreloadManager.h>)
#import <TXLiteAVSDK_Professional/TXVodPreloadManager.h>
#import <TXLiteAVSDK_Professional/TXVodDownloadManager.h>
#else
#import <TXVodPreloadManager.h>
#import <TXVodDownloadManager.h>
#endif


@interface FTXDownloadManager () <TXVodPreloadManagerDelegate, TXVodDownloadDelegate>

@property (nonatomic, weak) VodMethodChannelHandler *channelHandler;
@property (nonatomic, strong) dispatch_queue_t mPreloadQueue;
@property (atomic, strong) NSMutableArray *delegateArray;
@property (atomic, assign) BOOL isInitDownloadListener;

@end

@implementation FTXDownloadManager

#pragma mark - Lifecycle

- (instancetype)initWithChannelHandler:(VodMethodChannelHandler *)channelHandler {
    if (self = [super init]) {
        _channelHandler = channelHandler;
        _mPreloadQueue = dispatch_queue_create([@"cloud.tencent.com.preload" UTF8String], NULL);
        _delegateArray = [[NSMutableArray alloc] init];
        _isInitDownloadListener = NO;
    }
    return self;
}

- (void)initDownloadListenerIfNeed {
    if (self.isInitDownloadListener == NO) {
        self.isInitDownloadListener = YES;
        [[TXVodDownloadManager shareInstance] setDelegate:self];
    }
}

- (void)destroy {
    [[TXVodDownloadManager shareInstance] setDelegate:nil];
}

#pragma mark - MethodChannel dispatch

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    NSDictionary *args = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : @{};

    if ([@"startPreLoad" isEqualToString:method]) {
        NSString *playUrl = args[@"playUrl"];
        float preloadSizeMB = [args[@"preloadSizeMB"] floatValue];
        int preferredResolution = [args[@"preferredResolution"] intValue];
        int taskID = [[TXVodPreloadManager sharedManager] startPreload:playUrl
                                                           preloadSize:preloadSizeMB
                                                   preferredResolution:preferredResolution
                                                              delegate:self];
        result(@(taskID));
        return;
    }

    if ([@"stopPreLoad" isEqualToString:method]) {
        NSNumber *value = args[@"value"];
        [[TXVodPreloadManager sharedManager] stopPreload:[value intValue]];
        result(nil);
        return;
    }

    if ([@"startPreLoadByParams" isEqualToString:method]) {
        [self startPreLoadByParamsFromArgs:args];
        result(nil);
        return;
    }

    if ([@"startDownload" isEqualToString:method]) {
        [self startDownloadFromArgs:args];
        result(nil);
        return;
    }

    if ([@"resumeDownload" isEqualToString:method]) {
        [self resumeDownloadFromArgs:args];
        result(nil);
        return;
    }

    if ([@"stopDownload" isEqualToString:method]) {
        [self stopDownloadFromArgs:args];
        result(nil);
        return;
    }

    if ([@"setDownloadHeaders" isEqualToString:method]) {
        NSDictionary *map = args[@"map"];
        if ([map isKindOfClass:[NSDictionary class]]) {
            [[TXVodDownloadManager shareInstance] setHeaders:map];
        }
        result(nil);
        return;
    }

    if ([@"getDownloadList" isEqualToString:method]) {
        NSArray<TXVodDownloadMediaInfo *> *mediaInfoList = [[TXVodDownloadManager shareInstance] getDownloadMediaInfoList];
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:mediaInfoList.count];
        for (TXVodDownloadMediaInfo *info in mediaInfoList) {
            [resultArray addObject:[self buildMapFromDownloadMediaInfo:info]];
        }
        result(resultArray);
        return;
    }

    if ([@"getDownloadInfo" isEqualToString:method]) {
        TXVodDownloadMediaInfo *mediaInfo = [self parseMediaInfoFromArgs:args];
        result([self buildMapFromDownloadMediaInfo:mediaInfo]);
        return;
    }

    if ([@"deleteDownloadMediaInfo" isEqualToString:method]) {
        TXVodDownloadMediaInfo *mediaInfo = [self parseMediaInfoFromArgs:args];
        [[TXVodDownloadManager shareInstance] stopDownload:mediaInfo];
        BOOL deleteResult = [[TXVodDownloadManager shareInstance] deleteDownloadMediaInfo:mediaInfo];
        result(@(deleteResult));
        return;
    }

    result(FlutterMethodNotImplemented);
}

#pragma mark - Method Handlers

- (void)startDownloadFromArgs:(NSDictionary *)args {
    [self initDownloadListenerIfNeed];
    NSString *url = [self nullableString:args[@"url"]];
    NSNumber *appId = args[@"appId"];
    NSString *fileId = [self nullableString:args[@"fileId"]];
    NSString *userName = [self nullableString:args[@"userName"]] ?: @"default";
    NSString *pSign = [self nullableString:args[@"pSign"]];
    NSNumber *quality = args[@"quality"];

    if (url.length > 0) {
        [[TXVodDownloadManager shareInstance] startDownload:userName url:url];
    } else if (appId != nil && fileId.length > 0) {
        TXVodDownloadDataSource *dataSource = [[TXVodDownloadDataSource alloc] init];
        dataSource.appId = [appId intValue];
        dataSource.fileId = fileId;
        dataSource.userName = userName;
        dataSource.quality = [self optQuality:quality];
        dataSource.pSign = pSign;
        [[TXVodDownloadManager shareInstance] startDownload:dataSource];
    }
}

- (void)resumeDownloadFromArgs:(NSDictionary *)args {
    [self initDownloadListenerIfNeed];
    TXVodDownloadMediaInfo *mediaInfo = [self parseMediaInfoFromArgs:args];
    if (nil == mediaInfo) return;
    TXVodDownloadDataSource *dataSource = mediaInfo.dataSource;
    if (nil != dataSource) {
        [[TXVodDownloadManager shareInstance] startDownload:dataSource];
    } else {
        [[TXVodDownloadManager shareInstance] startDownload:mediaInfo.userName url:mediaInfo.url];
    }
}

- (void)stopDownloadFromArgs:(NSDictionary *)args {
    [self initDownloadListenerIfNeed];
    TXVodDownloadMediaInfo *mediaInfo = [self parseMediaInfoFromArgs:args];
    [[TXVodDownloadManager shareInstance] stopDownload:mediaInfo];
}

- (void)startPreLoadByParamsFromArgs:(NSDictionary *)args {
    NSString *playUrl = [self nullableString:args[@"playUrl"]];
    NSString *fileId = [self nullableString:args[@"fileId"]];
    NSNumber *appId = args[@"appId"];
    NSString *pSign = [self nullableString:args[@"pSign"]];
    NSNumber *preloadSizeMBArg = args[@"preloadSizeMB"];
    NSNumber *preferredResolutionArg = args[@"preferredResolution"];
    NSNumber *tmpPreloadTaskIdArg = args[@"tmpPreloadTaskId"];
    NSDictionary *httpHeader = args[@"httpHeader"];
    if (![httpHeader isKindOfClass:[NSDictionary class]]) httpHeader = @{};

    dispatch_async(self.mPreloadQueue, ^{
        BOOL isUrlPreload = playUrl.length > 0;
        float preloadSizeMB = [preloadSizeMBArg floatValue];
        int preferredResolution = [preferredResolutionArg intValue];
        long tmpTaskId = [tmpPreloadTaskIdArg longValue];
        NSString *safeFileId = fileId ?: @"";
        TXPlayerAuthParams *params = [[TXPlayerAuthParams alloc] init];
        params.url = playUrl;
        params.appId = appId != nil ? [appId intValue] : 0;
        params.fileId = safeFileId;
        params.sign = pSign ?: @"";
        params.headers = httpHeader;

        __block TXPredownloadFileHelperDelegate *delegate = [[TXPredownloadFileHelperDelegate alloc] initWithBlock:tmpTaskId
            start:^(long tmpTaskId, int taskID, NSString * _Nonnull fileId, NSString * _Nonnull url, NSDictionary * _Nonnull param) {
                [self onPreLoadStartEvent:tmpTaskId taskID:taskID fileId:fileId url:url param:param];
            } complete:^(int taskID, NSString * _Nonnull url) {
                [self onComplete:taskID url:url];
                [self removePreDelegate:delegate];
            } error:^(long tmpTaskId, int taskID, NSString * _Nonnull url, NSError * _Nonnull error) {
                [self onPreLoadErrorEvent:-1 taskId:taskID url:url error:error];
                [self removePreDelegate:delegate];
            }];
        [self addPreDelegate:delegate];
        int taskID = [[TXVodPreloadManager sharedManager] startPreloadWithModel:params
                                                                    preloadSize:preloadSizeMB
                                                            preferredResolution:preferredResolution
                                                                       delegate:delegate];
        if (isUrlPreload && tmpTaskId >= 0) {
            [self onPreLoadStartEvent:tmpTaskId taskID:taskID fileId:safeFileId url:playUrl param:@{}];
        }
    });
}

#pragma mark - Helpers

- (NSString *)nullableString:(id)obj {
    if (obj == nil || obj == [NSNull null]) return nil;
    if ([obj isKindOfClass:[NSString class]]) return obj;
    return nil;
}

- (int)optQuality:(NSNumber *)quality {
    return nil == quality ? TXVodQualityFLU : [quality intValue];
}

- (TXVodDownloadMediaInfo *)parseMediaInfoFromArgs:(NSDictionary *)args {
    NSNumber *quality = args[@"quality"];
    NSString *url = [self nullableString:args[@"url"]];
    NSNumber *appId = args[@"appId"];
    NSString *fileId = [self nullableString:args[@"fileId"]];
    NSString *userName = [self nullableString:args[@"userName"]] ?: @"default";
    return [self parseMediaInfoFromInfo:quality url:url appId:appId fileId:fileId name:userName];
}

- (TXVodDownloadMediaInfo *)parseMediaInfoFromInfo:(NSNumber *)quality
                                               url:(NSString *)videoUrl
                                             appId:(NSNumber *)pAppId
                                            fileId:(NSString *)pFileId
                                              name:(NSString *)name {
    TXVodDownloadMediaInfo *mediaInfo = nil;
    if (name == nil) {
        name = @"default";
    }
    if (nil != pFileId && nil != pAppId) {
        TXVodDownloadMediaInfo *fileIdInfo = [[TXVodDownloadMediaInfo alloc] init];
        TXVodDownloadDataSource *dataSource = [[TXVodDownloadDataSource alloc] init];
        dataSource.appId = [pAppId intValue];
        dataSource.fileId = pFileId;
        dataSource.quality = [self optQuality:quality];
        dataSource.userName = name;
        fileIdInfo.dataSource = dataSource;
        mediaInfo = [[TXVodDownloadManager shareInstance] getDownloadMediaInfo:fileIdInfo];
    } else if (nil != videoUrl) {
        TXVodDownloadMediaInfo *urlInfo = [[TXVodDownloadMediaInfo alloc] init];
        urlInfo.url = videoUrl;
        urlInfo.userName = name;
        mediaInfo = [[TXVodDownloadManager shareInstance] getDownloadMediaInfo:urlInfo];
    }
    return mediaInfo;
}

- (NSMutableDictionary *)buildMapFromDownloadMediaInfo:(TXVodDownloadMediaInfo *)info {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (nil != info) {
        [dict setValue:info.playPath forKey:@"playPath"];
        [dict setValue:@(info.progress) forKey:@"progress"];
        [dict setValue:[TXCommonUtil getDownloadEventByState:(int)info.downloadState] forKey:@"downloadState"];
        [dict setValue:info.userName forKey:@"userName"];
        [dict setValue:@(info.duration) forKey:@"duration"];
        [dict setValue:@(info.playableDuration) forKey:@"playableDuration"];
        [dict setValue:@(info.size) forKey:@"size"];
        [dict setValue:@(info.downloadSize) forKey:@"downloadSize"];
        if (info.url.length > 0) {
            [dict setValue:info.url forKey:@"url"];
        }
        if (nil != info.dataSource) {
            TXVodDownloadDataSource *dataSource = info.dataSource;
            [dict setValue:@(dataSource.appId) forKey:@"appId"];
            [dict setValue:dataSource.fileId forKey:@"fileId"];
            [dict setValue:dataSource.pSign forKey:@"pSign"];
            [dict setValue:@(dataSource.quality) forKey:@"quality"];
            [dict setValue:dataSource.token forKey:@"token"];
        }
        [dict setValue:@(info.speed) forKey:@"speed"];
        [dict setValue:@(info.isResourceBroken) forKey:@"isResourceBroken"];
    }
    return dict;
}

- (void)removePreDelegate:(TXPredownloadFileHelperDelegate *)delegate {
    @synchronized (self.delegateArray) {
        [self.delegateArray removeObject:delegate];
    }
}

- (void)addPreDelegate:(TXPredownloadFileHelperDelegate *)delegate {
    @synchronized (self.delegateArray) {
        if (![self.delegateArray containsObject:delegate]) {
            [self.delegateArray addObject:delegate];
        }
    }
}

#pragma mark - Preload callbacks (helper)

- (void)onPreLoadStartEvent:(long)tmpTaskId taskID:(int)taskID fileId:(NSString *)fileId url:(NSString *)url param:(NSDictionary *)param {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(tmpTaskId) forKey:@"tmpTaskId"];
    [dict setObject:@(taskID) forKey:@"taskId"];
    if (fileId) [dict setObject:fileId forKey:@"fileId"];
    if (url) [dict setObject:url forKey:@"url"];
    if (param) [dict setObject:param forKey:@"param"];
    [self onPreloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_PREDOWNLOAD_ON_START withParams:dict]];
}

- (void)onPreLoadErrorEvent:(long)tmpTaskId taskId:(int)taskID url:(NSString *)url error:(NSError *)error {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (tmpTaskId >= 0) {
        [dict setObject:@(tmpTaskId) forKey:@"tmpTaskId"];
    }
    [dict setObject:@(taskID) forKey:@"taskId"];
    if (url) [dict setObject:url forKey:@"url"];
    [dict setObject:@(error.code) forKey:@"code"];
    if (nil != error.userInfo.description) {
        [dict setObject:error.userInfo.description forKey:@"msg"];
    }
    [self onPreloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_PREDOWNLOAD_ON_ERROR withParams:dict]];
}

- (void)onPreloadCallback:(NSDictionary<NSString *, id> *)arg_event {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.channelHandler invokePreDownloadEvent:arg_event];
    });
}

#pragma mark - TXVodPreloadManagerDelegate

- (void)onComplete:(int)taskID url:(NSString *)url {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(taskID) forKey:@"taskId"];
    [dict setObject:url forKey:@"url"];
    [self onPreloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_PREDOWNLOAD_ON_COMPLETE withParams:dict]];
}

- (void)onError:(int)taskID url:(NSString *)url error:(NSError *)error {
    [self onPreLoadErrorEvent:-1 taskId:taskID url:url error:error];
}

#pragma mark - TXVodDownloadDelegate

- (void)onDownloadStart:(TXVodDownloadMediaInfo *)mediaInfo {
    [self onDownloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_DOWNLOAD_START withParams:[self buildMapFromDownloadMediaInfo:mediaInfo]]];
}

- (void)onDownloadProgress:(TXVodDownloadMediaInfo *)mediaInfo {
    [self onDownloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_DOWNLOAD_PROGRESS withParams:[self buildMapFromDownloadMediaInfo:mediaInfo]]];
}

- (void)onDownloadStop:(TXVodDownloadMediaInfo *)mediaInfo {
    [self onDownloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_DOWNLOAD_STOP withParams:[self buildMapFromDownloadMediaInfo:mediaInfo]]];
}

- (void)onDownloadFinish:(TXVodDownloadMediaInfo *)mediaInfo {
    [self onDownloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_DOWNLOAD_FINISH withParams:[self buildMapFromDownloadMediaInfo:mediaInfo]]];
}

- (void)onDownloadError:(TXVodDownloadMediaInfo *)mediaInfo errorCode:(TXDownloadError)code errorMsg:(NSString *)msg {
    NSMutableDictionary *dict = [self buildMapFromDownloadMediaInfo:mediaInfo];
    [dict setValue:@(code) forKey:@"errorCode"];
    [dict setValue:msg forKey:@"errorMsg"];
    [self onDownloadCallback:[TXCommonUtil getParamsWithEvent:EVENT_DOWNLOAD_ERROR withParams:dict]];
}

/// HLS key 校验：ijk 遗留暂时弃用。
- (int)hlsKeyVerify:(TXVodDownloadMediaInfo *)mediaInfo url:(NSString *)url data:(NSData *)data {
    return 0;
}

- (void)onDownloadCallback:(NSDictionary<NSString *, id> *)arg_event {
    [self.channelHandler invokeDownloadEvent:arg_event];
}

@end
