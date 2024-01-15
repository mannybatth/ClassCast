//
//  CNFrame.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNFrame.h"

@implementation CNFrame

- (id) initWithData:(NSData*)data pts:(CMTime)pts {
    if (self = [super init]) {
        _data = data;
        _pts = pts;
    }
    return self;
}

@end
