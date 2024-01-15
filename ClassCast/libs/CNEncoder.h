//
//  CNEncoder.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class CNFrame, CNEncoder;

@protocol CNSampleBufferEncoder <NSObject>
- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@protocol CNEncoderDelegate <NSObject>
- (void) encoder:(CNEncoder*)encoder encodedFrame:(CNFrame*)frame;
@end

@interface CNEncoder : NSObject

@property (nonatomic) NSUInteger bitrate;
@property (nonatomic) dispatch_queue_t callbackQueue;
@property (nonatomic, weak) id<CNEncoderDelegate> delegate;

- (instancetype) initWithBitrate:(NSUInteger)bitrate;

@end
