//
//  CNAudioEncoder.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNAudioEncoder.h"

@implementation CNAudioEncoder

- (instancetype) initWithBitrate:(NSUInteger)bitrate sampleRate:(NSUInteger)sampleRate channels:(NSUInteger)channels {
    if (self = [super initWithBitrate:bitrate]) {
        self.sampleRate = sampleRate;
        self.channels = channels;
    }
    return self;
}

@end
