//
//  AppRecord.h
//  KXLazyTableImage
//
//  Created by 桜井雄介 on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppRecord : NSObject

@property NSString *appName;
@property UIImage *appIcon;
@property NSString *artist;
@property NSURL *appIconURL;
@property NSURL *appURL;

+ (AFHTTPRequestOperation*)downloadAppsOperationWithCompletion:(void(^)(NSArray *apps, NSError *error))completion;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
