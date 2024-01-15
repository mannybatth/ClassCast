//
//  CNHLSWriter.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CNHLSWriter : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic) dispatch_queue_t conversionQueue;
@property (nonatomic, strong, readonly) NSString *directoryPath;

- (id) initWithDirectoryPath:(NSString*)directoryPath;

- (void) addVideoStreamWithWidth:(int)width height:(int)height;
- (void) addAudioStreamWithSampleRate:(int)sampleRate;

- (BOOL) prepareForWriting:(NSError**)error;

- (void) processEncodedData:(NSData*)data presentationTimestamp:(CMTime)pts streamIndex:(NSUInteger)streamIndex isKeyFrame:(BOOL)isKeyFrame; // TODO refactor this

- (BOOL) finishWriting:(NSError**)error;

@end
