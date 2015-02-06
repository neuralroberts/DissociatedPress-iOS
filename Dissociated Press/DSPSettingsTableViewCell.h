//
//  DSPSettingsTableViewCell.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/5/15.
//
//

#import "DSPTableViewCell.h"
#import "DSPLabel.h"

@protocol DSPSettingsCellDelegate <NSObject>
- (void)tokenSizeSliderDidChange:(UISlider *)sender;
- (void)tokenTypeDidChange:(UISegmentedControl *)sender;
@end

typedef enum {
    DSPSettingsCellTypeTokenSize = 0,
    DSPSettingsCellTypeTokenType,
    DSPSettingsCellTypeAccount,
} DSPSettingsCellType;

@interface DSPSettingsTableViewCell : DSPTableViewCell

@property (weak, nonatomic) id<DSPSettingsCellDelegate>delegate;
@property (nonatomic) DSPSettingsCellType cellType;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UISlider *tokenSizeSlider;
@property (strong, nonatomic) UILabel *tokenSizeLabel;
@property (strong, nonatomic) UISegmentedControl *tokenTypeControl;

@end
