//
//  FeedSourceModel.m
//  XKCDFeed
//
//  Created by Danila Shikulin on 27/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <KZAsserts/KZAsserts.h>

#import "FeedSourceModel.h"

#import "FeedModel.h"
#import "FeedLoaderXKCD.h"


typedef NS_ENUM(NSInteger, FeedSource) {
    FeedSourceXKCD,
    FeedSourceXKCDCachedImageSizes,
    FeedSourceCount,
};

@interface FeedSourceModel ()
@property (nonatomic) FeedSource feedSource;

@end

@implementation FeedSourceModel

+ (NSArray *)modelsForAllFeedSources {
    return @[
             [self modelForFeedSource:FeedSourceXKCDCachedImageSizes],
             [self modelForFeedSource:FeedSourceXKCD],
             ];
}

+ (instancetype)modelForFeedSource:(FeedSource)feedsource {
    FeedSourceModel *model = [self new];
    model.feedSource = feedsource;
    return model;
}

- (NSString *)title {
    return [self titleForSource:self.feedSource];
}

- (FeedModel *)feedModel {
    return [self modelForSource:self.feedSource];
}

- (NSString *)titleForSource:(FeedSource)source {
    switch (source) {
        case FeedSourceXKCD:
            return @"XKCD (Jerky)";
        case FeedSourceXKCDCachedImageSizes:
            return @"XKCD (Nice) with cached image sizes";
        case FeedSourceCount: break;
    }
    
    //Unimpelmented!
    AssertTrueOr(NO,);
    return nil;
}

- (NSObject<FeedLoaderP> *)loaderForSource:(FeedSource)source {
    switch (source) {
        case FeedSourceXKCD:
            return [FeedLoaderXKCD new];
        case FeedSourceXKCDCachedImageSizes:{
            FeedLoaderXKCD *loader = [FeedLoaderXKCD new];
            loader.allowCachedImageSizes = YES;
            return loader;
        }
        case FeedSourceCount: break;
    }
    
    //Unimpelmented!
    AssertTrueOr(NO,);
    return nil;
}

- (FeedModel *)modelForSource:(FeedSource)source {
    FeedModel *model = [FeedModel new];
    model.feedLoader = [self loaderForSource:source];
    return model;
}

@end
