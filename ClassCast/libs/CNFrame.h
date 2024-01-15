//
//  CNFrame.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CNFrame : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic) CMTime pts;

- (instancetype) initWithData:(NSData*)data pts:(CMTime)pts;

@end
