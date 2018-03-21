//
//  DetailViewController.m
//  XKCDFeed
//
//  Created by Danila Shikulin on 21/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <UIImageView+WebCache.h>

#import "DetailViewController.h"


@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSObject<FeedItemP> *item = self.feedItem;
    self.title = item.title;
    
    if (!item.imageURL) return;
    
    UIImageView *imageView = self.imageView;
    [imageView sd_setImageWithURL:item.imageURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        CGFloat aspectRatio = image.size.width/image.size.height;
        [NSLayoutConstraint constraintWithItem:imageView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:imageView
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:aspectRatio
                                      constant:0].active = YES;
    }];
}

- (IBAction)didTapOnImage:(id)sender {
    NSObject<FeedItemP> *item = self.feedItem;
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:item.title
                                                                   message:item.caption
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Kek" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

@end
