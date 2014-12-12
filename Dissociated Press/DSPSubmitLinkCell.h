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
- (void)commentSwitchDidChange:(UISwitch *)commentSwitch;
@end

@interface DSPSubmitLinkCell : UITableViewCell

@property (weak, nonatomic) id<DSPSubmitLinkCellDelegate, UITextFieldDelegate>delegate;
@property (nonatomic, assign) BOOL isCaptchaCell;
@property (nonatomic, assign) BOOL isCommentCell;
@property (strong, nonatomic) DSPLabel *titleLabel;
@property (strong, nonatomic) DSPLabel *subtitleLabel;
@property (strong, nonatomic) UISwitch *commentSwitch;
@property (strong, nonatomic) UIImageView *captchaImageView;
@property (strong, nonatomic) UITextField *captchaTextField;
@property (strong, nonatomic) UIButton *captchaRefreshButton;
@property (strong, nonatomic) UIView *cardView;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
