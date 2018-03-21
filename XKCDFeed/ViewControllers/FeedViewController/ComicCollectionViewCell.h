//
//  ComicCollectionViewCell.h
//  XKCDFeed
//
//  Created by Danila Shikulin on 19/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ComicCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *debugLabel;

@end
