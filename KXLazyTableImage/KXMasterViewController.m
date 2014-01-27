//
//  KXMasterViewController.m
//  KXLazyTableImage
//
//  Created by 桜井雄介 on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXMasterViewController.h"
#import "KXDetailViewController.h"
#import "NSObject+LazyTableImageAspect.h"
#import "AppRecord.h"

@interface KXMasterViewController ()
{
    NSOperationQueue *_operationQueue;
}
@property (nonatomic) NSArray *apps;

@end

@implementation KXMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    _operationQueue = [[NSOperationQueue alloc] init];
    // LazyTableImageAspectを使用
    [self useLazyTableImageAspect];
    // 読み込み
    __block __weak typeof (self) __self = self;
    AFHTTPRequestOperation *operation = [AppRecord downloadAppsOperationWithCompletion:^(NSArray *apps, NSError *error) {
        if (!error) {
            __self.apps = apps;
            [__self.tableView reloadData];
        }
    }];
    [self.operationQueue addOperation:operation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearImages:(id)sender {
    for (AppRecord *app in self.apps) {
        app.appIcon = nil;
    }
    [self.tableView reloadData];
}

#pragma mark - Table View

- (AppRecord*)modelForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    return (_apps.count > 0) ? _apps[indexPath.row] : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // 対応するappレコードを取得
    AppRecord *app = [self modelForTableView:tableView atIndexPath:indexPath];
    // データをassign
    cell.textLabel.text = [app appName];
    cell.detailTextLabel.text = [app artist];
    if (app.appIcon) {
        // iconがすでにダウンロード済みならassign
        cell.imageView.image = app.appIcon;
    }else{
        // まだならplaceholderを代入してlazy download を開始
        [self startImageDownloadForURL:app.appIconURL tableView:tableView atIndexPath:indexPath completaion:^(UIImage *image, NSError *error) {
            if (!error) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                AppRecord *app = [self modelForTableView:tableView atIndexPath:indexPath];
                app.appIcon = image;
                [UIView transitionWithView:cell.imageView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    cell.imageView.image = image;
                } completion:NULL];
            }else{
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"エラー", )
                                                             message:error.localizedDescription
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [av show];
                }];
            }
        }];
        cell.imageView.image = [UIImage imageNamed:@"ph"];
    }
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _apps[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrolling!");
    self.title = @"scrolling!";
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"did end decelerating");
    self.title = @"end decelearating";
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"did end dragging!");
    self.title = @"end dragging!";
}

@end
