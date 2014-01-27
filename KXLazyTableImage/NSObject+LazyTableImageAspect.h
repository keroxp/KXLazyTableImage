//
//  NSObject+LazyTableImageAspect.h
//  KXLazyTableImage
//
//  Created by Yusuke Sakurai on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LazyImageAspect)

@property (nonatomic) NSMutableDictionary *downloadsInProgress;
@property (nonatomic) NSOperationQueue *operationQueue;

// indicate using this aspect, swizzling 2 scroll view delegate methods
- (void)useLazyTableImageAspect;
// start downloading of image in asynchronously, with completion handler
- (void)startImageDownloadForURL:(NSURL*)URL tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath completaion:(void (^)(UIImage *image, NSError *error))completion;
;

@end