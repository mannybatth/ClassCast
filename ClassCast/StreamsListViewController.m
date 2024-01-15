//
//  StreamsListViewController.m
//  ClassCast
//
//  Created by Manny on 4/22/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "StreamsListViewController.h"
#import "StreamStore.h"
#import "StreamViewController.h"

@interface StreamsListViewController ()
{
    NSMutableArray *streamsList;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation StreamsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Streams";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [StreamStore getStreams:^(NSArray *streams, NSString *error) {
       
        streamsList = [NSMutableArray arrayWithArray:streams];
        [self.tableView reloadData];
        
    }];
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [streamsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatMessageViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    CNStream *stream = [streamsList objectAtIndex:indexPath.row];
    cell.textLabel.text = stream.streamId;
    
    if (stream.state == CNStreamStateStreaming) {
        cell.detailTextLabel.text = @"LIVE";
    } else if (stream.state == CNStreamStateFinished) {
        cell.detailTextLabel.text = @"VOD";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CNStream *stream = [streamsList objectAtIndex:indexPath.row];
    
    UINavigationController *streamViewNavigationController = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"StreamViewNavigationController"];
    StreamViewController *streamViewController = (StreamViewController*)streamViewNavigationController.topViewController;
    streamViewController.stream = stream;
    streamViewController.isBroadcaster = NO;
    [self.navigationController presentViewController:streamViewNavigationController animated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
