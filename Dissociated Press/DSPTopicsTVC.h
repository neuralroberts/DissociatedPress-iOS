//
//  DSPTopicsTVCTableViewController.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/16/14.
//
//

#import <UIKit/UIKit.h>

@protocol DSPTopicsTVCDelegate <NSObject>
- (void)didDismissTopicsTVC;
@end

@interface DSPTopicsTVC : UITableViewController

@property (nonatomic, weak) id<DSPTopicsTVCDelegate>delegate;
@property (nonatomic, strong) NSArray *topics;
@property (nonatomic, strong) NSMutableArray *selectedTopics;

- (CGFloat)tableViewHeight;

@end
