//
//  DSPSettingsTableViewCell.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/5/15.
//
//

#import "DSPSettingsTableViewCell.h"

NSString* const DSPSettingsCellTypeTokenSize = @"cellTypeTokenSize";
NSString* const DSPSettingsCellTypeTokenType = @"cellTypeTokenType";
NSString* const DSPSettingsCellTypeDetail = @"cellTypeDetail";
NSString* const DSPSettingsCellTypeDisclosure = @"cellTypeDisclosure";

@interface DSPSettingsTableViewCell ()

@property (strong, nonatomic) NSMutableArray *tokenSizeCellConstraints;
@property (strong, nonatomic) NSMutableArray *tokenTypeCellConstraints;
@property (strong, nonatomic) NSMutableArray *detailCellConstraints;
@property (strong, nonatomic) NSMutableArray *disclosureCellConstraints;
@end

@implementation DSPSettingsTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    [super applyConstraints];
    
    if ([reuseIdentifier isEqualToString:DSPSettingsCellTypeTokenSize]) {
        [self.cardView addSubview:self.titleLabel];
        [self.cardView addSubview:self.tokenSizeSlider];
        [self.cardView addSubview:self.tokenSizeLabel];
        [self.cardView addConstraints:self.tokenSizeCellConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([reuseIdentifier isEqualToString:DSPSettingsCellTypeTokenType]) {
        [self.cardView addSubview:self.titleLabel];
        [self.cardView addSubview:self.tokenTypeControl];
        [self.cardView addConstraints:self.tokenTypeCellConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([reuseIdentifier isEqualToString:DSPSettingsCellTypeDetail]) {
        [self.cardView addSubview:self.titleLabel];
        [self.cardView addSubview:self.detailLabel];
        [self.cardView addConstraints:self.detailCellConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([reuseIdentifier isEqualToString:DSPSettingsCellTypeDisclosure]) {
        [self.cardView addSubview:self.titleLabel];
        [self.cardView addSubview:self.disclosureButton];
        [self.cardView addConstraints:self.disclosureCellConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return self;
}

#pragma mark - properties

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _detailLabel.textColor = [UIColor darkGrayColor];
        _detailLabel.backgroundColor = [UIColor whiteColor];
        _detailLabel.numberOfLines = 1;
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _detailLabel;
}

- (UISlider *)tokenSizeSlider
{
    if (!_tokenSizeSlider) {
        _tokenSizeSlider = [[UISlider alloc] init];
        _tokenSizeSlider.minimumValue = 1;
        _tokenSizeSlider.maximumValue = 9;
        _tokenSizeSlider.value = 1;
        [_tokenSizeSlider addTarget:self action:@selector(tokenSizeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
        _tokenSizeSlider.translatesAutoresizingMaskIntoConstraints = NO;
        [_tokenSizeSlider setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_tokenSizeSlider setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _tokenSizeSlider;
}

- (UILabel *)tokenSizeLabel
{
    if (!_tokenSizeLabel) {
        _tokenSizeLabel = [[UILabel alloc] init];
        _tokenSizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tokenSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)1];
        [_tokenSizeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_tokenSizeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _tokenSizeLabel;
}

- (UISegmentedControl *)tokenTypeControl
{
    if (!_tokenTypeControl) {
        NSArray *tokenTypes = @[@"Character", @"Word"];
        _tokenTypeControl = [[UISegmentedControl alloc] initWithItems:tokenTypes];
        _tokenTypeControl.selectedSegmentIndex = 0;
        _tokenTypeControl.translatesAutoresizingMaskIntoConstraints = NO;
        [_tokenTypeControl addTarget:self action:@selector(tokenTypeDidChange:) forControlEvents:UIControlEventValueChanged];
        [_tokenTypeControl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_tokenTypeControl setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _tokenTypeControl;
}

- (UIButton *)disclosureButton
{
    if (!_disclosureButton) {
        _disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        _disclosureButton.enabled = NO;
        _disclosureButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_disclosureButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_disclosureButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _disclosureButton;
}

#pragma mark - delegate methods

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

#pragma mark - Constraints

- (NSMutableArray *)tokenSizeCellConstraints
{
    if (!_tokenSizeCellConstraints) {
        _tokenSizeCellConstraints = [NSMutableArray array];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.cardView
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.cardView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1
                                                                           constant:0]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                             toItem:self.cardView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                             toItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tokenSizeSlider
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tokenSizeSlider
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1
                                                                           constant:0]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tokenSizeLabel
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.tokenSizeSlider
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tokenSizeLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.tokenSizeSlider
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1
                                                                           constant:0]];
        
        [_tokenSizeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.tokenSizeLabel
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:16]];
    }
    return _tokenSizeCellConstraints;
}

- (NSMutableArray *)tokenTypeCellConstraints
{
    if (!_tokenTypeCellConstraints) {
        _tokenTypeCellConstraints = [NSMutableArray array];
        
        [_tokenTypeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.cardView
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenTypeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.cardView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1
                                                                           constant:0]];
        
        [_tokenTypeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                             toItem:self.cardView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenTypeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                             toItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenTypeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tokenTypeControl
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                             toItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:16]];
        
        [_tokenTypeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tokenTypeControl
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.titleLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1
                                                                           constant:0]];
        
        [_tokenTypeCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.tokenTypeControl
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:16]];
    }
    return _tokenTypeCellConstraints;
}

- (NSMutableArray *)detailCellConstraints
{
    if (!_detailCellConstraints) {
        _detailCellConstraints = [NSMutableArray array];
        
        [_detailCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.cardView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1
                                                                        constant:16]];
        
        [_detailCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.cardView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
        
        [_detailCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:self.cardView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1
                                                                        constant:16]];
        
        [_detailCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1
                                                                        constant:16]];
        
        [_detailCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.detailLabel
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1
                                                                        constant:16]];
        
        [_detailCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.detailLabel
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
        
        [_detailCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.detailLabel
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1
                                                                        constant:16]];
        
    }
    return _detailCellConstraints;
}

- (NSMutableArray *)disclosureCellConstraints
{
    if (!_disclosureCellConstraints) {
        _disclosureCellConstraints = [NSMutableArray array];
        
        [_disclosureCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.cardView
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1
                                                                            constant:16]];
        
        [_disclosureCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.cardView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1
                                                                            constant:0]];
        
        [_disclosureCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                              toItem:self.cardView
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1
                                                                            constant:16]];
        
        [_disclosureCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                              toItem:self.titleLabel
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1
                                                                            constant:16]];
        
        [_disclosureCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.disclosureButton
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                              toItem:self.titleLabel
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1
                                                                            constant:16]];
        
        [_disclosureCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.disclosureButton
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.titleLabel
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1
                                                                            constant:0]];
        
        [_disclosureCellConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.disclosureButton
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1
                                                                            constant:16]];
    }
    return _disclosureCellConstraints;
}


@end
