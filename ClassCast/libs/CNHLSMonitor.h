//
//  CNHLSMonitor.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNHLSUploader.h"

@interface CNHLSMonitor : NSObject <CNHLSUploaderDelegate>

+ (CNHLSMonitor*) sharedMonitor;

- (void) startMonitoringFolderPath:(NSString*)path stream:(CNStream*)stream delegate:(id<CNHLSUploaderDelegate>)delegate;
- (void) finishUploadingContentsAtFolderPath:(NSString*)path stream:(CNStream*)stream;

@end
