//
//  DSPTopStoriesTVC.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/5/14.
//
//

#import <UIKit/UIKit.h>


@protocol DSPTopStoriesDelegate <NSObject>

- (void)didRevokeVoteInCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)didUpvoteInCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDownvoteInCellAtIndexPath:(NSIndexPath *)indexPath;


@end

@interface DSPTopStoriesTVC : UITableViewController <DSPTopStoriesDelegate>

- (void)didRevokeVoteInCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)didUpvoteInCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDownvoteInCellAtIndexPath:(NSIndexPath *)indexPath;

@end
