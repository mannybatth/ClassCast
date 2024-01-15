//
//  CNAACEncoder.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNAudioEncoder.h"

@interface CNAACEncoder : CNAudioEncoder <CNSampleBufferEncoder>

@property (nonatomic) dispatch_queue_t encoderQueue;
@property (nonatomic) BOOL addADTSHeader;

@end
