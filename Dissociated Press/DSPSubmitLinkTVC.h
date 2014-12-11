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
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@property (strong, nonatomic) DSPNewsStory *story;

@end
