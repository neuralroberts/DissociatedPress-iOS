//
//  DSPTableViewCell.m
//  DissociatedPress-iOS
//
//  Created by Joe Wilkerson on 12/17/14.
//
//

#import "DSPTableViewCell.h"

@implementation DSPTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.cardView = [[UIView alloc] init];
    [self.cardView setAlpha:1];
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.cornerRadius = 4;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 3.f);
    self.cardView.layer.shadowRadius = -.4f;
    self.cardView.layer.shadowOpacity = 0.2;
    self.cardView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.cardView];
    
    return self;
}

- (void)applyConstraints
{
    /*
     *constraints between cardView and contentView
     */
    [self.contentView removeConstraints:self.contentView.constraints];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:8]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:8]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1
                                                                  constant:16]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cardView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1
                                                                  constant:16]];
}
@end
