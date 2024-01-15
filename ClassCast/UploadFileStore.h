//
//  UploadFileStore.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "AFNetworking.h"
#import "CNHTTPClient.h"
#import "CNStream.h"

@interface UploadFileStore : NSObject

+ (NSOperation*)uploadFile:(NSData *)fileData fileName:(NSString*)fileName mimeType:(NSString*)mimeType forStream:(CNStream*)stream block:(void (^)(NSDictionary *response, NSString *error))block;

@end
