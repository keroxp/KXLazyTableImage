//
//  KXDetailViewController.h
//  KXLazyTableImage
//
//  Created by 桜井雄介 on 2014/01/22.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KXDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
