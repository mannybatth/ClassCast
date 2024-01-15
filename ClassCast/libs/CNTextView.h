//
//  CNTextView.h
//  CNiPhoneApp
//
//  Created by Manny on 3/6/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "HPGrowingTextView.h"

@protocol CNTextViewDelegate <NSObject>

@optional
- (void)onCNTextViewSubmitClick:(NSString*)text;
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;

@end

@interface CNTextView : UIView

@property (nonatomic,weak) id<CNTextViewDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HPGrowingTextView *hpTextView;
@property (nonatomic, strong) UIButton *submitBtn;

- (id)initWithTableView:(UITableView*)tableView frame:(CGRect)frame placeholder:(NSString*)placeholder;
- (void)resignTextView;

@end
