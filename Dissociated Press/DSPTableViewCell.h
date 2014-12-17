//
//  DSPTableViewCell.h
//  DissociatedPress-iOS
//
//  Created by Joe Wilkerson on 12/17/14.
//
//

#import <UIKit/UIKit.h>

@interface DSPTableViewCell : UITableViewCell

@property (strong, nonatomic) UIView *cardView;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;
- (void)applyConstraints;

@end
