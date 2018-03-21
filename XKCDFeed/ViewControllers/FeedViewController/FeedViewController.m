//
//  ViewController.m
//  XKCDFeed
//
//  Created by Danila Shikulin on 19/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <KZAsserts/KZAsserts.h>
#import <TRCollectionViewModifier.h>
#import <UIImageView+WebCache.h>

#import "FeedViewController.h"

#import "ComicCollectionViewCell.h"
#import "DetailViewController.h"
#import "FRGWaterfallCollectionViewLayout.h"


static NSTimeInterval const kAnimationTimeDefault = 0.2;

@interface FeedViewController () <
UICollectionViewDelegate,
UICollectionViewDataSource,
FRGWaterfallCollectionViewDelegate,
TRMultipleItemsViewModifierDelegate
>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIStepper *columnCountStepper;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadSpinner;
@property (strong, nonatomic) TRCollectionViewModifier *collectionViewModifier;

@property (nonatomic) NSInteger columnsCount;

- (FRGWaterfallCollectionViewLayout *)collectionViewLayout;
@end

@implementation FeedViewController

- (void)setColumnsCount:(NSInteger)columnsCount {
    if (self.columnsCount == columnsCount) return;
    
    self.columnCountStepper.value = columnsCount;
    self.collectionViewLayout.columnsCount = columnsCount;
    
    [self tryLoadMoreItemsIfNeeded];
}

- (NSInteger)columnsCount {
    return self.collectionViewLayout.columnsCount;
}

- (FRGWaterfallCollectionViewLayout *)collectionViewLayout {
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    if (layout) AssertTrueOrReturnNil([layout isKindOfClass:[FRGWaterfallCollectionViewLayout class]]);
    return (FRGWaterfallCollectionViewLayout *)layout;
}

- (UICollectionViewLayout *)newLayout {
    FRGWaterfallCollectionViewLayout *layout = [FRGWaterfallCollectionViewLayout new];
    layout.delegate = self;
    layout.itemInnerMargin = 10;
    layout.topInset = 10.0f;
    layout.bottomInset = 30.0f;
    return layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // model should be set at this point
    AssertTrueOrReturn(self.model);
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressOnCollectionView:)];
    longPress.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:longPress];
    
    [self.collectionView setCollectionViewLayout:[self newLayout]];
    self.columnsCount = 2;
    
    TRCollectionViewModifier *viewModifier = [[TRCollectionViewModifier alloc] initWithCollectionView:self.collectionView];
    viewModifier.delegate = self;
    self.collectionViewModifier = viewModifier;
    self.model.viewModifier = viewModifier;
    
    [self.model loadMoreItems];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ComicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comicCellID" forIndexPath:indexPath];
    NSObject<FeedItemP> *item = [self.model itemAtIndex:indexPath.row];

    cell.imageView.backgroundColor = [UIColor whiteColor];
    cell.imageView.contentMode = UIViewContentModeCenter;
    
    __weak __typeof__(self) weakSelf = self;
    [cell.imageView sd_setImageWithURL:item.imageURL placeholderImage:self.model.placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (!image && error) {
            NSLog(@"Failed to load image for item %@: %@", item, error);
            return;
        }
        
        if (image) {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        if (image && CGSizeEqualToSize(item.imageSize, CGSizeZero)) {
            item.imageSize = image.size;
            
            [strongSelf.collectionViewModifier modifyAnimatedWithUpdateBlock:^NSArray<NSIndexPath *> * _Nullable {
                return @[indexPath];
            } deleteBlock:nil insertBlock:nil completionBlock:nil];
        }
    }];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<FeedItemP> *item = [self.model itemAtIndex:indexPath.row];
    CGSize imageSize = item.imageSize;
    CGFloat width = collectionViewLayout.itemWidth;
    CGFloat height = width;
    if (!CGSizeEqualToSize(item.imageSize, CGSizeZero)) {
        height = width * imageSize.height/imageSize.width;
    }
    return height;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewControllerID"];
    vc.feedItem = [self.model itemAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tryLoadMoreItemsIfNeeded];
}

#pragma mark - TRMultipleItemsViewModifierDelegate

- (void)modifier:(nonnull NSObject<TRMultipleItemsViewModifierProtocol> *)modifier willUpdateView:(nullable UIView *)view {
    [self hideLoadSpinner];
}

- (void)modifier:(nonnull NSObject<TRMultipleItemsViewModifierProtocol> *)modifier didUpdatedView:(nullable UIView *)view {
    [self tryLoadMoreItemsIfNeeded];
}

#pragma mark - UI Interaction

- (IBAction)stepperDidChangeColumnCount:(UIStepper *)stepper {
    self.columnsCount = stepper.value;
}

-(void)didLongPressOnCollectionView:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    NSObject<FeedItemP> *item = [self.model itemAtIndex:indexPath.row];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:item.title
                                                                   message:item.caption
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"LoL" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - Other

- (void)showLoadSpinner {
    [UIView animateWithDuration:kAnimationTimeDefault animations:^{
        self.loadSpinner.alpha = 1.0;
    }];
}

- (void)hideLoadSpinner {
    [UIView animateWithDuration:kAnimationTimeDefault animations:^{
        self.loadSpinner.alpha = 0.0;
    }];
}

- (void)tryLoadMoreItemsIfNeeded {
    if ([self isNeedMoreItems]) {
        if ([self.model loadMoreItems]) {
            [self showLoadSpinner];
        }
    }
}

- (BOOL)isNeedMoreItems {
    UIScrollView *scrollView = self.collectionView;
    
    if (scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.bounds.size.height + 200) {
        // we are close to the bottom of the table
        // so soon we want to see more items
        return YES;
    }
    return NO;
}

@end
