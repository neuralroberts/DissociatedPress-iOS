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
#import <Appirater/Appirater.h>
#import <iAd/iAd.h>
#import "IAPHelper.h"


#define NUM_SECTIONS 4

#define SECTION_DISSOCIATOR 0
#define SECTION_ACCOUNTS 1
#define SECTION_PURCHASES 2
#define SECTION_ABOUT 3

#define NUM_ROWS_DISSOCIATOR 3
#define NUM_ROWS_ACCOUNTS 1
#define NUM_ROWS_PURCHASES 2
#define NUM_ROWS_ABOUT 5

#define ROW_DISSOCIATOR_HELPCELL 2


@interface DSPSettingsVC ()

@property (nonatomic) NSInteger tokenSize;
@property (nonatomic) NSNumber *dissociateByWord;

@property (strong, nonatomic) DSPSettingsTableViewCell *sizingCell;
@property (strong, nonatomic) DSPHelpTableViewCell *helpCell;

@end

@implementation DSPSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationStateDidChange) name:@"authenticationStateDidChange" object:nil];
    
    self.helpCell = [[DSPHelpTableViewCell alloc] initWithReuseIdentifier:nil];
    self.helpCell.delegate = self;
    self.helpCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.helpCell.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 70);
    
    [self updateIAPStatus:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIAPStatus:) name:IAPHelperProductPurchasedNotification object:nil];

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

- (void)toggleHelpCell
{
    [self.helpCell toggleHelp];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)updateIAPStatus:(NSNotification *)notification
{
    if ([[IAPHelper sharedInstance] productPurchased:IAPHelperProductRemoveAds]) {
        self.canDisplayBannerAds = NO;
    }
    else {
        self.canDisplayBannerAds = YES;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:SECTION_PURCHASES];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        case 2:
            return @"In-App purchases";
            break;
        case 3:
            return @"About Dissociated Press";
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
            case SECTION_PURCHASES:
            return NUM_ROWS_PURCHASES;
            break;
        case SECTION_ABOUT:
            return NUM_ROWS_ABOUT;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_DISSOCIATOR && indexPath.row == ROW_DISSOCIATOR_HELPCELL) {
        [self.helpCell setNeedsUpdateConstraints];
        [self.helpCell setNeedsLayout];
        [self.helpCell layoutIfNeeded];
        return self.helpCell;
    } else {
        return [self tableView:tableView settingsCellForIndexPath:indexPath];
    }
}

