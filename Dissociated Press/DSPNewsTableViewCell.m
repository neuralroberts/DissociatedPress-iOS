//
//  NewsTableViewCell.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/15/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPNewsTableViewCell.h"
#import "DSPImageStore.h"

@interface DSPNewsTableViewCell ()

@property (strong, nonatomic) NSMutableArray *hasThumbnailConstraints;
@property (strong, nonatomic) NSMutableArray *noThumbnailConstraints;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UIButton *dissociateButton;
@end

@implementation DSPNewsTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    self.thumbnail = [[UIImageView alloc] init];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFit;
    self.thumbnail.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.thumbnail];
    
    self.titleLabel = [[DSPLabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.cardView addSubview:self.titleLabel];
    
    self.contentLabel = [[DSPLabel alloc] init];
    self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.contentLabel.textColor = [UIColor blackColor];
    self.contentLabel.backgroundColor = [UIColor whiteColor];
    self.contentLabel.numberOfLines = 4;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.cardView addSubview:self.contentLabel];
    
    self.dateLabel = [[DSPLabel alloc] init];
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.dateLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.13 alpha:1.0];
    self.dateLabel.backgroundColor = [UIColor whiteColor];
    self.dateLabel.numberOfLines = 1;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.dateLabel];
    
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.actionButton setImage:[UIImage imageNamed:@"UIButtonAction"] forState:UIControlStateNormal];
    [self.actionButton setImage:[UIImage imageNamed:@"UIButtonAction_Selected"] forState:UIControlStateHighlighted];
    
    self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionButton addTarget:self action:@selector(didClickActionButton) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.actionButton];
    
    self.dissociateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dissociateButton setImage:[UIImage imageNamed:@"UIButton_UnicodeGameDie"] forState:UIControlStateNormal];
    [self.dissociateButton setImage:[UIImage imageNamed:@"UIButton_UnicodeGameDie_Selected"] forState:UIControlStateHighlighted];
    self.dissociateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dissociateButton addTarget:self action:@selector(didTouchDownDissociateButton) forControlEvents:UIControlEventTouchDown];
    [self.dissociateButton addTarget:self action:@selector(didTouchUpInsideDissociateButton) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.dissociateButton];
    
    self.hasThumbnailConstraints = [NSMutableArray array];
    self.noThumbnailConstraints = [NSMutableArray array];
    
    [self applyConstraints];
    
    return self;
}

- (void)didClickActionButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickActionButtonInCellAtIndexPath:)]) {
        [self.delegate didClickActionButtonInCellAtIndexPath:self.indexPath];
    }
}

- (void)didTouchUpInsideDissociateButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dissociateCellAtIndexPath:)]) {
        [self.delegate dissociateCellAtIndexPath:self.indexPath];
    }
}

- (void)didTouchDownDissociateButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(reassociateCellAtIndexPath:)]) {
        [self.delegate reassociateCellAtIndexPath:self.indexPath];
    }
}


