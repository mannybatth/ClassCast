//
//  CNHTTPClient.h
//  CNiPhoneApp
//
//  Created by Manny on 2/7/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface CNHTTPClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
