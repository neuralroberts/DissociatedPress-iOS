//
//  DSPSubmitLinkTVC.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/9/14.
//
//

#import <UIKit/UIKit.h>
#import "DSPNewsStory.h"
#import "DSPSubmitLinkCell.h"


@interface DSPSubmitLinkTVC : UITableViewController <UITextFieldDelegate, DSPSubmitLinkCellDelegate>

- (void)getNewCaptcha;
- (void)textFieldTextDidChange:(UITextField *)textfield;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)commentSwitchDidChange:(UISwitch *)commentSwitch;


@property (strong, nonatomic) DSPNewsStory *story;
@property (nonatomic, strong) NSString *tokenDescriptionString;
@property (strong, nonatomic) NSArray *queries;
@property (strong, nonatomic) NSArray *topics;


@end
