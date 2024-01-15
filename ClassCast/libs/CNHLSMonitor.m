//
//  CNHLSMonitor.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNHLSMonitor.h"
#import "CNHLSUploader.h"
//#import "KFLog.h"

@interface CNHLSMonitor()

@property (nonatomic, strong) NSMutableDictionary *hlsUploaders;
@property (nonatomic) dispatch_queue_t monitorQueue;

@end

static CNHLSMonitor *_sharedMonitor = nil;

@implementation CNHLSMonitor

+ (CNHLSMonitor*) sharedMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMonitor = [[CNHLSMonitor alloc] init];
    });
    return _sharedMonitor;
}

- (id) init {
    if (self = [super init]) {
        self.hlsUploaders = [NSMutableDictionary dictionary];
        self.monitorQueue = dispatch_queue_create("CNHLSMonitor Queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void) startMonitoringFolderPath:(NSString *)path stream:(CNStream*)stream delegate:(id<CNHLSUploaderDelegate>)delegate {
    dispatch_async(self.monitorQueue, ^{
        CNHLSUploader *hlsUploader = [[CNHLSUploader alloc] initWithDirectoryPath:path stream:stream];
        hlsUploader.delegate = delegate;
        [self.hlsUploaders setObject:hlsUploader forKey:path];
    });
}

- (void) finishUploadingContentsAtFolderPath:(NSString*)path stream:(CNStream*)stream {
    dispatch_async(self.monitorQueue, ^{
        CNHLSUploader *hlsUploader = [self.hlsUploaders objectForKey:path];
        if (!hlsUploader) {
            hlsUploader = [[CNHLSUploader alloc] initWithDirectoryPath:path stream:stream];
            [self.hlsUploaders setObject:hlsUploader forKey:path];
        }
        hlsUploader.delegate = self;
        [hlsUploader finishedRecording];
    });
}

- (void) uploaderHasFinished:(CNHLSUploader*)uploader {
    NSLog(@"Uploader finished, switched to VOD manifest");
    dispatch_async(self.monitorQueue, ^{
        [self.hlsUploaders removeObjectForKey:uploader.directoryPath];
    });
}

@end
