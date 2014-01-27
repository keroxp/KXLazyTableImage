//
//  NSObject+LazyTableImageAspect.h
//  KXLazyTableImage
//
//  Created by 桜井雄介 on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LazyImageAspect)

@property (nonatomic) NSMutableDictionary *downloadsInProgress;
@property (nonatomic) NSOperationQueue *operationQueue;

- (void)useLazyTableImageAspect;
- (void)startImageDownloadForURL:(NSURL*)URL tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath completaion:(void (^)(UIImage *image, NSError *error))completion;
;

@end