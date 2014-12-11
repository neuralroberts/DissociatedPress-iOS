//
//  DSPSubmitLinkCell.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/10/14.
//
//

#import "DSPSubmitLinkCell.h"

@interface DSPSubmitLinkCell ()

@property (strong, nonatomic) NSMutableArray *defaultConstraints;
@property (strong, nonatomic) NSMutableArray *captchaConstraints;

@end

@implementation DSPSubmitLinkCell


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
    
    self.titleLabel = [[DSPLabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.titleLabel];
    
    self.subtitleLabel = [[DSPLabel alloc] init];
    self.subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.subtitleLabel.textColor = [UIColor darkGrayColor];
    self.subtitleLabel.backgroundColor = [UIColor whiteColor];
    self.subtitleLabel.numberOfLines = 2;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.subtitleLabel];
    
    self.captchaImageView = [[UIImageView alloc] init];
    self.captchaImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.captchaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.captchaImageView];
    
    self.captchaTextField = [[UITextField alloc] init];
    self.captchaTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.captchaTextField.layer.borderWidth = 0.5f;
    self.captchaTextField.layer.borderColor = [[UIColor redColor]CGColor];
    [self.cardView addSubview:self.captchaTextField];
    
    self.captchaRefreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.captchaRefreshButton setImage:[UIImage imageNamed:@"UIButtonBarRefresh"] forState:UIControlStateNormal];
    self.captchaRefreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.captchaRefreshButton addTarget:self action:@selector(didClickCaptchaRefresh) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.captchaRefreshButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview: self.activityIndicator];
    
    self.defaultConstraints = [NSMutableArray array];
    self.captchaConstraints = [NSMutableArray array];
    
    [self applyConstraints];
    
    return self;
}

- (void)setDelegate:(id<DSPSubmitLinkCellDelegate,UITextFieldDelegate>)delegate
{
    _delegate = delegate;
    self.captchaTextField.delegate = delegate;
}

- (void)didClickCaptchaRefresh
{
    self.captchaTextField.text = @"";
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getNewCaptcha)]) {
        [self.delegate getNewCaptcha];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.isCaptchaCell) {
        self.titleLabel.hidden = NO;
        self.subtitleLabel.hidden = NO;
        self.captchaImageView.hidden = YES;
        self.captchaTextField.hidden = YES;
        self.captchaRefreshButton.hidden = YES;
        [self.cardView removeConstraints:self.captchaConstraints];
        [self.cardView addConstraints:self.defaultConstraints];
        
    } else if (self.isCaptchaCell) {
        self.titleLabel.hidden = YES;
        self.subtitleLabel.hidden = YES;
        self.captchaImageView.hidden = NO;
        self.captchaTextField.hidden = NO;
        self.captchaRefreshButton.hidden = NO;
        [self.cardView removeConstraints:self.defaultConstraints];
        [self.cardView addConstraints:self.captchaConstraints];
        
        if (self.captchaImageView.image == nil) {
            [self.activityIndicator startAnimating];
        } else {
            [self.activityIndicator stopAnimating];
        }
    }
}

- (void)applyConstraints
{
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
    
    [self.captchaImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.captchaImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    /*
     *default constraints
     */
    [self.defaultConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.defaultConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.defaultConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.titleLabel
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.defaultConstraints addObject:[NSLayoutConstraint constraintWithItem:self.subtitleLabel
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.titleLabel
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.defaultConstraints addObject:[NSLayoutConstraint constraintWithItem:self.subtitleLabel
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.defaultConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.subtitleLabel
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.defaultConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.subtitleLabel
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:8]];
    
    /*
     *captcha constraints
     */
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaImageView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaImageView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaTextField
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.captchaImageView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaTextField
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cardView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.captchaTextField
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaTextField
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.captchaImageView
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1
                                                                     constant:0]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaTextField
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.captchaImageView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:0]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaRefreshButton
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.captchaImageView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:8]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.captchaRefreshButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.captchaImageView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:0]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:0]];
    
    [self.captchaConstraints addObject:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.cardView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0]];
}

@end
