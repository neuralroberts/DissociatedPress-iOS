//
//  SettingsViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/12/14.
//
//

#import "SettingsViewController.h"

#define NUM_SECTIONS 1

#define SECTION_SETTINGS 0

#define NUM_ROWS_SETTINGS 2

@interface SettingsViewController ()

@property (nonatomic) NSInteger nGramSize;
@property (nonatomic, strong) UISlider *nGramSizeSlider;
@property (nonatomic, strong) UILabel *nGramSizeLabel;

@end

@implementation SettingsViewController

- (NSInteger)nGramSize
{
    if (!_nGramSize) {
        NSInteger nGramSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"nGramSizeParameter"];
        _nGramSize = nGramSize;
    }
    return _nGramSize;
}

- (UISlider *)nGramSizeSlider
{
    if (!_nGramSizeSlider) {
        UISlider *nGramSlider = [[UISlider alloc] init];
        nGramSlider.minimumValue = 1;
        nGramSlider.maximumValue = 9;
        nGramSlider.value = self.nGramSize;
        [nGramSlider addTarget:self action:@selector(nGramSliderChanged) forControlEvents:UIControlEventValueChanged];
        _nGramSizeSlider = nGramSlider;
    }
    return _nGramSizeSlider;
}

- (UILabel *)nGramSizeLabel
{
    if (!_nGramSizeLabel) {
        UILabel *nGramSizeLabel = [[UILabel alloc] init];
        nGramSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)self.nGramSize];
        _nGramSizeLabel = nGramSizeLabel;
    }
    return _nGramSizeLabel;
}

- (void)nGramSliderChanged
{
    self.nGramSize = self.nGramSizeSlider.value;
    self.nGramSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)self.nGramSize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.nGramSize forKey:@"nGramSizeParameter"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_SETTINGS:
            return NUM_ROWS_SETTINGS;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
    
    if (indexPath.section == SECTION_SETTINGS) {
        if (indexPath.row == 0) {
            self.nGramSizeSlider.frame = CGRectMake(cell.contentView.frame.origin.x + 112.0,
                                                    cell.contentView.frame.origin.y,
                                                    cell.contentView.frame.size.width - 164.0,
                                                    cell.contentView.frame.size.height);
            self.nGramSizeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            self.nGramSizeLabel.frame = CGRectMake(cell.contentView.frame.size.width - 32.0,
                                                   cell.contentView.frame.origin.y,
                                                   32.0,
                                                   cell.contentView.frame.size.height);
            self.nGramSizeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            cell.textLabel.text = @"nGram size";
            [cell.contentView addSubview:self.nGramSizeSlider];
            [cell.contentView addSubview:self.nGramSizeLabel];
        }
    }
    return cell;
}

@end
