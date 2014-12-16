//
//  NewsTableViewController.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPNewsTableViewCell.h"
#import "DSPQueryHeaderView.h"
#import "DSPTopicHeaderView.h"
#import "DSPTopicsTVC.h"




@interface DSPNewsTVC : UITableViewController <DSPNewsCellDelegate, DSPQueryHeaderDelegate, UISearchBarDelegate, DSPTopicHeaderDelegate, DSPTopicsTVCDelegate, UIPopoverControllerDelegate>

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
- (void)didClickActionButtonInCellAtIndexPath:(NSIndexPath *)cellIndex;
- (void)touchedStepper:(UIStepper *)sender;
- (void)touchedTopicHeader;
- (void)didDismissTopicsTVC;


@end
