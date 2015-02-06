//
//  DSPSettingsTableViewCell.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/5/15.
//
//

#import "DSPSettingsTableViewCell.h"

@implementation DSPSettingsTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.titleLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.detailLabel.textColor = [UIColor darkGrayColor];
    self.detailLabel.backgroundColor = [UIColor whiteColor];
    self.detailLabel.numberOfLines = 1;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.detailLabel];
    
    self.tokenSizeSlider = [[UISlider alloc] init];
    self.tokenSizeSlider.minimumValue = 1;
    self.tokenSizeSlider.maximumValue = 9;
    self.tokenSizeSlider.value = 1;
    [self.tokenSizeSlider addTarget:self action:@selector(tokenSizeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    self.tokenSizeSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.tokenSizeSlider];
    
    self.tokenSizeLabel = [[UILabel alloc] init];
    self.tokenSizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tokenSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)1];
    [self.cardView addSubview:self.tokenSizeLabel];
    
    NSArray *tokenTypes = @[@"Character", @"Word"];
    self.tokenTypeControl = [[UISegmentedControl alloc] initWithItems:tokenTypes];
    self.tokenTypeControl.selectedSegmentIndex = 0;
    self.tokenTypeControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tokenTypeControl addTarget:self action:@selector(tokenTypeDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.cardView addSubview:self.tokenTypeControl];
    
    [self applyConstraints];
    
    return self;
}

- (void)tokenSizeSliderDidChange:(UISlider *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tokenSizeSliderDidChange:)]) {
        self.tokenSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)sender.value];
        [self.delegate tokenSizeSliderDidChange:sender];
    }
}

- (void)tokenTypeDidChange:(UISegmentedControl *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tokenTypeDidChange:)]) {
        [self.delegate tokenTypeDidChange:sender];
    }
}

- (void)setCellType:(DSPSettingsCellType)cellType
{
    _cellType = cellType;
    
    if (cellType == DSPSettingsCellTypeTokenSize) {
        self.titleLabel.hidden = NO;
        self.detailLabel.hidden = YES;
        self.tokenSizeSlider.hidden = NO;
        self.tokenSizeLabel.hidden = NO;
        self.tokenTypeControl.hidden = YES;
    } else if (cellType == DSPSettingsCellTypeTokenType) {
        self.titleLabel.hidden = NO;
        self.detailLabel.hidden = YES;
        self.tokenSizeSlider.hidden = YES;
        self.tokenSizeLabel.hidden = YES;
        self.tokenTypeControl.hidden = NO;
    } else if (cellType == DSPSettingsCellTypeAccount) {
        self.titleLabel.hidden = NO;
        self.detailLabel.hidden = NO;
        self.tokenSizeSlider.hidden = YES;
        self.tokenSizeLabel.hidden = YES;
        self.tokenTypeControl.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)updateConstraints
{
    [super updateConstraints];
}

- (void)applyConstraints
{
    [super applyConstraints];
    
    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tokenSizeSlider setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.tokenSizeSlider setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tokenSizeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tokenSizeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tokenTypeControl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tokenTypeControl setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.tokenSizeSlider
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.tokenSizeSlider
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.tokenSizeLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.tokenSizeSlider
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.tokenSizeLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.tokenSizeSlider
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.tokenSizeLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.tokenTypeControl
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.tokenTypeControl
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.tokenTypeControl
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.detailLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
}
@end
