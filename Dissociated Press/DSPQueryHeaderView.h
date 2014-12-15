//
//  DPNewsHeaderView.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/4/14.
//
//

#import <UIKit/UIKit.h>

@protocol DSPQueryHeaderDelegate <NSObject>
- (void)touchedStepper:(UIStepper *)sender;
@end

@interface DSPQueryHeaderView : UIView

@property (weak, nonatomic) id<DSPQueryHeaderDelegate, UISearchBarDelegate>delegate;
@property (strong, nonatomic) NSMutableArray *searchBars; // array of uisearchbars
@property (nonatomic, strong) UIStepper *stepper;

- (CGFloat)headerHeight;

@end
