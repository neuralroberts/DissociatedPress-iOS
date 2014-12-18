//
//  DSPTopStoriesTableViewCell.m
//  DissociatedPress-iOS
//
//  Created by Joe Wilkerson on 12/17/14.
//
//

#import "DSPTopStoriesTableViewCell.h"

@interface DSPTopStoriesTableViewCell ()

@property (strong, nonatomic) NSMutableArray *hasThumbnailConstraints;
@property (strong, nonatomic) NSMutableArray *noThumbnailConstraints;

@property (strong, nonatomic) UIView *bodyContainerView;
@end

@implementation DSPTopStoriesTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    //container view to group text labels, so that they can be centered together
    self.bodyContainerView = [[UIView alloc] init];
    self.bodyContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bodyContainerView.backgroundColor = [UIColor clearColor];
    [self.cardView addSubview:self.bodyContainerView];
    
    self.titleLabel = [[DSPLabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bodyContainerView addSubview:self.titleLabel];
    
    self.thumbnail = [[UIImageView alloc] init];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFit;
    self.thumbnail.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.thumbnail];
    
    self.upvoteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.upvoteButton setImage:[UIImage imageNamed:@"upvote"] forState:UIControlStateNormal];
    self.upvoteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.upvoteButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.upvoteButton addTarget:self action:@selector(upvote) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.upvoteButton];
    
    self.downvoteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.downvoteButton setImage:[UIImage imageNamed:@"downvote"] forState:UIControlStateNormal];
    self.downvoteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.downvoteButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.downvoteButton addTarget:self action:@selector(downvote) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.downvoteButton];
    
    self.voteLabel = [[DSPLabel alloc] init];
    self.voteLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.voteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.voteLabel];
    
    self.authorLabel = [[DSPLabel alloc] init];
    self.authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.authorLabel.textColor = [UIColor grayColor];
    self.authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bodyContainerView addSubview:self.authorLabel];
    
    self.hasThumbnailConstraints = [NSMutableArray array];
    self.noThumbnailConstraints = [NSMutableArray array];
    [self applyConstraints];
    
    return self;
}

- (void)configureCell
{
    if (!self.link) {
        return;
    }
    
    self.titleLabel.text = self.link.title;
    self.voteLabel.text = [NSString stringWithFormat:@"%ld",(long)self.link.score];
    self.authorLabel.text = [NSString stringWithFormat:@"submitted by %@",self.link.author];
    
    [self updateVoteStatus];
    
    if ([[self.link.thumbnailURL absoluteString] isEqualToString:@"default"]) self.hasThumbnail = NO;
    else self.hasThumbnail = YES;
    
    if (self.hasThumbnail) {
        self.thumbnail.hidden = NO;
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:self.link.thumbnailURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [self imageWithImage:[[UIImage alloc] initWithData:imageData] scaledToWidth:72.0];
                weakSelf.thumbnail.image = image;
            });
        });
    } else {
        self.thumbnail.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)upvote
{
    if (self.link.voteStatus == RKVoteStatusUpvoted) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRevokeVoteInCellAtIndexPath:)]) {
            [self.delegate didRevokeVoteInCellAtIndexPath:self.indexPath];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpvoteInCellAtIndexPath:)]) {
            [self.delegate didUpvoteInCellAtIndexPath:self.indexPath];
        }
    }
    
}

- (void)downvote
{
    if (self.link.voteStatus == RKVoteStatusDownvoted) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRevokeVoteInCellAtIndexPath:)]) {
            [self.delegate didRevokeVoteInCellAtIndexPath:self.indexPath];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownvoteInCellAtIndexPath:)]) {
            [self.delegate didDownvoteInCellAtIndexPath:self.indexPath];
        }
    }
    
}


