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

@property (nonatomic) NSNumber *dissociateByWord;
@property (nonatomic, strong) UISegmentedControl *dissociateByWordControl;

@end

@implementation SettingsViewController

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

- (UISegmentedControl *)dissociateByWordControl
{
    if (!_dissociateByWordControl) {
        NSArray *items = @[@"Char", @"Word"];
        UISegmentedControl *dissociateByWordControl = [[UISegmentedControl alloc] initWithItems:items];
        dissociateByWordControl.selectedSegmentIndex = [self.dissociateByWord intValue];
        [dissociateByWordControl addTarget:self action:@selector(dissociateByWordControlChanged) forControlEvents:UIControlEventValueChanged];
        _dissociateByWordControl = dissociateByWordControl;
    }
    return _dissociateByWordControl;
}

- (void)dissociateByWordControlChanged
{
    self.dissociateByWord = [NSNumber numberWithInteger:self.dissociateByWordControl.selectedSegmentIndex];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nGramSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"nGramSizeParameter"];
    BOOL dissociateByWord = [[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"];
    self.dissociateByWord = [NSNumber numberWithBool:dissociateByWord];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.nGramSize forKey:@"nGramSizeParameter"];
    [defaults setBool:[self.dissociateByWord boolValue] forKey:@"dissociateByWordParameter"];
    [defaults synchronize];
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
        } else if (indexPath.row == 1) {
            self.dissociateByWordControl.frame = CGRectMake(cell.contentView.frame.size.width - 128.0,
                                                            cell.contentView.frame.origin.y,
                                                            120.0,
                                                            cell.contentView.frame.size.height);
            self.dissociateByWordControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
            
            cell.textLabel.text = @"Dissociate by:";
            [cell.contentView addSubview:self.dissociateByWordControl];
        }
    }
    return cell;
}

@end
