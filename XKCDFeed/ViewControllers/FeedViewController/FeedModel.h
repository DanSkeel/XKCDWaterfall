//
//  FeedModel.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 19/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TRMultipleItemsViewModifierProtocol.h>

#import "FeedItemP.h"
#import "FeedLoaderP.h"


@interface FeedModel : NSObject
@property (weak, nonatomic) NSObject<TRMultipleItemsViewModifierProtocol> *viewModifier;
@property (strong, nonatomic) NSObject<FeedLoaderP> *feedLoader;

- (UIImage *)placeholderImage;
- (NSInteger)itemsCount;
- (NSObject<FeedItemP> *)itemAtIndex:(NSInteger)index;

- (BOOL)loadMoreItems;
@end
