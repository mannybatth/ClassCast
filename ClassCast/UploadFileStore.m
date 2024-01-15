//
//  UploadFileStore.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "UploadFileStore.h"

@implementation UploadFileStore

+ (NSOperation *)uploadFile:(NSData *)fileData fileName:(NSString *)fileName mimeType:(NSString*)mimeType forStream:(CNStream*)stream  block:(void (^)(NSDictionary *, NSString *))block
{
    CNHTTPClient *httpClient = [CNHTTPClient sharedClient];
    
    NSDictionary *params = @{
                             @"streamId": stream.streamId
                             };
    
    NSString *path = [NSString stringWithFormat:@"%@/upload.php", BASE_URL_SUB_PATH];
    
    NSLog(@"API REQUEST: %@", [[NSURL URLWithString:path relativeToURL:httpClient.baseURL] absoluteString]);
    
    NSMutableURLRequest *request = [httpClient.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:httpClient.baseURL] absoluteString] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFormData:fileData name:@"upload_file"];
        [formData appendPartWithFileData:fileData name:@"upload_file" fileName:fileName mimeType:mimeType];
    } error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[[AFJSONResponseSerializer alloc] init]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@", JSON);
        block(JSON, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [httpClient.operationQueue cancelAllOperations];
        block(nil, error.localizedDescription);
        [UploadFileStore showErrorAlertWithTitle:@"Upload Failed" message:error.localizedDescription];
        
    }];
    
    [httpClient.operationQueue addOperation:operation];
    return operation;
}

+ (void)showErrorAlertWithTitle:(NSString*)title message:(NSString*)message
{
    NSLog(@"ERROR API: %@ -- %@", title, message);
}

@end
