//
//  StreamViewController.h
//  ClassCast
//
//  Created by Manny on 4/22/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNRecorder.h"
#import "CNStream.h"

@interface StreamViewController : UIViewController <CNRecorderDelegate>

@property (nonatomic, strong) CNRecorder *recorder;

@property (nonatomic, strong) CNStream *stream;
@property (nonatomic) BOOL isBroadcaster;
@property (nonatomic) NSString *viewerName;

@end
