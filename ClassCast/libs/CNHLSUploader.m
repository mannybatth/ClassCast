//
//  CNHLSUploader.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNHLSUploader.h"
#import "UploadFileStore.h"
#import "CNStream.h"
//#import "KFLog.h"

static NSString * const kManifestKey =  @"manifest";
static NSString * const kFileNameKey = @"fileName";
static NSString * const kVODManifestFileName = @"vod.m3u8";


static NSString * const kUploadStateQueued = @"queued";
static NSString * const kUploadStateFinished = @"finished";
static NSString * const kUploadStateUploading = @"uploading";
static NSString * const kUploadStateFailed = @"failed";

@interface CNHLSUploader()

@property (nonatomic) NSUInteger numbersOffset;
@property (nonatomic, strong) NSMutableDictionary *queuedSegments;
@property (nonatomic) NSUInteger nextSegmentIndexToUpload;
//@property (nonatomic, strong) OWS3Client *s3Client;
@property (nonatomic, strong) DirectoryWatcher *directoryWatcher;
@property (atomic, strong) NSMutableDictionary *files;
@property (nonatomic, strong) NSString *manifestPath;
@property (nonatomic) BOOL manifestReady;
@property (nonatomic, strong) NSString *finalManifestString;
@property (nonatomic) BOOL isFinishedRecording;
@property (nonatomic) BOOL hasUploadedFinalManifest;

@end

@implementation CNHLSUploader

- (id) initWithDirectoryPath:(NSString *)directoryPath stream:(CNStream*)stream {
    if (self = [super init]) {
        self.stream = stream;
        _directoryPath = [directoryPath copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.directoryWatcher = [DirectoryWatcher watchFolderWithPath:_directoryPath delegate:self];
        });
        _files = [NSMutableDictionary dictionary];
        _scanningQueue = dispatch_queue_create("CNHLSUploader Scanning Queue", DISPATCH_QUEUE_SERIAL);
        _callbackQueue = dispatch_queue_create("CNHLSUploader Callback Queue", DISPATCH_QUEUE_SERIAL);
        _queuedSegments = [NSMutableDictionary dictionaryWithCapacity:5];
        _numbersOffset = 0;
        _nextSegmentIndexToUpload = 0;
        _manifestReady = NO;
        _isFinishedRecording = NO;
        self.manifestGenerator = [[CNHLSManifestGenerator alloc] initWithTargetDuration:10 playlistType:CNHLSManifestPlaylistTypeVOD];
    }
    return self;
}

#warning This code is buggy and doesnt finish uploading all segments or the VOD properly
- (void) finishedRecording {
    self.isFinishedRecording = YES;
    if (!self.hasUploadedFinalManifest) {
        NSString *manifestSnapshot = [self manifestSnapshot];
        NSLog(@"final manifest snapshot: %@", manifestSnapshot);
        [self.manifestGenerator appendFromLiveManifest:manifestSnapshot];
        [self.manifestGenerator finalizeManifest];
        NSString *manifestString = [self.manifestGenerator manifestString];
        [self updateManifestWithString:manifestString manifestName:kVODManifestFileName];
    }
}

- (void) uploadNextSegment
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:nil];
    NSUInteger tsFileCount = 0;
    for (NSString *fileName in contents) {
        if ([[fileName pathExtension] isEqualToString:@"ts"]) {
            tsFileCount++;
        }
    }
    
    NSDictionary *segmentInfo = [_queuedSegments objectForKey:@(_nextSegmentIndexToUpload)];
    
    // Skip uploading files that are currently being written
    if (tsFileCount == 1 && !self.isFinishedRecording) {
        NSLog(@"Skipping upload of ts file currently being recorded: %@ %@", segmentInfo, contents);
        return;
    }
    
    NSString *manifest = [segmentInfo objectForKey:kManifestKey];
    NSString *fileName = [segmentInfo objectForKey:kFileNameKey];
    NSString *fileUploadState = [_files objectForKey:fileName];
    if (![fileUploadState isEqualToString:kUploadStateQueued]) {
        NSLog(@"Trying to upload file that isn't queued (%@): %@", fileUploadState, segmentInfo);
        return;
    }
    [_files setObject:kUploadStateUploading forKey:fileName];
    NSString *filePath = [_directoryPath stringByAppendingPathComponent:fileName];
    
    NSDate *uploadStartDate = [NSDate date];
    NSError *error = nil;
    NSDictionary *fileStats = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"Error getting stats of path %@: %@", filePath, error);
    }
    uint64_t fileSize = [fileStats fileSize];
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    [UploadFileStore uploadFile:fileData fileName:fileName mimeType:@"video/MP2T" forStream:self.stream block:^(NSDictionary *response, NSString *error) {
        if (error) {
            dispatch_async(_scanningQueue, ^{
                [_files setObject:kUploadStateQueued forKey:fileName];
                NSLog(@"Failed to upload segment, requeuing %@: %@", fileName, error.description);
                [self uploadNextSegment];
            });
            return;
            
        }
        
        dispatch_async(_scanningQueue, ^{
            NSDate *uploadFinishDate = [NSDate date];
            NSTimeInterval timeToUpload = [uploadFinishDate timeIntervalSinceDate:uploadStartDate];
            double bytesPerSecond = fileSize / timeToUpload;
            double KBps = bytesPerSecond / 1024;
            [_files setObject:kUploadStateFinished forKey:fileName];
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"Error removing uploaded segment: %@", error.description);
            }
            [_queuedSegments removeObjectForKey:@(_nextSegmentIndexToUpload)];
            NSUInteger queuedSegmentsCount = _queuedSegments.count;
            [self updateManifestWithString:manifest manifestName:@"index.m3u8"];
            _nextSegmentIndexToUpload++;
            [self uploadNextSegment];
            if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:didUploadSegmentAtURL:uploadSpeed:numberOfQueuedSegments:)]) {
                NSURL *url = [self urlWithFileName:fileName];
                dispatch_async(self.callbackQueue, ^{
                    [self.delegate uploader:self didUploadSegmentAtURL:url uploadSpeed:KBps numberOfQueuedSegments:queuedSegmentsCount];
                });
            }
        });
    }];
}

