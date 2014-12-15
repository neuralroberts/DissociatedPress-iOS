//
//  DSPTopicHeaderView.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/13/14.
//
//

#import "DSPTopicHeaderView.h"

@interface DSPTopicHeaderView ()
@end

@implementation DSPTopicHeaderView

- (instancetype)init
{
    self = [super init];
    
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowRadius = 4;
    
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.text = @"Choose topics";
    self.headerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.headerLabel];
    
    self.headerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.headerButton setTitle:@"\u25BE" forState:UIControlStateNormal];
    [self.headerButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.headerButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.headerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.headerButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerButton.backgroundColor = [UIColor clearColor];
    [self.headerButton addTarget:self action:@selector(pressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.headerButton];
    
    NSArray *topics = @[@"Headlines", @"World", @"Business", @"Nation", @"Technology", @"Elections", @"Entertainment", @"Sports", @"Health"];

    [self applyConstraints];
    
    return self;
}

- (void)pressed
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (CGFloat)headerHeight
{
    return 44.0;
}

- (void)applyConstraints
{
    [self.headerButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.headerButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headerLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headerLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headerButton
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:16]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:16]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headerButton
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
}



@end
