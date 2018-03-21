//
//  FeedLoaderXKCD.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 20/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FeedLoaderP.h"


@interface FeedLoaderXKCD : NSObject <FeedLoaderP>

/**
 * XKCD API doesn't provide image sizes. So you have to load the picture to properly layout views.
 * I tried to layout them as squares and after loading update the size, but in this case views jump on every update to fit the layout.
 * When `allowCachedImageSizes` is set to YES, loader uses cached sizes.
 */
@property (nonatomic) BOOL allowCachedImageSizes;

@end
