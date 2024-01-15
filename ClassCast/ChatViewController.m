//
//  ChatViewController.m
//  ClassCast
//
//  Created by Manny on 5/7/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "ChatViewController.h"
#import "CNTextView.h"
#import "UIView+GCLibrary.h"

@interface ChatViewController () <CNTextViewDelegate, UITextViewDelegate>
{
    CGRect keyboardFrame;
}

@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    self.tableView.delegate = self.delegate;
    self.tableView.dataSource = self.delegate;
    self.textView.delegate = self;
    
    if (self.isBroadcaster) {
        self.viewerName = @"Broadcaster";
    }
    if (!self.viewerName) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"What is your name?"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Continue"
                                               otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(onCloseBtnClick:)];
    [self.navigationItem setLeftBarButtonItem:closeBtn animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *text = [[alertView textFieldAtIndex:0] text];
    self.viewerName = text;
    if ([self.delegate respondsToSelector:@selector(saveViewerName:)]) {
        [self.delegate saveViewerName:self.viewerName];
    }
}

- (void)onCloseBtnClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCNSubmitBtnClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(publishChatMessage:text:)]) {
        [self.delegate publishChatMessage:self.viewerName text:self.textView.text];
        self.textView.text = @"";
        [self.textView resignFirstResponder];
    }
}

- (void)scrollToBottomOfTableView
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height - self.tableView.contentInset.bottom)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height + self.tableView.contentInset.bottom);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

#pragma mark -
#pragma mark UIKeyboard Delegates

- (void)keyboardWillHide:(NSNotification *)notification
{
    float duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    keyboardFrame = CGRectZero;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.CNTextView.height, 0.0);
    
    CGSize screenSize = self.tableView.superview.bounds.size;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.CNTextView.y = screenSize.height - self.CNTextView.height;
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height+self.CNTextView.height, 0.0);
    
    CGSize screenSize = self.tableView.superview.bounds.size;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.CNTextView.y = screenSize.height - (keyboardFrame.size.height + self.CNTextView.height);
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