- (DSPSettingsTableViewCell *)tableView:(UITableView *)tableView settingsCellForIndexPath:(NSIndexPath *)indexPath
{
    DSPSettingsTableViewCell *cell;
    
    if (indexPath.section == SECTION_DISSOCIATOR) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeTokenType];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeTokenType];
            cell.titleLabel.text = @"Token type:";
            cell.tokenTypeControl.selectedSegmentIndex = [self.dissociateByWord intValue];
            cell.delegate = self;
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeTokenSize];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeTokenSize];
            cell.titleLabel.text = @"Token size:";
            cell.tokenSizeSlider.value = self.tokenSize;
            cell.tokenSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tokenSize];
            cell.delegate = self;
        }
        
    } else if (indexPath.section == SECTION_ACCOUNTS) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDetail];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDetail];
            cell.titleLabel.text = @"Reddit account";
            if ([[RKClient sharedClient] isSignedIn]) {
                cell.detailLabel.text = [[[RKClient sharedClient] currentUser] username];
                cell.detailLabel.textColor = [UIColor darkGrayColor];
            } else {
                cell.detailLabel.text = @"Not signed in";
                cell.detailLabel.textColor = [UIColor redColor];
            }
        }
        
    } else if (indexPath.section == SECTION_PURCHASES) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDetail];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDetail];
            cell.titleLabel.text = @"Remove all ads";
            if ([[IAPHelper sharedInstance] productPurchased:IAPHelperProductRemoveAds]) {
                cell.detailLabel.text = @"\u2713";
            }
            else {
                cell.detailLabel.text = @"$0.99";
            }
            cell.detailLabel.textColor = [UIColor darkGrayColor];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDetail];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDetail];
            cell.titleLabel.text = @"Restore In-App Purchases";
            cell.detailLabel.text = @"";
        }
        
    } else if (indexPath.section == SECTION_ABOUT) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDisclosure];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDisclosure];
            cell.titleLabel.text = @"Report a bug";
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDisclosure];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDisclosure];
            cell.titleLabel.text = @"Feedback";
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDisclosure];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDisclosure];
            cell.titleLabel.text = @"Rate Dissociated Press";
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDisclosure];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDisclosure];
            cell.titleLabel.text = @"Acknowledgements";
        } else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:DSPSettingsCellTypeDetail];
            if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:DSPSettingsCellTypeDetail];
            NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            cell.titleLabel.text = @"Version";
            cell.detailLabel.text = version;
            cell.detailLabel.textColor = [UIColor darkGrayColor];
        }
    }
    
    cell.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 200);
    [cell setNeedsUpdateConstraints];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat calculatedHeight = 88.0;
    
    if (indexPath.section == SECTION_DISSOCIATOR && indexPath.row == ROW_DISSOCIATOR_HELPCELL) {
        [self.helpCell setNeedsUpdateConstraints];
        [self.helpCell setNeedsLayout];
        [self.helpCell layoutIfNeeded];
        calculatedHeight = [self.helpCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    } else {
        [self.sizingCell removeFromSuperview];
        self.sizingCell = [self tableView:tableView settingsCellForIndexPath:indexPath];
        self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.sizingCell.hidden = YES;
        [tableView addSubview:self.sizingCell];
        calculatedHeight = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    return calculatedHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_DISSOCIATOR) {
        if (indexPath.row == ROW_DISSOCIATOR_HELPCELL) {
            [self toggleHelpCell];
        }
        
    } else if (indexPath.section == SECTION_ACCOUNTS) {
        DSPAuthenticationTVC *authenticationTVC = [[DSPAuthenticationTVC alloc] init];
        [self.navigationController pushViewController:authenticationTVC animated:YES];
        
    } else if (indexPath.section == SECTION_PURCHASES) {
        if (indexPath.row == 0) {
            [[IAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                if (success) {
                    for (SKProduct *product in products) {
                        if ([product.productIdentifier isEqualToString:IAPHelperProductRemoveAds]) {
                            [[IAPHelper sharedInstance] buyProduct:product];
                        }
                    }
                } else {
                    UIAlertView *IAPAlert = [[UIAlertView alloc] initWithTitle:@"Could not reach the app store."
                                                                       message:@"Make sure you have internet connectivity."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                    [IAPAlert show];
                }
            }];
        } else if (indexPath.row == 1) {
            [[IAPHelper sharedInstance] restoreCompletedTransactions];
        }
        
    } else if (indexPath.section == SECTION_ABOUT) {
        if (indexPath.row == 0) {
            NSString *recipient = @"dissociatedpress@decentfolks.com";
            NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            NSString *subject = [NSString stringWithFormat:@"Bug report for Dissociated Press %@",version];
            [self composeMailWithRecipient:recipient Subject:subject];
        } else if (indexPath.row == 1) {
            NSString *recipient = @"dissociatedpress@decentfolks.com";
            NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            NSString *subject = [NSString stringWithFormat:@"Feedback for Dissociated Press %@",version];
            [self composeMailWithRecipient:recipient Subject:subject];
        } else if (indexPath.row == 2) {
            [Appirater forceShowPrompt:YES];
        } else if (indexPath.row == 3) {
            NSString *acknowledgementsMessage = [NSString stringWithFormat:@"AFNetworking (github.com/AFNetworking)\n"
                                                 @"Appirater (github.com/arashpayan)\n"
                                                 @"MBProgressHUD (github.com/jdg)\n"
                                                 @"MWFeedParser (github.com/mwaterfall)\n"
                                                 @"Mantle (github.com/Mantle)\n"
                                                 @"RedditKit (github.com/samsymons)\n"
                                                 @"SSKeyChain (github.com/soffes)\n"];
            UIAlertView *acknowledgementsView = [[UIAlertView alloc] initWithTitle:@"Acknowledgements"
                                                                           message:acknowledgementsMessage
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
            [acknowledgementsView show];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)composeMailWithRecipient:(NSString *)recipient Subject:(NSString *)subject
{
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    mailVC.mailComposeDelegate = self;
    [mailVC setSubject:subject];
    [mailVC setToRecipients:@[recipient]];
    [self presentViewController:mailVC animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultFailed || result == MFMailComposeResultSent) {
            if (error) {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                         message:error.localizedDescription
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                [errorAlertView show];
            } else {
                UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Message sent"
                                                                           message:@"Thanks for your feedback!"
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK" //@"Thank you for thanking me!"
                                                                 otherButtonTitles:nil];
                [successAlertView show];
            }
        }
    }];
}

#pragma mark - DSPSettingsCellDelegate

- (void)tokenSizeSliderDidChange:(UISlider *)sender
{
    self.tokenSize = sender.value;
}

- (void)tokenTypeDidChange:(UISegmentedControl *)sender
{
    self.dissociateByWord = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
}

#pragma mark - DSPHelpCellDelegate

- (void)didPressDisclosureButton
{
    [self toggleHelpCell];
}

@end
