//
//  DSPSubmitLinkTVC.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/9/14.
//
//

#import "DSPSubmitLinkTVC.h"
#import <RedditKit/RedditKit.h>
#import "RKClient+DSP.h"
#import "DSPAuthenticationTVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DSPWebViewController.h"
#import "DSPSendMessageTVC.h"
#import "IAPHelper.h"
#import <iAd/iAd.h>


@interface DSPSubmitLinkTVC () <UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray *cellsIndex;
@property (strong, nonatomic) UIBarButtonItem *submitButton;
@property (strong, nonatomic) NSString *captchaIdentifier;
@property (strong, nonatomic) UIImage *captchaImage;
@property (strong, nonatomic) NSString *captchaText;
@property (nonatomic, assign) BOOL captchaNeeded;
@property (nonatomic, assign) BOOL includeComment;
@property (strong, nonatomic) DSPSubmitLinkCell *sizingCell;
@end

@implementation DSPSubmitLinkTVC

- (void)submitPost
{
    DSPNewsStory *story = self.story;
    
    [MBProgressHUD showHUDAddedTo:self.originalContentView animated:YES];
    
    __weak  __typeof(self)weakSelf = self;
    [[RKClient sharedClient] DSPSubmitLinkPostWithTitle:story.dissociatedTitle subredditName:@"Dissociated_Press" URL:story.url resubmit:YES captchaIdentifier:weakSelf.captchaIdentifier captchaValue:weakSelf.captchaText completion:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        NSString *submittedLinkName = [responseObject  valueForKeyPath:@"json.data.name"];
        
        if (!error && submittedLinkName) {
            UIAlertView *submissionAlertVew = [[UIAlertView alloc] initWithTitle:@"Post successful"
                                                                         message:nil
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
            [submissionAlertVew show];
            
            if (weakSelf.includeComment) {
                [[RKClient sharedClient] submitComment:[weakSelf commentString] onThingWithFullName:submittedLinkName completion:^(NSError *error) {
                    if (error) {
                        NSLog(@"%@",error);
                    }
                }];
            }
        } else {
            NSString *errorTitle = @"Error";
            NSString *errorMessage = error.localizedFailureReason;
            NSString *otherButtonTitles = nil;
            NSString *errorKey = [responseObject valueForKeyPath:@"json.errors"][0][0];
            
            if ([errorKey isEqualToString:@"QUOTA_FILLED"] || error.code == RKClientErrorRateLimited) {
                errorTitle = @"Sorry!";
                if (responseObject) errorMessage = [responseObject valueForKeyPath:@"json.errors"][0][1];
                else errorMessage = @"You've submitted too many links recently.";
                otherButtonTitles = @"More info";
            }
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errorTitle
                                                                     message:errorMessage //error.localizedFailureReason
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:otherButtonTitles, nil];
            [errorAlertView show];
            
            [self getNewCaptcha];
        }
        
        [MBProgressHUD hideHUDForView:weakSelf.originalContentView animated:YES];
    }];
}


