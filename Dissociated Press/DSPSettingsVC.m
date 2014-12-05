//
//  SettingsViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/12/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPSettingsVC.h"

#define NUM_SECTIONS 1

#define SECTION_SETTINGS 0

#define NUM_ROWS_SETTINGS 2

@interface DSPSettingsVC ()

@property (nonatomic) NSInteger tokenSize;
@property (nonatomic, strong) UISlider *tokenSizeSlider;
@property (nonatomic, strong) UILabel *tokenSizeLabel;

@property (nonatomic) NSNumber *dissociateByWord;
@property (nonatomic, strong) UISegmentedControl *dissociateByWordControl;

@end

@implementation DSPSettingsVC

- (UISlider *)tokenSizeSlider
{
    if (!_tokenSizeSlider) {
        UISlider *tokenSlider = [[UISlider alloc] init];
        tokenSlider.minimumValue = 1;
        tokenSlider.maximumValue = 9;
        tokenSlider.value = self.tokenSize;
        [tokenSlider addTarget:self action:@selector(tokenSliderChanged) forControlEvents:UIControlEventValueChanged];
        _tokenSizeSlider = tokenSlider;
    }
    return _tokenSizeSlider;
}

- (UILabel *)tokenSizeLabel
{
    if (!_tokenSizeLabel) {
        UILabel *tokenSizeLabel = [[UILabel alloc] init];
        tokenSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tokenSize];
        _tokenSizeLabel = tokenSizeLabel;
    }
    return _tokenSizeLabel;
}

- (void)tokenSliderChanged
{
    self.tokenSize = self.tokenSizeSlider.value;
    self.tokenSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tokenSize];
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
    
    self.tokenSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"tokenSizeParameter"];
    BOOL dissociateByWord = [[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"];
    self.dissociateByWord = [NSNumber numberWithBool:dissociateByWord];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.tokenSize forKey:@"tokenSizeParameter"];
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
            self.tokenSizeSlider.frame = CGRectMake(cell.contentView.frame.origin.x + 112.0,
                                                    cell.contentView.frame.origin.y,
                                                    cell.contentView.frame.size.width - 164.0,
                                                    cell.contentView.frame.size.height);
            self.tokenSizeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            self.tokenSizeLabel.frame = CGRectMake(cell.contentView.frame.size.width - 32.0,
                                                   cell.contentView.frame.origin.y,
                                                   32.0,
                                                   cell.contentView.frame.size.height);
            self.tokenSizeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            cell.textLabel.text = @"Token size";
            [cell.contentView addSubview:self.tokenSizeSlider];
            [cell.contentView addSubview:self.tokenSizeLabel];
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
