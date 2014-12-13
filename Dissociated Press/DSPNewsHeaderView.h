//
//  DPNewsHeaderView.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/4/14.
//
//

#import <UIKit/UIKit.h>
#import "DSPNewsTVC.h"

@interface DSPNewsHeaderView : UIView

@property (weak, nonatomic) DSPNewsTVC<UISearchBarDelegate> *tableViewController;
@property (strong, nonatomic) NSMutableArray *searchBars; // array of uisearchbars
@property (nonatomic, strong) UIStepper *stepper;

- (CGFloat)headerHeight;

@end