- (void)updateSubmitButtonStatus
{
    if ([[RKClient sharedClient] isSignedIn]) {
        if (self.captchaNeeded == YES) {
            
            if ([self.captchaText length] > 0) {
                self.submitButton.enabled = YES;
            } else {
                self.submitButton.enabled = NO;
            }
        } else {
            self.submitButton.enabled = YES;
        }
    } else {
        self.submitButton.enabled = NO;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //this hides extra separators
    
    self.navigationItem.title = @"Submit to reddit";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    self.sizingCell = [[DSPSubmitLinkCell alloc] initWithReuseIdentifier:nil];
    self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sizingCell.hidden = YES;
    [self.tableView addSubview:self.sizingCell];
    self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 300);
    
    self.submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitPost)];
    self.submitButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.submitButton;
    
    self.cellsIndex = [NSMutableArray arrayWithObjects:@"titleCell", @"linkCell", @"userCell", @"commentCell", nil];
    
    self.includeComment = [[NSUserDefaults standardUserDefaults] boolForKey:@"includeComment"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationStateDidChange) name:@"authenticationStateDidChange" object:nil];
    
    [self getNewCaptcha];
    
    [self updateIAPStatus:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIAPStatus:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@ %@",[self class], NSStringFromSelector(_cmd));
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)authenticationStateDidChange
{
    NSIndexPath *userCellIndexPath = [NSIndexPath indexPathForItem:[self.cellsIndex indexOfObject:@"userCell"] inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[userCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self getNewCaptcha];
}

- (void)getNewCaptcha
{
    self.captchaText = @"";
    
    //if there is already a captcha cell, remove it
    for (NSString *cellType in self.cellsIndex) {
        if ([cellType isEqualToString:@"captchaCell"]) {
            NSArray *indexPathsToDelete = [self indexPathArrayForRangeFromStart:self.cellsIndex.count-1 toEnd:self.cellsIndex.count inSection:0];
            [self.tableView beginUpdates];
            [self.cellsIndex removeObject:cellType];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
    
    //check whether captcha is needed
    //if so, grab one and add it to the table
    
    __weak __typeof(self)weakSelf = self;
    [[RKClient sharedClient] needsCaptchaWithCompletion:^(BOOL result, NSError *error) {
        if (result == YES) {
            weakSelf.captchaNeeded = YES;
            weakSelf.captchaImage = nil;
            NSArray *indexPathsToInsert = [weakSelf indexPathArrayForRangeFromStart:weakSelf.cellsIndex.count toEnd:weakSelf.cellsIndex.count+1 inSection:0];
            [weakSelf.tableView beginUpdates];
            [weakSelf.cellsIndex addObject:@"captchaCell"];
            [weakSelf.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
            
            [[RKClient sharedClient] newCaptchaIdentifierWithCompletion:^(id object, NSError *error) {
                weakSelf.captchaIdentifier = object;
                [[RKClient sharedClient] imageForCaptchaIdentifier:weakSelf.captchaIdentifier completion:^(id object, NSError *error) {
                    weakSelf.captchaImage = object;
                    NSArray *indexPathsToReload = [weakSelf indexPathArrayForRangeFromStart:weakSelf.cellsIndex.count-1 toEnd:weakSelf.cellsIndex.count inSection:0];
                    [weakSelf.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }];
        } else {
            weakSelf.captchaNeeded = NO;
            weakSelf.captchaIdentifier = nil;
            weakSelf.captchaImage = nil;
        }
        [weakSelf updateSubmitButtonStatus];
    }];
    
}

- (NSString *)commentString
{
    NSMutableString *commentString = [[NSMutableString alloc] initWithString:@""];
    
    NSString *title = [self.story.dissociatedTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [commentString appendString:[NSString stringWithFormat:@"**%@**  \n\n",title]];
    [commentString appendString:[NSString stringWithFormat:@"%@  \n",self.story.dissociatedContent]];
    [commentString appendString:@"&nbsp;\n\n"];
    [commentString appendString:[NSString stringWithFormat:@"*seed story: [%@](%@)*  \n",self.story.title, [self.story.url absoluteString]]];
    [commentString appendString:[NSString stringWithFormat:@"*%@*  \n",self.tokenDescriptionString]];
    if (self.queries) {
        [commentString appendString:[NSString stringWithFormat:@"*original queries: %@*",[self.queries componentsJoinedByString:@", "]]];
    }
    if (self.topics) {
        [commentString appendString:[NSString stringWithFormat:@"*original topics: %@*",[self.topics componentsJoinedByString:@", "]]];
    }
    
    return commentString;
}

- (NSArray *)indexPathArrayForRangeFromStart:(NSInteger)start toEnd:(NSInteger)end inSection:(NSInteger)section
{
    //returns an array of index paths in the given range
    //used by the tableview when inserting/deleting rows
    NSMutableArray *rangeArray = [NSMutableArray array];
    for (NSInteger i = start; i < end; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
        [rangeArray addObject:path];
    }
    return rangeArray;
}

- (void)updateIAPStatus:(NSNotification *)notification
{
    if ([[IAPHelper sharedInstance] productPurchased:IAPHelperProductRemoveAds]) {
        self.canDisplayBannerAds = NO;
    }
    else {
        self.canDisplayBannerAds = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cellsIndex count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellType = self.cellsIndex[indexPath.row];
    NSString *cellReuseIdentifier = @"submissionCell";

    DSPSubmitLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[DSPSubmitLinkCell alloc] initWithReuseIdentifier:cellReuseIdentifier];
    
    cell = [self configureCell:cell ForCellType:cellType];
    
    return cell;
}

- (DSPSubmitLinkCell *)configureCell:(DSPSubmitLinkCell *)cell ForCellType:(NSString *)cellType
{
    cell.isCaptchaCell = NO;
    cell.isCommentCell = NO;
    cell.subtitleLabel.numberOfLines = 2;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cellType isEqualToString:@"titleCell"]) {
        cell.titleLabel.text = @"Title";
        cell.subtitleLabel.text = self.story.dissociatedTitle;
    } else if ([cellType isEqualToString:@"linkCell"]) {
        cell.titleLabel.text = @"Link";
        cell.subtitleLabel.text = [self.story.url absoluteString];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([cellType isEqualToString:@"userCell"]) {
        cell.titleLabel.text = @"Username";
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        if ([[RKClient sharedClient] isSignedIn]) {
            cell.subtitleLabel.text = [[[RKClient sharedClient] currentUser] username];
            cell.subtitleLabel.textColor = [UIColor darkGrayColor];
        } else {
            cell.subtitleLabel.text = @"You must be logged into reddit to post";
            cell.subtitleLabel.textColor = [UIColor redColor];
        }
    } else if ([cellType isEqualToString:@"commentCell"]) {
        cell.isCommentCell = YES;
        cell.delegate = self;
        cell.subtitleLabel.numberOfLines = 0;
        cell.titleLabel.text = @"Include comment?";
        if (self.includeComment) {
            cell.subtitleLabel.text = [self commentString];
        } else {
            cell.subtitleLabel.text = nil;
        }
    }else if ([cellType isEqualToString:@"captchaCell"]) {
        cell.delegate = self;
        cell.captchaImageView.image = self.captchaImage;
        cell.isCaptchaCell = YES;
    }
    
    [cell setNeedsUpdateConstraints];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = self.cellsIndex[indexPath.row];
    self.sizingCell = [self configureCell:self.sizingCell ForCellType:cellType];
    
    CGFloat calculatedHeight = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return calculatedHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = self.cellsIndex[indexPath.row];
    
    if ([cellType isEqualToString:@"linkCell"]) {
        DSPWebViewController *webVC = [[DSPWebViewController alloc] initWithURL:self.story.url];
        [self.navigationController pushViewController:webVC animated:YES];
    } else if ([cellType isEqualToString:@"userCell"]) {
        DSPAuthenticationTVC *authenticationTVC = [[DSPAuthenticationTVC alloc] init];
        [self.navigationController pushViewController:authenticationTVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.captchaText = textField.text;
    [self updateSubmitButtonStatus];
    
    return YES;
}

- (void)textFieldTextDidChange:(UITextField *)textfield
{
    self.captchaText = textfield.text;
    [self updateSubmitButtonStatus];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Post successful"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if ([alertView.title isEqualToString:@"Sorry!"]) {
        if (buttonIndex == 1) {
            UIAlertView *moreInfoAlert = [[UIAlertView alloc] initWithTitle:@"Posting throttled"
                                                                    message:@"Reddit prevents new users from posting too often. This problem will go away once your posts receive enough votes. If you don't want to wait, message the Dissociated Press mods to have your account verified."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:@"Mail the mods", nil];
            [moreInfoAlert show];
        }
    }
    
    if ([alertView.title isEqualToString:@"Posting throttled"]) {
        if (buttonIndex == 1) {
            [self sendVerificationMessage];
        }
    }
}

- (void)sendVerificationMessage
{
    if ([[RKClient sharedClient] isSignedIn]) {
        DSPSendMessageTVC *messageTVC = [[DSPSendMessageTVC alloc] init];
        messageTVC.recipient = @"/r/Dissociated_Press";
        messageTVC.subject = @"Verify account";
        NSString *username = [[[RKClient sharedClient] currentUser] username];
        messageTVC.message = [NSString stringWithFormat:@"Please add account %@ to list of approved submitters for /r/Dissociated_Press",username];
        
        //    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //        UIPopoverController *popoverVC = [[UIPopoverController alloc] initWithContentViewController:messageTVC];
        ////        topicsTVC.preferredContentSize = CGSizeMake(320, topicsTVC.tableViewHeight+44.0);
        //        [popoverVC presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //    } else {
        [self.navigationController pushViewController:messageTVC animated:YES];
        //    }
    } else {
        UIAlertView *notSignedInAlert = [[UIAlertView alloc] initWithTitle:@"Not signed in"
                                                                   message:@"You must be signed in to reddit to send a message"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
        [notSignedInAlert show];
    }
}


- (void)commentSwitchDidChange:(UISwitch *)commentSwitch
{
    self.includeComment = commentSwitch.on;
    
    [[NSUserDefaults standardUserDefaults] setBool:self.includeComment forKey:@"includeComment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray *indexesToReload = [self indexPathArrayForRangeFromStart:3 toEnd:4 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:indexesToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