- (void)setNewsStory:(DSPNewsStory *)newsStory
{
    _newsStory = newsStory;
    
    self.titleLabel.attributedText = [self attributedTitleForStory:newsStory];
    self.contentLabel.attributedText = [self attributedContentForStory:newsStory];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:newsStory.date]];
    
    
    if (self.newsStory.hasThumbnail) {
        self.thumbnail.hidden = NO;
        
        UIImage *image = [[DSPImageStore sharedStore] imageForKey:self.newsStory.uniqueIdentifier];
        if (image) self.thumbnail.image = image;
        else {
            self.thumbnail.image = [UIImage imageNamed:@"mirroredNewspaperBW"];
            __weak __typeof(self)weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:weakSelf.newsStory.imageUrl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    [[DSPImageStore sharedStore] setImage:image forKey:weakSelf.newsStory.uniqueIdentifier];
                    weakSelf.thumbnail.image = image;
                });
            });
        }
    } else {
        self.thumbnail.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (NSAttributedString *)attributedTitleForStory:(DSPNewsStory *)story
{
    NSString *dissociatedTitle = story.dissociatedTitle;
    if ([dissociatedTitle length] > 0) {
        NSString *displayString = [dissociatedTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        return [[NSAttributedString alloc] initWithString:displayString attributes:attributes];
    } else {
        NSString *originalTitle = story.title;
        NSString *displayString = [originalTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
        return [[NSAttributedString alloc] initWithString:displayString attributes:attributes];
    }
}

- (NSAttributedString *)attributedContentForStory:(DSPNewsStory *)story
{
    NSString *dissociatedContent = story.dissociatedContent;
    if ([dissociatedContent length] > 0) {
        NSString *displayString = [dissociatedContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        return [[NSAttributedString alloc] initWithString:displayString attributes:attributes];
    } else {
        NSString *originalContent = story.content;
        NSString *displayString = [originalContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
        return [[NSAttributedString alloc] initWithString:displayString attributes:attributes];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.newsStory.hasThumbnail) {
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
    
    //set compression & hugging priority for buttons
    for (UIButton *button in @[self.actionButton, self.dissociateButton]) {
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    
    //thumbnail size
    [self.thumbnail setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.thumbnail setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
//    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    CGFloat thumbnailSize = 48;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        thumbnailSize = 72;
    }
    [self.thumbnail addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationLessThanOrEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:thumbnailSize]];
    
    [self.thumbnail addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.thumbnail
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1
                                                                constant:0]];
    
    //unconditional constraints
    [self.cardView addConstraints:@[
                                    //title leading = cardview leading + 16
                                    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //title top = cardview top + 16
                                    [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //dissociate button leading = title trailing + 16
                                    [NSLayoutConstraint constraintWithItem:self.dissociateButton
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //dissociate button top = cardview top + 16
                                    [NSLayoutConstraint constraintWithItem:self.dissociateButton
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //cardview trailing = dissociate button trailing + 16
                                    [NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dissociateButton
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //action button top = dissociate button bottom + 16
                                    [NSLayoutConstraint constraintWithItem:self.actionButton
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dissociateButton
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //action button centerX = dissociate button centerX + 0
                                    [NSLayoutConstraint constraintWithItem:self.actionButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dissociateButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0],
                                    
                                    //cardview bottom >= actionbutton bottom + 16
                                    [NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.actionButton
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //date top = title bottom + 8
                                    [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8],
                                    
                                    //dissociate button leading = date trailing + 16
                                    [NSLayoutConstraint constraintWithItem:self.dissociateButton
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //body top = date bottom + 8
                                    [NSLayoutConstraint constraintWithItem:self.contentLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8],
                                    
                                    //dissociated button leading = body trailing + 16
                                    [NSLayoutConstraint constraintWithItem:self.dissociateButton
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //cardview bottom >= body bottom + 16
                                    [NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.contentLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //thumbnail top = title bottom + 8
                                    [NSLayoutConstraint constraintWithItem:self.thumbnail
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8],
                                    
                                    //thumbnail leading = card leading + 16
                                    [NSLayoutConstraint constraintWithItem:self.thumbnail
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1
                                                                  constant:16],
                                    
                                    //card bottom >= thumb bottom + 16
                                    [NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.thumbnail
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:16]
                                    ]];
    
    //constraints for no thumbnail condition
    [self.noThumbnailConstraints addObjectsFromArray:@[
                                                       //date leading = title leading + 0
                                                       [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.titleLabel
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                   multiplier:1
                                                                                     constant:0],
                                                       
                                                       //body leading = title leading + 0
                                                       [NSLayoutConstraint constraintWithItem:self.contentLabel
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.titleLabel
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                   multiplier:1
                                                                                     constant:0]
                                                       ]];
    
    //constraints for has thumbnail condition
    [self.hasThumbnailConstraints addObjectsFromArray:@[
                                                        //date leading = thumbnail trailing + 16
                                                        [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.thumbnail
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                    multiplier:1
                                                                                      constant:16],
                                                        
                                                        //body leading = thumbnail trailing + 16
                                                        [NSLayoutConstraint constraintWithItem:self.contentLabel
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.thumbnail
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                    multiplier:1
                                                                                      constant:16]
                                                        ]];
}

@end
