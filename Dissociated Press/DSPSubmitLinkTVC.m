//
//  DSPSubmitLinkTVC.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/9/14.
//
//

#import "DSPSubmitLinkTVC.h"
#import <RedditKit/RedditKit.h>

@interface DSPSubmitLinkTVC ()
@property (strong, nonatomic) NSMutableArray *cellsIndex;
@property (strong, nonatomic) UIBarButtonItem *submitButton;
@property (strong, nonatomic) NSString *captchaIdentifier;
@property (strong, nonatomic) UIImage *captchaImage;
@property (strong, nonatomic) NSString *captchaText;
@property (nonatomic, assign) BOOL captchaNeeded;
@property (strong, nonatomic) DSPSubmitLinkCell *sizingCell;
@end

@implementation DSPSubmitLinkTVC

- (void)submitPost
{
    //    void(^postStoryAtIndexPath)(DSPNewsStory*, NSIndexPath*) = ^void(DSPNewsStory *story, NSIndexPath *indexPath) {
    //        NSLog(@"logged in as %@",[[RKClient sharedClient] currentUser]);
    //        //        DSPRedditPostViewController *postViewController = [[DSPRedditPostViewController alloc] init];
    //        //        postViewController.story = story;
    //        //        [self.navigationController pushViewController:postViewController animated:YES];
    //        //        [[RKClient sharedClient] needsCaptchaWithCompletion:^(BOOL result, NSError *error) {
    //        //            if (result == YES) {
    //        //                NSLog(@"needs captcha");
    //        //                [[RKClient sharedClient] newCaptchaIdentifierWithCompletion:^(id object, NSError *error) {
    //        //                    NSString *captchaIdentifier = object;
    //        //                    [[RKClient sharedClient] imageForCaptchaIdentifier:captchaIdentifier completion:^(id object, NSError *error) {
    //        //                        NSLog(@"%@\n, %@",object, error);
    //        //                        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:object];
    //        //                    }];
    //        //                }];
    //        //            } else {
    //        //                NSLog(@"no captcha needed");
    //        //            }
    //        //        }];
    //
    //        //
    //        //        NSURLSessionTask *urlSessionTask = [[RKClient sharedClient] submitLinkPostWithTitle:story.title subredditName:@"NewsSalad" URL:story.url captchaIdentifier:nil captchaValue:nil completion:^(NSError *error) {
    //        //            if (!error) {
    //        //                NSLog(@"should post here");
    //        //            } else {
    //        //                NSLog(@"Failed to post, with error: %@", error);
    //        //            }
    //        //        }];
    //
    //    };
    //
    //    if ([[RKClient sharedClient] isSignedIn]) {
    //        postStoryAtIndexPath(story, cellIndex);
    //    } else {
    //        self.authenticationManager = [[DSPAuthenticationManager alloc] init];
    //
    //        [self.authenticationManager signInWithCompletion:^{
    //            postStoryAtIndexPath(story, cellIndex);
    //        }];
    //    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = @"Submit to reddit";
    
    self.sizingCell = [[DSPSubmitLinkCell alloc] initWithReuseIdentifier:nil];
    self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sizingCell.hidden = YES;
    [self.tableView addSubview:self.sizingCell];
    self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 300);
    
    self.submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.submitButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.submitButton;
    
    self.cellsIndex = [NSMutableArray arrayWithObjects:@"titleCell", @"linkCell", @"userCell", nil];
    
    [self getNewCaptcha];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[RKClient sharedClient] isSignedIn]) {
        self.submitButton.enabled = YES;
    } else {
        self.submitButton.enabled = NO;
    }
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

- (void)getNewCaptcha
{
    self.captchaText = @"";

    for (NSString *cellType in self.cellsIndex) {
        if ([cellType isEqualToString:@"captchaCell"]) {
            NSArray *indexPathsToDelete = [self indexPathArrayForRangeFromStart:self.cellsIndex.count-1 toEnd:self.cellsIndex.count inSection:0];
            [self.tableView beginUpdates];
            [self.cellsIndex removeObject:cellType];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
    
    [[RKClient sharedClient] needsCaptchaWithCompletion:^(BOOL result, NSError *error) {
        if (result == YES) {
            self.captchaNeeded = YES;
            NSLog(@"needs captcha");
            self.captchaImage = nil;
            NSArray *indexPathsToInsert = [self indexPathArrayForRangeFromStart:self.cellsIndex.count toEnd:self.cellsIndex.count+1 inSection:0];
            [self.tableView beginUpdates];
            [self.cellsIndex addObject:@"captchaCell"];
            [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            [[RKClient sharedClient] newCaptchaIdentifierWithCompletion:^(id object, NSError *error) {
                self.captchaIdentifier = object;
                [[RKClient sharedClient] imageForCaptchaIdentifier:self.captchaIdentifier completion:^(id object, NSError *error) {
                    NSLog(@"%@\n, %@",object, error);
                    self.captchaImage = object;
                    NSArray *indexPathsToReload = [self indexPathArrayForRangeFromStart:self.cellsIndex.count-1 toEnd:self.cellsIndex.count inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }];
        } else {
            self.captchaNeeded = NO;
            self.captchaIdentifier = nil;
            self.captchaImage = nil;
            NSLog(@"no captcha needed");
        }
    }];
    
    [self updateSubmitButtonStatus];
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
    if ([cellType isEqualToString:@"titleCell"]) {
        cell.titleLabel.text = @"Title";
        cell.subtitleLabel.text = self.story.title;
    } else if ([cellType isEqualToString:@"linkCell"]) {
        cell.titleLabel.text = @"Link";
        cell.subtitleLabel.text = [self.story.url absoluteString];
    } else if ([cellType isEqualToString:@"userCell"]) {
        cell.titleLabel.text = @"Username";
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        if ([[RKClient sharedClient] isSignedIn]) {
            cell.detailTextLabel.text = [[[RKClient sharedClient] currentUser] username];
        } else {
            cell.subtitleLabel.text = @"You must be logged into reddit to post";
            cell.subtitleLabel.textColor = [UIColor redColor];
        }
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
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [textField resignFirstResponder];
    self.captchaText = textField.text;
    [self updateSubmitButtonStatus];
    
    return YES;
}


@end
