//
//  NewsTableViewController.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPNewsTableViewCell.h"

@interface DSPNewsTVC : UITableViewController <DSPNewsCellDelegate>

- (void)didClickActionButtonInCellAtIndexPath:(NSIndexPath *)cellIndex;

- (void)touchedStepper:(UIStepper *)sender;

@end
