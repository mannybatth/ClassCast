//
//  StreamStore.m
//  ClassCast
//
//  Created by Manny on 4/27/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "StreamStore.h"

@implementation StreamStore

+ (void)createNewStreamWithBlock:(void (^)(CNStream *, NSString *))block
{
    PFObject *object = [PFObject objectWithClassName:@"Streams"];
    object[@"state"] = [NSNumber numberWithInt:0];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        CNStream *stream = [CNStream CNStreamFromPFObject:object];
        block(stream, error.localizedDescription);
    }];
}

+ (void)startStream:(CNStream *)stream block:(void (^)(BOOL, NSString *))block
{
    PFObject *theStream = [PFObject objectWithoutDataWithClassName:@"Streams" objectId:stream.streamId];
    theStream[@"state"] = [NSNumber numberWithInt:CNStreamStateStreaming];
    [theStream saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        stream.state = CNStreamStateFinished;
        block(succeeded, error.localizedDescription);
    }];
}

+ (void)finishStream:(CNStream *)stream block:(void (^)(BOOL , NSString *))block
{
    PFObject *theStream = [PFObject objectWithoutDataWithClassName:@"Streams" objectId:stream.streamId];
    theStream[@"state"] = [NSNumber numberWithInt:CNStreamStateFinished];
    [theStream saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        stream.state = CNStreamStateFinished;
        block(succeeded, error.localizedDescription);
    }];
}

+ (void)getStreams:(void (^)(NSArray *, NSString *))block
{
    PFQuery *query1 = [PFQuery queryWithClassName:@"Streams"];
    [query1 whereKey:@"state" equalTo:[NSNumber numberWithInt:CNStreamStateStreaming]];
    PFQuery *query2 = [PFQuery queryWithClassName:@"Streams"];
    [query2 whereKey:@"state" equalTo:[NSNumber numberWithInt:CNStreamStateFinished]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *streamsList = [NSMutableArray new];
        [objects enumerateObjectsUsingBlock:^(PFObject *object, NSUInteger idx, BOOL *stop) {
            
            CNStream *stream = [CNStream CNStreamFromPFObject:object];
            [streamsList addObject:stream];
            
        }];
        block(streamsList, error.localizedDescription);
    }];
}

@end
