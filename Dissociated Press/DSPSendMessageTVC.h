//
//  DSPSendMessageTVC.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/3/15.
//
//

#import <UIKit/UIKit.h>
#import "DSPSubmitLinkCell.h"


@interface DSPSendMessageTVC : UITableViewController <UITextFieldDelegate, DSPSubmitLinkCellDelegate>

- (void)getNewCaptcha;
- (void)textFieldTextDidChange:(UITextField *)textfield;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;


@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *recipient;
@end
