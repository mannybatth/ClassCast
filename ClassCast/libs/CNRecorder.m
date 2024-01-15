//
//  CNRecorder.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNRecorder.h"
#import "CNHLSMonitor.h"
#import "CNHLSWriter.h"
#import "CNFrame.h"
#import "CNVideoFrame.h"
#import "StreamStore.h"
//#import "KFLog.h"

@interface CNRecorder()

@property (nonatomic) double minBitrate;

@end

@implementation CNRecorder

- (id) init {
    if (self = [super init]) {
        _minBitrate = 300 * 1000;
        [self setupSession];
        [self setupEncoders];
    }
    return self;
}

- (void) setupSession {
    _session = [[AVCaptureSession alloc] init];
    [self setupVideoCapture];
    [self setupAudioCapture];
    
    // start capture and a preview layer
    [_session startRunning];
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void) setupVideoCapture
{
    NSError *error = nil;
    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (error) {
        NSLog(@"Error getting video input device: %@", error.description);
    }
    if ([_session canAddInput:videoInput]) {
        [_session addInput:videoInput];
    }
    
    // create an output for YUV output with self as delegate
    _videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    NSDictionary *captureSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    _videoOutput.videoSettings = captureSettings;
    _videoOutput.alwaysDiscardsLateVideoFrames = YES;
    if ([_session canAddOutput:_videoOutput]) {
        [_session addOutput:_videoOutput];
    }
    _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
}

- (AVCaptureVideoOrientation) avOrientationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
}

- (void) setupAudioCapture
{
    // create capture device with video input
    
    /*
     * Create audio connection
     */
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"Error getting audio input device: %@", error.description);
    }
    if ([_session canAddInput:audioInput]) {
        [_session addInput:audioInput];
    }
    
    _audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_audioOutput setSampleBufferDelegate:self queue:_audioQueue];
    if ([_session canAddOutput:_audioOutput]) {
        [_session addOutput:_audioOutput];
    }
    _audioConnection = [_audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (void) setupEncoders {
    self.audioSampleRate = 44100;
//    self.videoHeight = 720;
//    self.videoWidth = 1280;
    self.videoHeight = 360;
    self.videoWidth = 640;
    int audioBitrate = 64 * 1000; // 64 Kbps
    int maxBitrate = 700 * 1000;
    int videoBitrate = maxBitrate - audioBitrate;
    _h264Encoder = [[CNH264Encoder alloc] initWithBitrate:videoBitrate width:self.videoWidth height:self.videoHeight];
    _h264Encoder.delegate = self;
    
    _aacEncoder = [[CNAACEncoder alloc] initWithBitrate:audioBitrate sampleRate:self.audioSampleRate channels:1];
    _aacEncoder.delegate = self;
    _aacEncoder.addADTSHeader = YES;
}

- (void) startRecording:(CNStream*)stream
{
    self.stream = stream;
    self.stream.state = CNStreamStateStreaming;
    
    [StreamStore startStream:self.stream block:^(BOOL success, NSString *error) {
        
    }];
    
    [self setupHLSWriterWithEndpoint:self.stream];
    
    [[CNHLSMonitor sharedMonitor] startMonitoringFolderPath:_hlsWriter.directoryPath stream:self.stream delegate:self];
    
    NSError *e = nil;
    [_hlsWriter prepareForWriting:&e];
    if (e) {
        NSLog(@"Error preparing for writing: %@", e);
    }
    self.isRecording = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(recorderDidStartRecording:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recorderDidStartRecording:self error:nil];
        });
    }
}

- (void) stopRecording
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session stopRunning];
        self.isRecording = NO;
        NSError *error = nil;
        [_hlsWriter finishWriting:&error];
        if (error) {
            NSLog(@"Error stop recording: %@", error);
        }
        
        [StreamStore finishStream:self.stream block:^(BOOL success, NSString *error) {
            if (!success) {
                NSLog(@"Error stopping stream: %@", error);
            } else {
                NSLog(@"Stream stopped: %@", self.stream.streamId);
            }
        }];
        
        [[CNHLSMonitor sharedMonitor] finishUploadingContentsAtFolderPath:_hlsWriter.directoryPath stream:self.stream];
        if (self.delegate && [self.delegate respondsToSelector:@selector(recorderDidFinishRecording:error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate recorderDidFinishRecording:self error:error];
            });
        }
    });
}

- (void) setupHLSWriterWithEndpoint:(CNStream*)stream
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *folderName = [NSString stringWithFormat:@"%@.hls", stream.streamId];
    NSString *hlsDirectoryPath = [basePath stringByAppendingPathComponent:folderName];
    [[NSFileManager defaultManager] createDirectoryAtPath:hlsDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.hlsWriter = [[CNHLSWriter alloc] initWithDirectoryPath:hlsDirectoryPath];
    [_hlsWriter addVideoStreamWithWidth:self.videoWidth height:self.videoHeight];
    [_hlsWriter addAudioStreamWithSampleRate:self.audioSampleRate];
    
}

#pragma mark CNEncoderDelegate method
- (void) encoder:(CNEncoder*)encoder encodedFrame:(CNFrame *)frame
{
    if (encoder == _h264Encoder) {
        CNVideoFrame *videoFrame = (CNVideoFrame*)frame;
        [_hlsWriter processEncodedData:videoFrame.data presentationTimestamp:videoFrame.pts streamIndex:0 isKeyFrame:videoFrame.isKeyFrame];
    } else if (encoder == _aacEncoder) {
        [_hlsWriter processEncodedData:frame.data presentationTimestamp:frame.pts streamIndex:1 isKeyFrame:NO];
    }
}

#pragma mark AVCaptureOutputDelegate method
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!_isRecording) {
        return;
    }
    // pass frame to encoders
    if (connection == _videoConnection) {
//        if (!_hasScreenshot) {
//            UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
//            NSString *path = [self.hlsWriter.directoryPath stringByAppendingPathComponent:@"thumb.jpg"];
//            NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
//            [imageData writeToFile:path atomically:NO];
//            _hasScreenshot = YES;
//        }
        [_h264Encoder encodeSampleBuffer:sampleBuffer];
    } else if (connection == _audioConnection) {
        [_aacEncoder encodeSampleBuffer:sampleBuffer];
    }
}

#pragma mark CNHLSUploaderDelegate method
- (void) uploader:(CNHLSUploader *)uploader didUploadSegmentAtURL:(NSURL *)segmentURL uploadSpeed:(double)uploadSpeed numberOfQueuedSegments:(NSUInteger)numberOfQueuedSegments
{
    NSLog(@"[Background monitor] Uploaded segment %@ @ %f KB/s, numberOfQueuedSegments %d", segmentURL, uploadSpeed, numberOfQueuedSegments);
}

@end
