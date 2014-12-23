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
    self.headerLabel.text = @"Search by topic";
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
    [self addSubview:self.headerButton];
    
    [self applyConstraints];
    
    return self;
}

- (void)setDelegate:(id<DSPTopicHeaderDelegate>)delegate
{
    _delegate = delegate;
    [self.headerButton addTarget:delegate action:@selector(touchedTopicHeader) forControlEvents:UIControlEventTouchUpInside];
}


- (CGFloat)headerHeight
{
    return (32.0 + self.headerLabel.intrinsicContentSize.height);
}

- (void)applyConstraints
{
    NSLayoutConstraint *constraint;
    
    [self.headerButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.headerButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headerLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.headerLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:0]];
    
    //this constraint cant be required, or it will conflict with the 'UIView-Encapsulated-Layout-Width' of 0, before the table view's frame has been set. Or something like that. 
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.headerButton
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1
                                               constant:16];
    [constraint setPriority:999.0];
    [self addConstraint:constraint];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:0]];
}



@end
