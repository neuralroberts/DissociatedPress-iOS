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

extern NSString* const DSPSettingsCellTypeTokenSize;
extern NSString* const DSPSettingsCellTypeTokenType;
extern NSString* const DSPSettingsCellTypeDetail;
extern NSString* const DSPSettingsCellTypeDisclosure;

@interface DSPSettingsTableViewCell : DSPTableViewCell

@property (weak, nonatomic) id<DSPSettingsCellDelegate>delegate;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UISlider *tokenSizeSlider;
@property (strong, nonatomic) UILabel *tokenSizeLabel;
@property (strong, nonatomic) UISegmentedControl *tokenTypeControl;
@property (strong, nonatomic) UIButton *disclosureButton;

@end
