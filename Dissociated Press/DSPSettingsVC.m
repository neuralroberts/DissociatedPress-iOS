//
//  SettingsViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/12/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPSettingsVC.h"
#import "DSPAuthenticationTVC.h"
#import <RedditKit/RedditKit.h>


#define NUM_SECTIONS 2

#define SECTION_DISSOCIATOR 0
#define SECTION_ACCOUNTS 1

#define NUM_ROWS_DISSOCIATOR 2
#define NUM_ROWS_ACCOUNTS 1

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
        NSArray *items = @[@"Character", @"Word"];
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
    
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationStateDidChange) name:@"authenticationStateDidChange" object:nil];
}

- (void)authenticationStateDidChange
{
    NSIndexPath *redditAccountCell = [NSIndexPath indexPathForItem:0 inSection:SECTION_ACCOUNTS];
    [self.tableView reloadRowsAtIndexPaths:@[redditAccountCell] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@ %@",[self class], NSStringFromSelector(_cmd));
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tokenSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"tokenSizeParameter"];
    BOOL dissociateByWord = [[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"];
    self.dissociateByWord = [NSNumber numberWithBool:dissociateByWord];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.tokenSize forKey:@"tokenSizeParameter"];
    [defaults setBool:[self.dissociateByWord boolValue] forKey:@"dissociateByWordParameter"];
    [defaults synchronize];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Dissociator settings";
            break;
            case 1:
            return @"Accounts";
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_DISSOCIATOR:
            return NUM_ROWS_DISSOCIATOR;
            break;
        case SECTION_ACCOUNTS:
            return NUM_ROWS_ACCOUNTS;
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
    
    cell.layer.cornerRadius = 12.0;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 8.0;
    cell.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == SECTION_DISSOCIATOR) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
            self.dissociateByWordControl.frame = CGRectMake(cell.contentView.frame.size.width - 184.0,
                                                            cell.contentView.frame.origin.y + 16.0,
                                                            160.0,
                                                            cell.contentView.frame.size.height - 32.0);
            self.dissociateByWordControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
            
            cell.textLabel.text = @"Dissociate by:";
            [cell.contentView addSubview:self.dissociateByWordControl];
        }
    } else if (indexPath.section == SECTION_ACCOUNTS) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = @"Reddit account";
        
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        UILabel *accountNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 144.0,
                                                                              cell.contentView.frame.origin.y + 16.0,
                                                                              200.0,
                                                                              cell.contentView.frame.size.height - 32.0)];
        accountNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [cell.contentView addSubview:accountNameLabel];
        
        if ([[RKClient sharedClient] isSignedIn]) {
            accountNameLabel.text = [[[RKClient sharedClient] currentUser] username];
            accountNameLabel.textColor = [UIColor darkGrayColor];
        } else {
            accountNameLabel.text = @"Not signed in";
            accountNameLabel.textColor = [UIColor redColor];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_DISSOCIATOR) {
    } else if (indexPath.section == SECTION_ACCOUNTS) {
        DSPAuthenticationTVC *authenticationTVC = [[DSPAuthenticationTVC alloc] init];
        [self.navigationController pushViewController:authenticationTVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
