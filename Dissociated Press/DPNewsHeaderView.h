//
//  DPNewsHeaderView.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/4/14.
//
//

#import <UIKit/UIKit.h>
#import "NewsTableViewController.h"

@interface DPNewsHeaderView : UIView

@property (strong, nonatomic) NewsTableViewController<UISearchBarDelegate> *tableViewController;
@property (strong, nonatomic) NSMutableArray *searchBars; // array of uisearchbars
@property (nonatomic, strong) UIStepper *stepper;
@end
