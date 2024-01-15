//
//  StreamViewController.m
//  ClassCast
//
//  Created by Manny on 4/22/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "StreamViewController.h"
#import "ChatViewController.h"
#import "RecordButton.h"
#import "UIView+AutoLayout.h"
#import <Firebase/Firebase.h>
#import "Message.h"
#import "StreamStore.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface StreamViewController () <UITableViewDelegate, UITableViewDataSource, StreamChatDelegate>
{
    dispatch_group_t recorderTask;
    CGSize currentScreenSize;
    
    RecordButton *recordButton;
    Firebase *f;
    NSMutableArray *messages;
    
    ChatViewController *chatViewController;
    MPMoviePlayerController *player;
}

@property (nonatomic, strong) IBOutlet UIView *streamView;

@end

@implementation StreamViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    messages = [NSMutableArray new];
    
    if (!self.stream && self.isBroadcaster) {
        [self setupRecorder];
        [self setupRecordButton];
        [StreamStore createNewStreamWithBlock:^(CNStream *stream, NSString *error) {
            
            self.stream = stream;
            [self setupFireBase];
            
        }];
    } else {
        [self setupMoviePlayer];
        [self setupFireBase];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    currentScreenSize = [self currentSize];
    
    if (recorderTask) {
        dispatch_queue_t waitingQueue = dispatch_queue_create("com.thecn.ClassCast.waitingQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(waitingQueue, ^{
            // Waiting for threads
            dispatch_group_wait(recorderTask, DISPATCH_TIME_FOREVER);
            
            // Background work complete
            dispatch_async(dispatch_get_main_queue(), ^{
                self.streamView.frame = self.view.bounds;
                [self checkViewOrientation:animated];
                [self startPreview];
            });
        });
    }
}

- (void)setupFireBase
{
    f = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE_URL, self.stream.streamId]];
    [f observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        
        NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
        
        Message *message = [Message new];
        message.name = [snapshot.value objectForKey:@"name"];
        message.text = [snapshot.value objectForKey:@"text"];
        
        NSMutableArray *rowsToInsert = [NSMutableArray new];
        [rowsToInsert addObject:[NSIndexPath indexPathForItem:messages.count inSection:0]];
        
        [messages addObject:message];
        
        [chatViewController.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
        
    }];
}

- (void)setupMoviePlayer
{
    player = [[MPMoviePlayerController alloc] init];
    if (self.stream.state == CNStreamStateStreaming) {
        player.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/streams/%@/index.m3u8", BASE_URL, BASE_URL_SUB_PATH, self.stream.streamId]];
    } else {
        player.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/streams/%@/vod.m3u8", BASE_URL, BASE_URL_SUB_PATH, self.stream.streamId]];
    }
    
    player.view.frame = self.streamView.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight;
    [self.streamView addSubview:player.view];
    [player play];
}

- (void)setupRecorder
{
    recorderTask = dispatch_group_create();
    dispatch_group_enter(recorderTask);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.recorder = [[CNRecorder alloc] init];
        self.recorder.delegate = self;
        dispatch_group_leave(recorderTask);
    });
}

- (void)setupRecordButton
{
    recordButton = [[RecordButton alloc] initWithFrame:CGRectZero];
    [self.view addSubview:recordButton];
    [recordButton addTarget:self action:@selector(onRecordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLayoutConstraint *constraint = [recordButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0f];
    [self.view addConstraint:constraint];
    constraint = [recordButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.view addConstraint:constraint];
}

- (IBAction)onCloseBtnClick:(id)sender
{
    if (self.recorder.isRecording) {
        [self.recorder stopRecording];
    }
    if (player) [player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onChatBtnClick:(id)sender
{
    chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatViewController.delegate = self;
    chatViewController.isBroadcaster = self.isBroadcaster;
    if (self.viewerName) chatViewController.viewerName = self.viewerName;
    UINavigationController *chatViewNavigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    [self.navigationController presentViewController:chatViewNavigationController animated:YES completion:^{
    }];
}

- (void)onRecordBtnClick:(id)sender
{
    if (!self.recorder.isRecording) {
        [self.recorder startRecording:self.stream];
    } else {
        [self.recorder stopRecording];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    AVCaptureVideoPreviewLayer *preview = self.recorder.previewLayer;
    [UIView animateWithDuration:duration animations:^{
        preview.frame = self.streamView.bounds;
    } completion:NULL];
    [[preview connection] setVideoOrientation:[self avOrientationForInterfaceOrientation:toInterfaceOrientation]];
    
    [self checkViewOrientation:YES];
}

- (void)checkViewOrientation:(BOOL)animated
{
//    CGFloat duration = 0.2f;
//    if (!animated) {
//        duration = 0.0f;
//    }
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    // Hide controls in Portrait
//    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortrait) {
//        self.recordButton.enabled = NO;
//        [UIView animateWithDuration:0.2 animations:^{
//            self.shareButton.alpha = 0.0f;
//            self.recordButton.alpha = 0.0f;
//            self.rotationLabel.alpha = 1.0f;
//            self.rotationImageView.alpha = 1.0f;
//        } completion:NULL];
//    } else {
//        self.recordButton.enabled = YES;
//        [UIView animateWithDuration:0.2 animations:^{
//            self.shareButton.alpha = 1.0f;
//            self.recordButton.alpha = 1.0f;
//            self.rotationLabel.alpha = 0.0f;
//            self.rotationImageView.alpha = 0.0f;
//        } completion:NULL];
//    }
}

- (AVCaptureVideoOrientation)avOrientationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
}

- (void)startPreview
{
    AVCaptureVideoPreviewLayer *preview = self.recorder.previewLayer;
    [preview removeFromSuperlayer];
    preview.frame = self.streamView.bounds;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [[preview connection] setVideoOrientation:[self avOrientationForInterfaceOrientation:orientation]];
    
    [self.streamView.layer addSublayer:preview];
}

- (void)recorder:(CNRecorder *)recorder streamReadyAtURL:(NSURL *)url
{
    NSLog(@"recorder streamReadyAtURL");
}

- (void)recorderDidStartRecording:(CNRecorder *)recorder error:(NSError *)error
{
    NSLog(@"recorderDidStartRecording");
    recordButton.enabled = YES;
    if (error) {
        recordButton.isRecording = NO;
    } else {
        recordButton.isRecording = YES;
    }
}

- (void)recorderDidFinishRecording:(CNRecorder *)recorder error:(NSError *)error
{
    NSLog(@"recorderDidFinishRecording");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)currentSize
{
    return [self sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

#pragma mark -
#pragma mark StreamChatDelegate

- (void)publishChatMessage:(NSString *)name text:(NSString *)text
{
    Firebase *childRef = [f childByAppendingPath:[self uuid]];
    [childRef setValue:@{ @"name": name, @"text": text }];
}

- (void)saveViewerName:(NSString *)name
{
    self.viewerName = name;
}

- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge NSString *)uuidStringRef;
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 25;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatMessageViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    Message *message = [messages objectAtIndex:indexPath.row];
    cell.textLabel.text = message.name;
    cell.detailTextLabel.text = message.text;
    
    return cell;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
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
