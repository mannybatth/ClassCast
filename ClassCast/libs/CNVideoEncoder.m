//
//  CNVideoEncoder.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNVideoEncoder.h"

@implementation CNVideoEncoder

- (instancetype) initWithBitrate:(NSUInteger)bitrate width:(int)width height:(int)height {
    if (self = [super initWithBitrate:bitrate]) {
        _width = width;
        _height = height;
    }
    return self;
}

@end
