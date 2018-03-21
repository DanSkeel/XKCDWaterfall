//
//  FeedsTableViewController.m
//  XKCDFeed
//
//  Created by Danila Shikulin on 21/03/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <KZAsserts/KZAsserts.h>

#import "FeedsTableViewController.h"
#import "FeedViewController.h"

#import "FeedLoaderXKCD.h"
#import "FeedModel.h"


@implementation FeedsTableViewController

- (NSArray<FeedSourceModel *> *)feedSourceModels {
    if (!_feedSourceModels) {
        _feedSourceModels = [FeedSourceModel modelsForAllFeedSources];
    }
    return _feedSourceModels;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feedSourceModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedSourceCellID" forIndexPath:indexPath];
    cell.textLabel.text = self.feedSourceModels[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedViewControllerID"];
    vc.model = self.feedSourceModels[indexPath.row].feedModel;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
