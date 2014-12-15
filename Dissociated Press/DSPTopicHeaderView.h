//
//  DSPTopicHeaderView.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/13/14.
//
//

#import <UIKit/UIKit.h>

@interface DSPTopicHeaderView : UIView

@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *headerButton;

- (CGFloat)headerHeight;

@end