- (void)updateVoteStatus
{
    if (self.link.voteStatus == RKVoteStatusNone) {
        self.voteLabel.textColor = [self noVoteColor];
        [self.upvoteButton setTintColor:[self noVoteColor]];
        [self.downvoteButton setTintColor:[self noVoteColor]];
    } else if (self.link.voteStatus == RKVoteStatusUpvoted) {
        self.voteLabel.textColor = [self upvoteColor];
        [self.upvoteButton setTintColor:[self upvoteColor]];
        [self.downvoteButton setTintColor:[self noVoteColor]];
    } else if (self.link.voteStatus == RKVoteStatusDownvoted) {
        self.voteLabel.textColor = [self downvoteColor];
        [self.upvoteButton setTintColor:[self noVoteColor]];
        [self.downvoteButton setTintColor:[self downvoteColor]];
    }
}

- (UIColor *)upvoteColor
{
    return [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:97.0/255.0 alpha:1.0];
}

- (UIColor *)downvoteColor
{
    return [UIColor colorWithRed:148.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0];
}

- (UIColor *)noVoteColor
{
    return [UIColor colorWithRed:183.0/255.0 green:183.0/255.0 blue:183.0/255.0 alpha:1.0];
}

- (void)updateConstraints
{
    [super updateConstraints];

    if (self.hasThumbnail) {
        [self.cardView removeConstraints:self.noThumbnailConstraints];
        [self.cardView addConstraints:self.hasThumbnailConstraints];
    } else {
        [self.cardView removeConstraints:self.hasThumbnailConstraints];
        [self.cardView addConstraints:self.noThumbnailConstraints];
    }
}


- (void)applyConstraints
{
    [super applyConstraints];
    
    //vote label centery to cardview centery
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.voteLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    //votelabel centeryX to upvote centerx
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.voteLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.upvoteButton
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];
    
    //upvote bottom to votelabel top
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.upvoteButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.voteLabel
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0]];
    //downvote top to votelabel bottom
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.downvoteButton
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.voteLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0]];
    //upvote leading to cardview margin
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.upvoteButton
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:8]];
    //downvote leading to cardview margin
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.downvoteButton
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:8]];
    //upvote top>= cardview top
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.upvoteButton
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:8]];
    //downvote bottom >= cardview bottom
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.downvoteButton
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:8]];
    //upvote / downvote equal size
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.downvoteButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.upvoteButton
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1
                                                               constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.downvoteButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.upvoteButton
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1
                                                               constant:0]];
    //body top to carcview top
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyContainerView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:8]];
    
    //title top to body top
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.bodyContainerView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0]];
    
    //body centery to cardview centery
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyContainerView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    
    //title bottom to authorlabel top
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.authorLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0]];
    
    //author bottom to body bottom
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyContainerView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.authorLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0]];
    
    //body bottom >= cardview bottom
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.bodyContainerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:8]];
    
    //author label leading to title label leading
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.authorLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:0]];
    
    //title trailing to body trailing
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyContainerView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:0]];
    
    //body trailing to cardview trailing
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.bodyContainerView
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:8]];
    
    //hasthumbnailconstraints
    //thumbnail leading to upvote trailing
    [self.hasThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.upvoteButton
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1
                                                                          constant:8]];
    //thumbnail centery to cardview centery
    [self.hasThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.cardView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0]];
    //thumbnail trailing to title leading
    [self.hasThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1
                                                                          constant:8]];
    
    //thumbnail top >= cardview top
    [self.hasThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                            toItem:self.cardView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:8]];
    
    //thumbnail bottom >= cardview bottom
    [self.hasThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                            toItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1
                                                                          constant:8]];
    
    [self.hasThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1
                                                                          constant:0]];
    
    [self.hasThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:72]];
    
    [self.thumbnail setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    
    //nothumbnailconstraints
    //body leading to upvote trailing
    [self.noThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.bodyContainerView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.upvoteButton
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1
                                                                         constant:8]];
    
    //title leading to body leading
    [self.noThumbnailConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.bodyContainerView
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:0]];

}

@end