- (void) updateManifestWithString:(NSString*)manifestString manifestName:(NSString*)manifestName
{
    NSData *data = [manifestString dataUsingEncoding:NSUTF8StringEncoding];
    [UploadFileStore uploadFile:data fileName:manifestName mimeType:@"application/x-mpegURL" forStream:self.stream block:^(NSDictionary *response, NSString *error) {
        if (error) {
            NSLog(@"Error updating manifest: %@", error.description);
            return;
        }
        
        dispatch_async(self.callbackQueue, ^{
            if (!_manifestReady) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:liveManifestReadyAtURL:)]) {
                    [self.delegate uploader:self liveManifestReadyAtURL:[self manifestURL]];
                }
                _manifestReady = YES;
            }
            if (self.isFinishedRecording && _queuedSegments.count == 0) {
                self.hasUploadedFinalManifest = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:vodManifestReadyAtURL:)]) {
                    [self.delegate uploader:self vodManifestReadyAtURL:[self manifestURL]];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(uploaderHasFinished:)]) {
                    [self.delegate uploaderHasFinished:self];
                }
            }
        });
    }];
}

- (void) directoryDidChange:(DirectoryWatcher *)folderWatcher
{
    dispatch_async(_scanningQueue, ^{
        NSError *error = nil;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_directoryPath error:&error];
        NSLog(@"Directory changed, fileCount: %lu", (unsigned long)files.count);
        if (error) {
            NSLog(@"Error listing directory contents");
        }
        if (!_manifestPath) {
            [self initializeManifestPathFromFiles:files];
        }
        [self detectNewSegmentsFromFiles:files];
    });
}

- (void) detectNewSegmentsFromFiles:(NSArray*)files {
    if (!_manifestPath) {
        NSLog(@"Manifest path not yet available");
        return;
    }
    [files enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        NSArray *components = [fileName componentsSeparatedByString:@"."];
        NSString *filePrefix = [components firstObject];
        NSString *fileExtension = [components lastObject];
        if ([fileExtension isEqualToString:@"ts"]) {
            NSString *uploadState = [_files objectForKey:fileName];
            if (!uploadState) {
                NSString *manifestSnapshot = [self manifestSnapshot];
                [self.manifestGenerator appendFromLiveManifest:manifestSnapshot];
                NSUInteger segmentIndex = [self indexForFilePrefix:filePrefix];
                NSDictionary *segmentInfo = @{kManifestKey: manifestSnapshot,
                                              kFileNameKey: fileName};
                NSLog(@"new ts file detected: %@", fileName);
                [_files setObject:kUploadStateQueued forKey:fileName];
                [_queuedSegments setObject:segmentInfo forKey:@(segmentIndex)];
                [self uploadNextSegment];
            }
        } else if ([fileExtension isEqualToString:@"jpg"]) {
            //[self uploadThumbnail:fileName];
        }
    }];
}

- (void) initializeManifestPathFromFiles:(NSArray*)files {
    [files enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        if ([[fileName pathExtension] isEqualToString:@"m3u8"]) {
            NSArray *components = [fileName componentsSeparatedByString:@"."];
            NSString *filePrefix = [components firstObject];
            _manifestPath = [_directoryPath stringByAppendingPathComponent:fileName];
            _numbersOffset = filePrefix.length;
            NSAssert(_numbersOffset > 0, nil);
            *stop = YES;
        }
    }];
}

- (NSString*) manifestSnapshot {
    return [NSString stringWithContentsOfFile:_manifestPath encoding:NSUTF8StringEncoding error:nil];
}

- (NSUInteger) indexForFilePrefix:(NSString*)filePrefix {
    NSString *numbers = [filePrefix substringFromIndex:_numbersOffset];
    return [numbers integerValue];
}

- (NSURL*) urlWithFileName:(NSString*)fileName {
//    NSString *key = [self awsKeyForStream:self.stream fileName:fileName];
//    NSString *ssl = @"";
//    if (self.useSSL) {
//        ssl = @"s";
//    }
//    NSString *urlString = [NSString stringWithFormat:@"http%@://%@.s3.amazonaws.com/%@", ssl, self.stream.bucketName, key];
//    return [NSURL URLWithString:urlString];
    return nil;
}

- (NSURL*) manifestURL {
    NSString *manifestName = nil;
    if (self.isFinishedRecording) {
        manifestName = kVODManifestFileName;
    } else {
        manifestName = [_manifestPath lastPathComponent];
    }
    return [self urlWithFileName:manifestName];
}

@end
