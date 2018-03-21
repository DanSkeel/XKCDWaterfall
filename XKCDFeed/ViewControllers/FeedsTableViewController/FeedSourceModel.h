//
//  FeedSourceModel.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 27/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FeedModel;

@interface FeedSourceModel : NSObject
@property (nonatomic) NSString *title;

+ (NSArray *)modelsForAllFeedSources;
- (FeedModel *)feedModel;
@end
