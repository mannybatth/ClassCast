//
//  CNVideoEncoder.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNEncoder.h"

@interface CNVideoEncoder : CNEncoder

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

- (instancetype) initWithBitrate:(NSUInteger)bitrate width:(int)width height:(int)height;

@end
