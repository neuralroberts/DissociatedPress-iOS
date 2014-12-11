//
//  DSPSubmitLinkCell.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/10/14.
//
//

#import <UIKit/UIKit.h>
#import "DSPLabel.h"

@protocol DSPSubmitLinkCellDelegate <NSObject>
- (void)getNewCaptcha;
- (void)textFieldTextDidChange:(UITextField *)textfield;
@end

@interface DSPSubmitLinkCell : UITableViewCell

@property (weak, nonatomic) id<DSPSubmitLinkCellDelegate, UITextFieldDelegate>delegate;
@property (nonatomic, assign) BOOL isCaptchaCell;
@property (strong, nonatomic) DSPLabel *titleLabel;
@property (strong, nonatomic) DSPLabel *subtitleLabel;
@property (strong, nonatomic) UIImageView *captchaImageView;
@property (strong, nonatomic) UITextField *captchaTextField;
@property (strong, nonatomic) UIButton *captchaRefreshButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *cardView;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
