//
//  FeedItemXKCD.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 20/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FeedItemP.h"


@interface FeedItemXKCD : NSObject <FeedItemP>
@property (nonatomic) NSInteger ID;

+ (instancetype)itemWithJSON:(NSDictionary *)JSON;
@end
