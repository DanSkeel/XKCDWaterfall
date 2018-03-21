//
//  DetailViewController.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 21/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FeedItemP.h"


@interface DetailViewController : UIViewController
@property (strong, nonatomic) NSObject<FeedItemP> *feedItem;

@end
