//
//  Model.m
//  XKCDFeed
//
//  Created by Danila Shikulin on 19/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <SDWebImageManager.h>

#import "FeedModel.h"


@interface FeedModel ()
@property (strong, nonatomic) NSMutableArray<NSObject<FeedItemP> *> *feedItems;

@end

@implementation FeedModel

- (NSMutableArray<NSObject<FeedItemP> *> *)feedItems {
    return _feedItems ?: (_feedItems = [NSMutableArray new]);
}

- (NSInteger)itemsCount {
    return self.feedItems.count;
}

- (NSObject<FeedItemP> *)itemAtIndex:(NSInteger)index {
    return self.feedItems[index];
}

- (UIImage *)placeholderImage {
    return nil;
}

- (BOOL)loadMoreItems {
    __weak __typeof__(self) weakSelf = self;
    return [self.feedLoader loadWithCompletion:^(NSArray<NSObject<FeedItemP> *> *feedItems) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"Loaded: %@", feedItems);
        
        [strongSelf.viewModifier modifyAnimatedWithUpdateBlock:nil
                                                   deleteBlock:nil
                                                   insertBlock:^NSArray<NSIndexPath *> * _Nonnull{
                                                       NSMutableArray *indexPaths = [NSMutableArray new];
                                                       [feedItems enumerateObjectsUsingBlock:^(NSObject<FeedItemP> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                           [indexPaths addObject:[NSIndexPath indexPathForRow:strongSelf.feedItems.count inSection:0]];
                                                           [strongSelf.feedItems addObject:obj];
                                                       }];
                                                       return indexPaths;
                                                   } completionBlock:nil];
    }];
}

@end

