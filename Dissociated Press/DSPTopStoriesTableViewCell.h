//
//  DSPTopStoriesTableViewCell.h
//  DissociatedPress-iOS
//
//  Created by Joe Wilkerson on 12/17/14.
//
//

#import <UIKit/UIKit.h>
#import "DSPTableViewCell.h"
#import "DSPLabel.h"
#import <RedditKit/RedditKit.h>
#import "DSPTopStoriesTVC.h"

@interface DSPTopStoriesTableViewCell : DSPTableViewCell

@property (strong, nonatomic) DSPLabel *titleLabel;
@property (strong, nonatomic) UIImageView *thumbnail;
@property (nonatomic, assign) BOOL hasThumbnail;
@property (strong, nonatomic) UIButton *upvoteButton;
@property (strong, nonatomic) UIButton *downvoteButton;
@property (strong, nonatomic) UIButton *touchCellButton;
@property (strong, nonatomic) DSPLabel *voteLabel;
@property (strong, nonatomic) DSPLabel *authorLabel;
@property (strong, nonatomic) RKLink *link;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<DSPTopStoriesDelegate>delegate;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;
- (void)configureCell;

@end
