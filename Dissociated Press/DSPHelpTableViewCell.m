//
//  DSPHelpTableViewCell.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/4/15.
//
//

#import "DSPHelpTableViewCell.h"

@interface DSPHelpTableViewCell ()

@property (nonatomic, assign) BOOL isExpanded;

@property (nonatomic, strong) NSString *helpText;
@property (strong, nonatomic) NSMutableArray *compressedConstraints;
@property (strong, nonatomic) NSMutableArray *expandedConstraints;

@end

@implementation DSPHelpTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    self.helpText = [NSString stringWithFormat:@"Dissociated Press works by breaking the original text into smaller pieces, called tokens, "
                     "and then reassembling these probabilistically into a new text. \n\n"
                     "For example, \"illuminati\" split into 4-character tokens would look like this:\n"
                     "[illu],[llum],[lumi],[umin],[mina],[inat],[nati]\n\n"
                     "\"Vaccination\" would become:\n"
                     "[Vacc],[acci],[ccin],[cina],[inat],[nati],[atio],[tion]\n\n"
                     "These share the token [inat], so they can be reassembled to create: \"Vaccinati\"\n\n"
                     "Coincidence? Your call.\n\n"
                     "Good settings to start with are character tokens of size 3-6, or words tokens of size 1-2. "
                     "Too small token settings will result in a nonsensical text, "
                     "but too large tokens will create a text identical to the original."];
    
    self.titleLabel = [[DSPLabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"Dissociator Help";
    [self.cardView addSubview:self.titleLabel];
    
    self.detailLabel = [[DSPLabel alloc] init];
    self.detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.detailLabel.textColor = [UIColor darkGrayColor];
    self.detailLabel.backgroundColor = [UIColor whiteColor];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.text = nil;
    self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.cardView addSubview:self.detailLabel];
    
    self.disclosureButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.disclosureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.disclosureButton addTarget:self action:@selector(didPressDisclosureButton) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.disclosureButton];
    
    self.compressedConstraints = [NSMutableArray array];
    self.expandedConstraints = [NSMutableArray array];

    [self applyConstraints];

    self.isExpanded = NO;
    
    return self;
}


- (void)setIsExpanded:(BOOL)isExpanded
{
    _isExpanded = isExpanded;
    
    if (self.isExpanded) {
        [self.cardView removeConstraints:self.compressedConstraints];
        [self.cardView addConstraints:self.expandedConstraints];
    } else {
        [self.cardView removeConstraints:self.expandedConstraints];
        [self.cardView addConstraints:self.compressedConstraints];
    }
    
    [self setNeedsLayout];
}

- (void)toggleHelp
{
    if (self.isExpanded) {
        self.detailLabel.text = nil;
        self.isExpanded = NO;
    } else {
        self.detailLabel.text = self.helpText;
        self.isExpanded = YES;
    }
    
}

- (void)didPressDisclosureButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPressDisclosureButton)]) {
        [self.delegate didPressDisclosureButton];
    }
}


- (void)applyConstraints
{
    [super applyConstraints];
    
//    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.disclosureButton
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.disclosureButton
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.disclosureButton
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cardView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.disclosureButton
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:16]];
    
    
    /*
     compressed constraints
     */
    [self.compressedConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1
                                                                        constant:16]];
    
    
    /*
     expanded constraints
     */
    [self.expandedConstraints addObject:[NSLayoutConstraint constraintWithItem:self.detailLabel
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.titleLabel
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:16]];
    
    [self.expandedConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.detailLabel
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:16]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.detailLabel
                                                              attribute:NSLayoutAttributeLeading
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
