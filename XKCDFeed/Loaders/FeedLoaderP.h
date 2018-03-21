//
//  FeedLoaderP.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 20/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FeedItemP.h"


@protocol FeedLoaderP <NSObject>
@property (nonatomic, readonly) BOOL hasNext;

- (BOOL)loadWithCompletion:(void (^)(NSArray<NSObject<FeedItemP> *> *feedItems))completion;
@end
