//
//  DSPSendMessageTVC.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/3/15.
//
//

#import "DSPSendMessageTVC.h"
#import <RedditKit/RedditKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <iAd/iAd.h>
#import "IAPHelper.h"


@interface DSPSendMessageTVC () <UIAlertViewDelegate>
@property (strong, nonatomic) DSPSubmitLinkCell *sizingCell;
@property (strong, nonatomic) UIBarButtonItem *sendButton;
@property (strong, nonatomic) NSMutableArray *cellsIndex;
@property (strong, nonatomic) NSString *captchaIdentifier;
@property (strong, nonatomic) UIImage *captchaImage;
@property (strong, nonatomic) NSString *captchaText;
@property (nonatomic, assign) BOOL captchaNeeded;


@end

@implementation DSPSendMessageTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //this hides extra separators

    self.navigationItem.title = @"Message the mods";
    
    self.sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = self.sendButton;
    
    self.sizingCell = [[DSPSubmitLinkCell alloc] initWithReuseIdentifier:nil];
    self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sizingCell.hidden = YES;
    [self.tableView addSubview:self.sizingCell];
    self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 300);
    
    self.cellsIndex = [NSMutableArray arrayWithObjects:@"recipientCell", @"subjectCell", @"messageCell", nil];
    
    [self updateIAPStatus:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIAPStatus:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [self getNewCaptcha];
}

- (void)send
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak  __typeof(self)weakSelf = self;
    [[RKClient sharedClient] sendMessage:self.message
                                 subject:self.subject
                               recipient:self.recipient
                       captchaIdentifier:self.captchaIdentifier
                            captchaValue:self.captchaText
                              completion:^(NSError *error) {
                                  if (!error) {
                                      UIAlertView *submissionAlertVew = [[UIAlertView alloc] initWithTitle:@"Message sent"
                                                                                                   message:nil
                                                                                                  delegate:weakSelf
                                                                                         cancelButtonTitle:@"OK"
                                                                                         otherButtonTitles:nil];
                                      [submissionAlertVew show];
                                  } else {
                                      UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                                           message:error.localizedFailureReason
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"OK"
                                                                                 otherButtonTitles:nil];
                                      [errorAlert show];
                                      
                                      [weakSelf getNewCaptcha];
                                  }
                                  [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                              }];
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
    }];
    
    [self updateSendButtonStatus];
}

- (void)updateSendButtonStatus
{
    if ([[RKClient sharedClient] isSignedIn]) {
        if (self.captchaNeeded == YES) {
            
            if ([self.captchaText length] > 0) {
                self.sendButton.enabled = YES;
            } else {
                self.sendButton.enabled = NO;
            }
        } else {
            self.sendButton.enabled = YES;
        }
    } else {
        self.sendButton.enabled = NO;
    }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
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
    cell.titleLabel.numberOfLines = 1;
    cell.subtitleLabel.numberOfLines = 1;
    
    if ([cellType isEqualToString:@"recipientCell"]) {
        cell.titleLabel.text = @"To:";
        cell.subtitleLabel.text = self.recipient;
    } else if ([cellType isEqualToString:@"subjectCell"]) {
        cell.titleLabel.text = @"Subject: ";
        cell.subtitleLabel.text = self.subject;
    } else if ([cellType isEqualToString:@"messageCell"]) {
        cell.subtitleLabel.numberOfLines = 2;
        cell.titleLabel.text = @"Message: ";
        cell.subtitleLabel.text = self.message;
    } else if ([cellType isEqualToString:@"captchaCell"]) {
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.captchaText = textField.text;
    [self updateSendButtonStatus];
    
    return YES;
}

- (void)textFieldTextDidChange:(UITextField *)textfield
{
    self.captchaText = textfield.text;
    [self updateSendButtonStatus];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Message sent"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
