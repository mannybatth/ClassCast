//
//  CNHLSUploader.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectoryWatcher.h"
#import "CNHLSManifestGenerator.h"

@class CNHLSUploader, CNStream;

@protocol CNHLSUploaderDelegate <NSObject>
@optional
- (void) uploader:(CNHLSUploader*)uploader didUploadSegmentAtURL:(NSURL*)segmentURL uploadSpeed:(double)uploadSpeed numberOfQueuedSegments:(NSUInteger)numberOfQueuedSegments; //KBps
- (void) uploader:(CNHLSUploader *)uploader liveManifestReadyAtURL:(NSURL*)manifestURL;
- (void) uploader:(CNHLSUploader *)uploader vodManifestReadyAtURL:(NSURL*)manifestURL;
- (void) uploader:(CNHLSUploader *)uploader thumbnailReadyAtURL:(NSURL*)manifestURL;
- (void) uploaderHasFinished:(CNHLSUploader*)uploader;
@end

@interface CNHLSUploader : NSObject <DirectoryWatcherDelegate>

@property (nonatomic, weak) id<CNHLSUploaderDelegate> delegate;
@property (readonly, nonatomic, strong) NSString *directoryPath;
@property (nonatomic) dispatch_queue_t scanningQueue;
@property (nonatomic) dispatch_queue_t callbackQueue;
@property (nonatomic, strong) CNStream *stream;
@property (nonatomic, strong) CNHLSManifestGenerator *manifestGenerator;

- (id) initWithDirectoryPath:(NSString*)directoryPath stream:(CNStream*)stream;
- (void) finishedRecording;

- (NSURL*) manifestURL;

@end
