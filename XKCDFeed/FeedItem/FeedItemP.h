//
//  FeedItemP.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 20/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>


@protocol FeedItemP <NSObject>
@property (nonatomic) CGSize imageSize;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *caption;

@end
