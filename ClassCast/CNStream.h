//
//  CNStream.h
//  ClassCast
//
//  Created by Manny on 4/27/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef NS_ENUM(NSUInteger, CNStreamState) {
    CNStreamStateUndefined = 0,
    CNStreamStateStreaming = 1,
    CNStreamStatePaused = 2,
    CNStreamStateStopped = 3,
    CNStreamStateFinished = 4,
    CNStreamStateFailed = 5
};

@interface CNStream : NSObject

@property (nonatomic, strong) NSString *streamId;
@property (nonatomic) CNStreamState state;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

+ (CNStream *)CNStreamFromPFObject:(PFObject *)object;

@end
