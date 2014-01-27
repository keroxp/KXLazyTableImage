//
//  AppRecord.m
//  KXLazyTableImage
//
//  Created by 桜井雄介 on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "AppRecord.h"

@implementation AppRecord

+ (AFHTTPRequestOperation *)downloadAppsOperationWithCompletion:(void (^)(NSArray *, NSError *))completion
{
    NSURL *URL = [NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *e = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&e];
        NSMutableArray *ma = [NSMutableArray new];
        for (NSDictionary *d in json[@"feed"][@"entry"]) {
            AppRecord *app = [[AppRecord alloc] initWithDictionary:d];
            [ma addObject:app];
        }
        if (completion) {
            completion(ma,e);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"エラー", ) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [av show];
        }];
    }];
    return operation;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _appName  = dictionary[@"im:name"][@"label"];
        _artist = dictionary[@"im:artist"][@"label"];
        _appIconURL = [NSURL URLWithString:dictionary[@"im:image"][2][@"label"]];
        _appURL = [NSURL URLWithString:dictionary[@"link"][@"attributes"][@"href"]];
    }
    return self ? self : nil;
}

@end
