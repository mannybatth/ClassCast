//
//  ChatViewController.h
//  ClassCast
//
//  Created by Manny on 5/7/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUIAutoGrowingTextView.h"

@protocol StreamChatDelegate <NSObject>

@required
- (void)publishChatMessage:(NSString*)name text:(NSString *)text;
- (void)saveViewerName:(NSString*)name;

@end

@interface ChatViewController : UIViewController

@property (nonatomic, weak) UIViewController<StreamChatDelegate, UITableViewDelegate, UITableViewDataSource> *delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *CNTextView;
@property (nonatomic, strong) IBOutlet UIButton *submitBtn;
@property (nonatomic, strong) IBOutlet AUIAutoGrowingTextView *textView;

@property (nonatomic) BOOL isBroadcaster;
@property (nonatomic) NSString *viewerName;

@end
