//
//  CNTextView.m
//  CNiPhoneApp
//
//  Created by Manny on 3/6/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "CNTextView.h"
#import "UIView+GCLibrary.h"

@interface CNTextView() <HPGrowingTextViewDelegate>
{
    CGRect keyboardFrame;
}

@end

@implementation CNTextView

@synthesize hpTextView, submitBtn;

- (id)initWithTableView:(UITableView*)tableView frame:(CGRect)frame placeholder:(NSString*)placeholder
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tableView = tableView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        
        [self setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.frame.size.height, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextView)];
        tap.cancelsTouchesInView = NO;
        [self.tableView addGestureRecognizer:tap];
        
        hpTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 6, 242, 43)];
        hpTextView.isScrollable = YES;
        hpTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        hpTextView.minNumberOfLines = 1;
        hpTextView.maxNumberOfLines = 5;
        hpTextView.returnKeyType = UIReturnKeyDefault;
        hpTextView.font = [UIFont systemFontOfSize:14.0f];
        hpTextView.delegate = self;
        hpTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        hpTextView.backgroundColor = [UIColor whiteColor];
        hpTextView.placeholder = placeholder;
        [self addSubview:hpTextView];
        
        submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        submitBtn.frame = CGRectMake(self.frame.size.width - 70, 6, 58, 35);
        [submitBtn setBackgroundImage:[UIImage imageNamed:@"send_message_btn"] forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(onSumbitBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:submitBtn];
        
    }
    return self;
}

- (void)resignTextView
{
	[hpTextView resignFirstResponder];
}

- (void)onSumbitBtnClick
{
    [self resignTextView];
    if ([self.delegate respondsToSelector:@selector(onCNTextViewSubmitClick:)]) {
        [self.delegate onCNTextViewSubmitClick:hpTextView.text];
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.height, 0.0);
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UIKeyboard Delegates

- (void)keyboardWillHide:(NSNotification *)notification
{
    float duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    keyboardFrame = CGRectZero;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.height, 0.0);
    
    CGSize screenSize = self.tableView.superview.bounds.size;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.y = screenSize.height - self.height;
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    float duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    keyboardFrame = [self.tableView.superview convertRect:keyboardFrame fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height+self.height, 0.0);
    
    CGSize screenSize = self.tableView.superview.bounds.size;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.y = screenSize.height - (keyboardFrame.size.height + self.height);
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
        [self.delegate growingTextViewDidBeginEditing:growingTextView];
    }
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
        [self.delegate growingTextViewDidEndEditing:growingTextView];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    if ([self.delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [self.delegate growingTextView:growingTextView willChangeHeight:height];
    }
    
    float diff = (growingTextView.frame.size.height - height);
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height+r.size.height, 0.0);
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
	[UIView commitAnimations];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
