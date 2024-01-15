//
//  CNAudioEncoder.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNEncoder.h"

@interface CNAudioEncoder : CNEncoder

@property (nonatomic) NSUInteger sampleRate;
@property (nonatomic) NSUInteger channels;

- (instancetype) initWithBitrate:(NSUInteger)bitrate sampleRate:(NSUInteger)sampleRate channels:(NSUInteger)channels;

@end
