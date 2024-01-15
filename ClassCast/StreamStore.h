//
//  StreamStore.h
//  ClassCast
//
//  Created by Manny on 4/27/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNStream.h"

@interface StreamStore : NSObject

+ (void)createNewStreamWithBlock:(void (^)(CNStream *stream, NSString *error))block;
+ (void)startStream:(CNStream*)stream block:(void (^)(BOOL success, NSString *error))block;
+ (void)finishStream:(CNStream*)stream block:(void (^)(BOOL success, NSString *error))block;
+ (void)getStreams:(void (^)(NSArray *streams, NSString *error))block;

@end
