//
//  CNEncoder.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNEncoder.h"

@implementation CNEncoder

- (instancetype) initWithBitrate:(NSUInteger)bitrate {
    if (self = [super init]) {
        self.bitrate = bitrate;
        self.callbackQueue = dispatch_queue_create("CNEncoder Callback Queue", NULL);
    }
    return self;
}

@end
