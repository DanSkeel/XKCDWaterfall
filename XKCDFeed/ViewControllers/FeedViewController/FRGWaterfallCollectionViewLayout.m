//
//  FRGWaterfallCollectionViewLayout.m
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import "FRGWaterfallCollectionViewLayout.h"


NSString* const FRGWaterfallLayoutCellKind = @"WaterfallCell";

@interface FRGWaterfallCollectionViewLayout()

@property (nonatomic, readwrite) CGFloat itemWidth;
@property (nonatomic) NSDictionary *layoutInfo;
@property (nonatomic) NSArray *sectionsHeights;
@property (nonatomic) NSArray *itemsInSectionsHeights;

@end

@implementation FRGWaterfallCollectionViewLayout

#pragma mark - Lifecycle

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setColumnsCount:(NSInteger)columnsCount {
    if (_columnsCount == columnsCount) return;
    _columnsCount = columnsCount;
    [self invalidateLayout];
}

- (void)setItemInnerMargin:(CGFloat)itemInnerMargin {
    if (_itemInnerMargin == itemInnerMargin) return;
    _itemInnerMargin = itemInnerMargin;
    [self invalidateLayout];
}

- (void)setup {
    self.columnsCount = 3;
    self.topInset = 10.0f;
    self.bottomInset = 10.0f;
}

- (void)prepareLayout {
    [self calculateItemWidth];
    [self calculateItemsHeights];
    [self calculateSectionsHeights];
    [self calculateItemsAttributes];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[FRGWaterfallLayoutCellKind][indexPath];
}

- (CGSize)collectionViewContentSize {
    CGFloat height = self.topInset;
    for (NSNumber *h in self.sectionsHeights) {
        height += [h integerValue];
    }
    height += self.bottomInset;
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return NO;
}

#pragma mark - Prepare layout calculation

- (void)calculateItemWidth {
    CGFloat gapsSum = self.itemInnerMargin * (self.columnsCount + 1);
    self.itemWidth = (self.collectionView.bounds.size.width - gapsSum) / self.columnsCount;
}

- (void)calculateItemsHeights {
    NSMutableArray *itemsInSectionsHeights = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    NSIndexPath *itemIndex;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        NSMutableArray *itemsHeights = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfItemsInSection:section]];
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            itemIndex = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat itemHeight = [self.delegate collectionView:self.collectionView
                                                        layout:self
                                      heightForItemAtIndexPath:itemIndex];
            [itemsHeights addObject:[NSNumber numberWithFloat:itemHeight]];
        }
        [itemsInSectionsHeights addObject:itemsHeights];
    }
    
    self.itemsInSectionsHeights = itemsInSectionsHeights;
}

- (void)calculateSectionsHeights {
    NSMutableArray *newSectionsHeights = [NSMutableArray array];
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        [newSectionsHeights addObject:[self calculateHeightForSection:section]];
    }
    self.sectionsHeights = [NSArray arrayWithArray:newSectionsHeights];
}

- (NSNumber *)calculateHeightForSection: (NSInteger)section {
    NSInteger sectionColumns[self.columnsCount];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        sectionColumns[column] = self.itemInnerMargin;
    }
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
    for (NSInteger item = 0; item < itemCount; item++) {
        indexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
        NSInteger currentColumn = 0;
        for (NSInteger column = 0; column < self.columnsCount; column++) {
            if(sectionColumns[currentColumn] > sectionColumns[column]) {
                currentColumn = column;
            }
        }
        
        sectionColumns[currentColumn] += [[[self.itemsInSectionsHeights objectAtIndex:section]
                                           objectAtIndex:indexPath.item] floatValue];
        sectionColumns[currentColumn] += self.itemInnerMargin;
    }
    
    NSInteger biggestColumn = 0;
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        if(sectionColumns[biggestColumn] < sectionColumns[column]) {
            biggestColumn = column;
        }
    }
    
    return [NSNumber numberWithFloat: sectionColumns[biggestColumn]];
}

- (void)calculateItemsAttributes {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForWaterfallCellIndexPath:indexPath];
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[FRGWaterfallLayoutCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

#pragma mark - Items frames

- (CGRect)frameForWaterfallCellIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.itemWidth;
    CGFloat height = [[[self.itemsInSectionsHeights objectAtIndex:indexPath.section]
                       objectAtIndex:indexPath.item] floatValue];
    
    CGFloat topInset = self.topInset;
    for (NSInteger section = 0; section < indexPath.section; section++) {
        topInset += [[self.sectionsHeights objectAtIndex:section] integerValue];
    }

    NSInteger columnsHeights[self.columnsCount];
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        columnsHeights[column] = self.itemInnerMargin;
    }
    
    for (NSInteger item = 0; item < indexPath.item; item++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
        NSInteger currentColumn = 0;
        for(NSInteger column = 0; column < self.columnsCount; column++) {
            if(columnsHeights[currentColumn] > columnsHeights[column]) {
                currentColumn = column;
            }
        }
                
        columnsHeights[currentColumn] += [[[self.itemsInSectionsHeights objectAtIndex:ip.section]
                                           objectAtIndex:ip.item] floatValue];
        columnsHeights[currentColumn] += self.itemInnerMargin;
    }
    
    NSInteger columnForCurrentItem = 0;
    for (NSInteger column = 0; column < self.columnsCount; column++) {
        if(columnsHeights[columnForCurrentItem] > columnsHeights[column]) {
            columnForCurrentItem = column;
        }
    }
    
    CGFloat originX = self.itemInnerMargin +
        columnForCurrentItem * self.itemWidth +
        columnForCurrentItem * self.itemInnerMargin;
    CGFloat originY =  columnsHeights[columnForCurrentItem] + topInset;
    
    return CGRectMake(originX, originY, width, height);
}

@end
