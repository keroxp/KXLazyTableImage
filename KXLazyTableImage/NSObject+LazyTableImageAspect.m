//
//  NSObject+LazyTableImageAspect.m
//  KXLazyTableImage
//
//  Created by Yusuke Sakurai on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "NSObject+LazyTableImageAspect.h"
#import <AFNetworking.h>

#import <objc/runtime.h>
#import <objc/objc.h>

static const char *kOperationQueueKey = "me.keroxp.app:operationQueue";
static const char *kDownloadsInProgressKey = "me.keroxp.app:downloadsInProgress";

@implementation NSObject (LazyImageAspect)

- (void)swizzleMethod:(SEL)method1 withMethod:(SEL)method2
{
    Method from_m = class_getInstanceMethod([self class], method1);
    Method to_m = class_getInstanceMethod([self class], method2);
    if (from_m) {
        // exchange two methods if the reciever has an impl of method1
        method_exchangeImplementations(from_m, to_m);
    }else{
        // unless no impl of method1, adding it and swizzling again
        IMP imp = method_getImplementation(to_m);
        void (^block)() = ^{};
        imp = imp_implementationWithBlock(block);
        const char *type = method_getTypeEncoding(to_m);
        class_addMethod([self class], method1, imp, type);
        [self swizzleMethod:method1 withMethod:method2];
    }
}

#pragma mark -

- (void)useLazyTableImageAspect
{
    // exchange delegate methods
    [self swizzleMethod:@selector(scrollViewDidEndDecelerating:) withMethod:@selector(_scrollViewDidEndDecelerating:)];
    [self swizzleMethod:@selector(scrollViewDidEndDragging:willDecelerate:) withMethod:@selector(_scrollViewDidEndDragging:willDecelerate:)];
}

- (void)startImageDownloadForURL:(NSURL *)URL tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath completaion:(void (^)(UIImage *, NSError *))completion
{
    // if donwload for the index path is in progress, do nothing
    AFHTTPRequestOperation *operation = [self.downloadsInProgress objectForKey:indexPath];
    if (operation) {
        return;
    }
    // making download operation
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *image = [[UIImage alloc] initWithData:responseObject];
        if (completion){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion(image,nil);
            }];
        }else{
            // if no completion handler, assigin image to image view automatically
            if ([[tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [UIView transitionWithView:cell.imageView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        [cell.imageView setImage:image];
                    } completion:NULL];
                }];
            }
        }
        [[self downloadsInProgress] removeObjectForKey:indexPath];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil,error);
        }
        [[self downloadsInProgress] removeObjectForKey:indexPath];
    }];
    // register operation to list
    [[self downloadsInProgress] setObject:operation forKey:indexPath];
    // unless table view is not scrolling, launch operation
    if (!tableView.dragging && !tableView.decelerating) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)loadImagesOnScreenRows:(UITableView*)tableview
{
    // spawn operations ready for start
    NSArray *is = [tableview indexPathsForVisibleRows];
    NSArray *operations = [[[self downloadsInProgress] objectsForKeys:is notFoundMarker:[NSNull null]] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSOperation* evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[NSOperation class]]
            && [evaluatedObject isReady]) {
            return YES;
        }
        return NO;
    }]];
    [[self operationQueue] addOperations:operations waitUntilFinished:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)_scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _scrollViewDidEndDecelerating:scrollView];
    if ([scrollView isKindOfClass:[UITableView class]]) {
        [self loadImagesOnScreenRows:(UITableView*)scrollView];
    }
}

- (void)_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self _scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (!decelerate && [scrollView isKindOfClass:[UITableView class]]) {
        [self loadImagesOnScreenRows:(UITableView*)scrollView];
    }
}

#pragma mark -

- (NSOperationQueue *)operationQueue
{
    NSOperationQueue *q = objc_getAssociatedObject(self, kOperationQueueKey);
    if (!q) {
        q = [[NSOperationQueue alloc] init];
        [self setOperationQueue:q];
    }
    return q;
}

- (void)setOperationQueue:(NSOperationQueue *)operationQueue
{
    objc_setAssociatedObject(self, kOperationQueueKey, operationQueue, OBJC_ASSOCIATION_RETAIN);
}

- (void)setDownloadsInProgress:(NSMutableDictionary *)downloadsInProgress
{
    objc_setAssociatedObject(self, kDownloadsInProgressKey, downloadsInProgress, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary *)downloadsInProgress
{
    NSMutableDictionary *obj = objc_getAssociatedObject(self, kDownloadsInProgressKey);
    if (!obj) {
        obj = [NSMutableDictionary new];
        [self setDownloadsInProgress:obj];
    }
    return obj;
}

@end