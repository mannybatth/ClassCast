//
//  CNHTTPClient.h
//  CNiPhoneApp
//
//  Created by Manny on 2/7/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "CNHTTPClient.h"

@implementation CNHTTPClient

+ (instancetype)sharedClient {
    static CNHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CNHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        [_sharedClient setRequestSerializer:[[AFJSONRequestSerializer alloc] init]];
    });
    
    return _sharedClient;
}

@end
