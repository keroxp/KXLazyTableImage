//
//  NSObject+LazyTableImageAspect.h
//  KXLazyTableImage
//
//  Created by 桜井雄介 on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LazyTableImageAspect <UIScrollViewDelegate>

@required
- (NSURL*)lazyTableImageURLForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
@optional
- (void)lazyTableImageDidFinishDownload:(UIImage*)image forURL:(NSURL*)URL tableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
- (BOOL)lazyTableImageShouldStartDownloadForURL:(NSURL*)URL tableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;

@end

@interface NSObject (LazyImageAspect)

@property (nonatomic) NSMutableDictionary *downloadsInProgress;
@property (nonatomic) NSOperationQueue *operationQueue;

- (void)useLazyTableImageAspect;
- (void)startImageDownloadForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath;
- (void)loadImagesOnScreenRows:(UITableView*)tableview;

@end