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


#define NUM_SECTIONS 3

#define SECTION_DISSOCIATOR 0
#define SECTION_ACCOUNTS 1
#define SECTION_ABOUT 2

#define NUM_ROWS_DISSOCIATOR 3
#define NUM_ROWS_ACCOUNTS 1
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
    
    self.sizingCell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:nil];
    self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sizingCell.hidden = YES;
    [self.tableView addSubview:self.sizingCell];
    self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 300);
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
        if (!self.helpCell) {
            self.helpCell = [[DSPHelpTableViewCell alloc] initWithReuseIdentifier:nil];
            self.helpCell.delegate = self;
            self.helpCell.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 200);
        }
        
        [self.helpCell setNeedsUpdateConstraints];
        [self.helpCell setNeedsLayout];
        [self.helpCell layoutIfNeeded];
        return self.helpCell;
    } else {
        NSString *reuseIdentifier = @"settingsCell";
        DSPSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) cell = [[DSPSettingsTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
        
        cell = [self configureCell:cell AtIndexPath:indexPath];
        
        return cell;
    }
}

- (DSPSettingsTableViewCell *)configureCell:(DSPSettingsTableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    cell.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 200);
    cell.delegate = self;
    
    if (indexPath.section == SECTION_DISSOCIATOR) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"Token type:";
            cell.tokenTypeControl.selectedSegmentIndex = [self.dissociateByWord intValue];
            cell.cellType = DSPSettingsCellTypeTokenType;
        } else if (indexPath.row == 1) {
            cell.titleLabel.text = @"Token size:";
            cell.tokenSizeSlider.value = self.tokenSize;
            cell.tokenSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tokenSize];
            cell.cellType = DSPSettingsCellTypeTokenSize;
        }
    } else if (indexPath.section == SECTION_ACCOUNTS) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"Reddit account";
            if ([[RKClient sharedClient] isSignedIn]) {
                cell.detailLabel.text = [[[RKClient sharedClient] currentUser] username];
                cell.detailLabel.textColor = [UIColor darkGrayColor];
            } else {
                cell.detailLabel.text = @"Not signed in";
                cell.detailLabel.textColor = [UIColor redColor];
            }
            cell.cellType = DSPSettingsCellTypeDetail;
        }
    } else if (indexPath.section == SECTION_ABOUT) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"Report a bug";
            cell.cellType = DSPSettingsCellTypeDisclosure;
        } else if (indexPath.row == 1) {
            cell.titleLabel.text = @"Feedback";
            cell.cellType = DSPSettingsCellTypeDisclosure;
        } else if (indexPath.row == 2) {
            cell.titleLabel.text = @"Rate Dissociated Press";
            cell.cellType = DSPSettingsCellTypeDisclosure;
        } else if (indexPath.row == 3) {
            cell.titleLabel.text = @"Acknowledgements";
            cell.cellType = DSPSettingsCellTypeDisclosure;
        } else if (indexPath.row == 4) {
            NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            cell.titleLabel.text = [NSString stringWithFormat:@"Dissociated Press version %@",version];
            cell.detailLabel.text = @"";
            cell.cellType = DSPSettingsCellTypeDetail;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat calculatedHeight = 88.0;
    
    if (indexPath.section == SECTION_DISSOCIATOR && indexPath.row == ROW_DISSOCIATOR_HELPCELL) {
        [self.helpCell setNeedsLayout];
        [self.helpCell layoutIfNeeded];
        calculatedHeight = [self.helpCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    } else {
        [self configureCell:self.sizingCell AtIndexPath:indexPath];
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
