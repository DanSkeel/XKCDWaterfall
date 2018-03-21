//
//  FeedsTableViewController.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 21/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FeedSourceModel.h"


@interface FeedsTableViewController : UITableViewController
@property (strong, nonatomic) NSArray<FeedSourceModel *> *feedSourceModels;

@end
