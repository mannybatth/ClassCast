//
//  CNStream.m
//  ClassCast
//
//  Created by Manny on 4/27/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNStream.h"

@implementation CNStream

+ (CNStream *)CNStreamFromPFObject:(PFObject *)object
{
    CNStream *stream = [CNStream new];
    stream.streamId = object.objectId;
    stream.state = [object[@"state"] intValue];
    stream.createdAt = object[@"createdAt"];
    stream.updatedAt = object[@"updatedAt"];
    return stream;
}

@end
