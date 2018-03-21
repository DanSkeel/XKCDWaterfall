//
//  FeedItemXKCD.m
//  XKCDFeed
//
//  Created by Danila Shikulin on 20/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <KZAsserts/KZAsserts.h>

#import "FeedItemXKCD.h"


@implementation FeedItemXKCD
@synthesize imageSize = _imageSize;
@synthesize imageURL = _imageURL;
@synthesize title = _title;
@synthesize caption = _caption;

+ (instancetype)itemWithJSON:(NSDictionary *)JSON {
    if (!JSON) return nil;
    
    FeedItemXKCD *item = [FeedItemXKCD new];
    
    NSNumber *IDNum = JSON[@"num"];
    AssertTrueOrReturnNil([IDNum isKindOfClass:[NSNumber class]]);
    item.ID = [IDNum integerValue];
    
    NSString *imageURLStr = JSON[@"img"];
    if ([imageURLStr pathExtension].length) {
        item.imageURL = [NSURL URLWithString:imageURLStr];
    } else {
        // some comics are interactive and don't have image URL;
    }
    
    item.title = JSON[@"title"];
    item.caption = JSON[@"alt"];
    return item;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" https://xkcd.com/%ld/", (long)self.ID];
}

@end
