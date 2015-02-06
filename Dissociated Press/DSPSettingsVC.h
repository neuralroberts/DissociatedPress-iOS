//
//  SettingsViewController.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/12/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPSettingsTableViewCell.h"
#import "DSPHelpTableViewCell.h"

@interface DSPSettingsVC : UITableViewController <DSPSettingsCellDelegate, DSPHelpCellDelegate>

- (void)tokenSizeSliderDidChange:(UISlider *)sender;
- (void)tokenTypeDidChange:(UISegmentedControl *)sender;
- (void)didPressDisclosureButton;

@end
