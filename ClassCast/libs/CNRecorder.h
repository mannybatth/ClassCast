//
//  CNRecorder.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CNAACEncoder.h"
#import "CNH264Encoder.h"
#import "CNHLSUploader.h"

@class CNRecorder, CNHLSWriter, CNStream;

@protocol CNRecorderDelegate <NSObject>
- (void) recorderDidStartRecording:(CNRecorder*)recorder error:(NSError*)error;
- (void) recorderDidFinishRecording:(CNRecorder*)recorder error:(NSError*)error;
- (void) recorder:(CNRecorder*)recorder streamReadyAtURL:(NSURL*)url;
@end

@interface CNRecorder : NSObject <CNEncoderDelegate, CNHLSUploaderDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession* session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput* videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput* audioOutput;
@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) dispatch_queue_t audioQueue;
@property (nonatomic, strong) AVCaptureConnection* audioConnection;
@property (nonatomic, strong) AVCaptureConnection* videoConnection;

@property (nonatomic, strong) CNAACEncoder *aacEncoder;
@property (nonatomic, strong) CNH264Encoder *h264Encoder;
@property (nonatomic, strong) CNHLSWriter *hlsWriter;
@property (nonatomic, strong) CNStream *stream;

@property (nonatomic) NSUInteger videoWidth;
@property (nonatomic) NSUInteger videoHeight;
@property (nonatomic) NSUInteger audioSampleRate;

@property (nonatomic) BOOL isRecording;

@property (nonatomic, weak) id<CNRecorderDelegate> delegate;

- (void) startRecording:(CNStream*)stream;
- (void) stopRecording;

@end
