//
//  DSPHelpTableViewCell.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/4/15.
//
//

#import "DSPTableViewCell.h"
#import "DSPLabel.h"

@protocol DSPHelpCellDelegate <NSObject>

- (void)didPressDisclosureButton;

@end

@interface DSPHelpTableViewCell : DSPTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)toggleHelp;

@property (weak, nonatomic) id<DSPHelpCellDelegate>delegate;
@property (strong, nonatomic) DSPLabel *titleLabel;
@property (strong ,nonatomic) DSPLabel *detailLabel;
@property (strong, nonatomic) UIButton *disclosureButton;

@end
