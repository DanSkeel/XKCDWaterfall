//
//  FeedLoaderXKCD.m
//  XKCDFeed
//
//  Created by Danila Shikulin on 20/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <KZAsserts/KZAsserts.h>

#import "FeedLoaderXKCD.h"

#import "FeedItemXKCD.h"


NSInteger const kFirstComicIndex = 1;
NSInteger const kNewestComicIndex = -1;

@interface FeedLoaderXKCD ()
@property (nonatomic) NSNumber *nextComicNumber;
@property (nonatomic) BOOL isRetrieving;
@property (strong, nonatomic) NSDictionary *cachedImageSizes;

@end

@implementation FeedLoaderXKCD

- (instancetype)init {
    if (self = [super init]) {
        _isRetrieving = NO;
    }
    return self;
}

- (NSDictionary *)cachedImageSizes {
    if (!_cachedImageSizes) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cachedXKCDImageSizes" ofType:nil];
        _cachedImageSizes = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    return _cachedImageSizes;
}

- (BOOL)loadWithCompletion:(void (^)(NSArray<NSObject<FeedItemP> *> *feedItems))completion {
    if (!self.hasNext) {
        return NO;
    }
    if (self.isRetrieving) {
        return NO;
    }
  
    [self loadNextComicsBatchWithCompletion:completion];
    
    return YES;
}

- (BOOL)loadNextComicsBatchWithCompletion:(void (^)(NSArray<NSObject<FeedItemP> *> *feedItems))completion {
    NSMutableArray *comicIDs = [NSMutableArray new];
    
    if (self.nextComicNumber) {
        NSInteger nextComicIdx = self.nextComicNumber.integerValue;
        for (NSInteger i = nextComicIdx; i >= MAX(nextComicIdx - 10, kFirstComicIndex); i--) {
            [comicIDs addObject:@(i)];
        }
        AssertTrueOrReturnNo(comicIDs.count);  // don't call this method if there are no IDs left
    } else {
        [comicIDs addObject:@(kNewestComicIndex)];
    }
    
    __weak __typeof__(self) weakSelf = self;
    return [self loadComicsWithIDs:comicIDs.copy completion:^(NSArray<FeedItemXKCD *> *feedItems) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (feedItems.count) {
            BOOL loadedOnlyFirstComic = (strongSelf.nextComicNumber == nil);
            strongSelf.nextComicNumber = @([feedItems.lastObject ID] - 1);
            
            if (loadedOnlyFirstComic) {
                NSMutableArray *loadedItems = feedItems.mutableCopy;
                [strongSelf loadNextComicsBatchWithCompletion:^(NSArray<NSObject<FeedItemP> *> *moreItems) {
                    [loadedItems addObjectsFromArray:moreItems];
                    if (completion) completion(loadedItems);
                }];
                return;
            }
        }
        if (completion) completion(feedItems);
    }];
}

- (BOOL)loadComicsWithIDs:(NSArray *)IDs completion:(void (^)(NSArray<FeedItemXKCD *> *feedItems))completion {
    AssertTrueOrReturnNo(IDs);
    
    __block NSMutableArray<FeedItemXKCD *> *loadedItems = [NSMutableArray new];
    dispatch_group_t group = dispatch_group_create();
    
    for (NSNumber *ID in IDs) {
        NSURL *URL = [self infoURLForComicIndex:ID];
        
        dispatch_group_enter(group);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        __weak __typeof__(self) weakSelf = self;
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __typeof__(self) strongSelf = weakSelf;
            
            // we don't want to miss call to `dispatch_group_leave`, so we avoid early returns;
            if (strongSelf) {
                if (!error && [(NSHTTPURLResponse *)response statusCode] == 200) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    FeedItemXKCD *item = [FeedItemXKCD itemWithJSON:json];
                    
                    if (strongSelf.allowCachedImageSizes) {
                        NSString *itemIDStr = [NSString stringWithFormat:@"%ld", (long)item.ID];
                        NSString *sizeStr = strongSelf.cachedImageSizes[itemIDStr];
                        if (sizeStr) {
                            NSArray *values = [sizeStr componentsSeparatedByString:@","];
                            item.imageSize = CGSizeMake([values.firstObject floatValue], [values.lastObject floatValue]);
                        }
                    }
                    
                    NSRange searchRange = NSMakeRange(0, [loadedItems count]);
                    NSUInteger findIndex = [loadedItems indexOfObject:item
                                                        inSortedRange:searchRange
                                                              options:NSBinarySearchingInsertionIndex
                                                      usingComparator:^NSComparisonResult(FeedItemXKCD *item_1, FeedItemXKCD *item_2) {
                                                          return item_2.ID - item_1.ID;
                                                      }];
                    [loadedItems insertObject:item atIndex:findIndex];                    
                } else {
                    NSLog(@"Failed to load comic at URL: %@", response.URL);
                }
            }
            
            dispatch_group_leave(group);
        }];
        if (!dataTask) {
            dispatch_group_leave(group);
            continue;
        }
        
        self.isRetrieving = YES;
        [dataTask resume];
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        strongSelf.isRetrieving = NO;
        if (completion) completion(loadedItems.count ? loadedItems.copy : nil);
    });
    
    return YES;
}

- (NSURL *)infoURLForComicIndex:(NSNumber *)comicIndex {
    if (!comicIndex) return nil;
    
    NSURL *URL = [NSURL URLWithString:@"https://xkcd.com"];
    if (comicIndex.integerValue != kNewestComicIndex) {
        URL = [URL URLByAppendingPathComponent:comicIndex.stringValue];
    }
    URL = [URL URLByAppendingPathComponent:@"info.0.json"];
    return URL;
}

- (BOOL)hasNext {
    if (!self.nextComicNumber) return YES;
    
    return self.nextComicNumber.integerValue >= kFirstComicIndex;
}

@end
