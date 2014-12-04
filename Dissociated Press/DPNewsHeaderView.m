//
//  DPNewsHeaderView.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/4/14.
//
//

#import "DPNewsHeaderView.h"

@implementation DPNewsHeaderView

- (instancetype)init
{
    self = [super init];
    
    self.backgroundColor = [UIColor colorWithRed:0.788 green:0.788 blue:0.788 alpha:0.9];
    
    NSArray *queries = @[@"florida man",@"",@"",@"",@""];
    self.searchBars = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        [self addSubview:searchBar];
        [self.searchBars addObject:searchBar];
        [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        searchBar.placeholder = [NSString stringWithFormat:@"Query %lu",(unsigned long)self.searchBars.count];
        if ([queries[i] length] > 0) {
            searchBar.text = queries[i];
        }
        searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    self.stepper = [[UIStepper alloc] init];
    self.stepper.minimumValue = 1;
    self.stepper.maximumValue = 5;
    self.stepper.value = 1;
    [self addSubview:self.stepper];
    self.stepper.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            44.0 * self.stepper.value);
    
    [self applyConstraints];
    
    return self;
}

- (void)setTableViewController:(NewsTableViewController<UISearchBarDelegate> *)tableViewController
{
    for (UISearchBar *searchBar in self.searchBars) {
        searchBar.delegate = tableViewController;
    }
    [self.stepper addTarget:self.tableViewController action:@selector(touchedStepper:) forControlEvents:UIControlEventValueChanged];
    _tableViewController = tableViewController;
}

- (void)applyConstraints
{
    for (int numSearchBar = 0; numSearchBar < 5; numSearchBar++) {
        UISearchBar *searchBar = self.searchBars[numSearchBar];
        [searchBar setContentCompressionResistancePriority:(UILayoutPriorityDefaultHigh - numSearchBar) forAxis:UILayoutConstraintAxisVertical];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:searchBar
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1
                                                          constant:110]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:searchBar
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1
                                                          constant:0]];
        
        if (numSearchBar == 0) {//pin first search bar to top of superview
            [self addConstraint:[NSLayoutConstraint constraintWithItem:searchBar
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0]];
        } else {//pin each search bar to the bottom of the preceding bar
            UISearchBar *lastSearchBar = self.searchBars[numSearchBar - 1];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:searchBar
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:lastSearchBar
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1
                                                              constant:0]];
            if (numSearchBar == 4) {//pin the last searchbar to the bottom of the superview
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:searchBar
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:0]];
            }
        }
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stepper
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stepper
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBars[0]
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.stepper
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:8]];
}
@end
