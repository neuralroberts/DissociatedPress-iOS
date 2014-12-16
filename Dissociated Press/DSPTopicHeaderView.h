//
//  DSPTopicHeaderView.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/13/14.
//
//

#import <UIKit/UIKit.h>

@protocol DSPTopicHeaderDelegate <NSObject>
- (void)touchedTopicHeader;
@end

@interface DSPTopicHeaderView : UIView

@property (weak, nonatomic) id<DSPTopicHeaderDelegate>delegate;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *headerButton;

- (CGFloat)headerHeight;

@end
