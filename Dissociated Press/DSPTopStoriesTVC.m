//
//  DSPTopStoriesTVC.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/5/14.
//
//

#import "DSPTopStoriesTVC.h"
#import "DSPTopStoriesTableViewCell.h"
#import <RedditKit/RedditKit.h>
#import "DSPAuthenticationTVC.h"
#import "DSPWebViewController.h"
#import <iAd/iAd.h>
#import "IAPHelper.h"
#import "DSPImageStore.h"

@interface DSPTopStoriesTVC () <UIAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) RKPagination *currentPagination;
@property (nonatomic) RKSubredditCategory currentCategory;
@property (strong, nonatomic) NSArray *links;
@property (strong, nonatomic) dispatch_queue_t linkLoaderQueue;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, getter = isLoadingNewLinks) BOOL loadingNewLinks;
@property (strong, nonatomic) UIActivityIndicatorView *footerActivityIndicator;

@property (strong, nonatomic) DSPTopStoriesTableViewCell *autoLayoutCell;
@property (strong, nonatomic) NSMutableDictionary *rowHeightCache;

@end

@implementation DSPTopStoriesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.autoLayoutCell = [[DSPTopStoriesTableViewCell alloc] initWithReuseIdentifier:nil];
    self.autoLayoutCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.autoLayoutCell.hidden = YES;
    [self.tableView addSubview:self.autoLayoutCell];
    self.autoLayoutCell.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 300);
    
    self.rowHeightCache = [NSMutableDictionary dictionary];
    
    self.linkLoaderQueue = dispatch_queue_create("com.DissociatedPress.newsLoaderQueue", DISPATCH_QUEUE_CONCURRENT);
    
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort  \u25be" style:UIBarButtonItemStylePlain target:self action:@selector(showSortActionSheet)];
    self.navigationItem.rightBarButtonItem = sortButton;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(resetLinks) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.footerActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.footerActivityIndicator.hidesWhenStopped = YES;
    self.tableView.tableFooterView = self.footerActivityIndicator;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationStateDidChange) name:@"authenticationStateDidChange" object:nil];
    
    self.currentCategory = (RKSubredditCategory)1;
    
    [self updateIAPStatus:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIAPStatus:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [self resetLinks];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@ %@",[self class], NSStringFromSelector(_cmd));
    // Dispose of any resources that can be recreated.
    [[DSPImageStore sharedStore] clearImageStore];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    self.rowHeightCache = [NSMutableDictionary dictionary];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)authenticationStateDidChange
{
    [self resetLinks];
}

- (void)resetLinks
{
    [self.refreshControl beginRefreshing];
    
    [self setNavigationTitle];
    
    NSArray *indexPathsToDelete = [self indexPathArrayForRangeFromStart:0 toEnd:self.links.count inSection:0];
    
    self.links = @[];
    self.currentPagination = [RKPagination new];
    self.currentPagination.timeMethod = RKTimeSortingMethodAllTime;
    
    
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self loadNewLinks];
}

- (void)loadNewLinks
{
    self.loadingNewLinks = YES;
    [self.footerActivityIndicator startAnimating];
    
    __weak __typeof(self)weakSelf = self;
    
    [[RKClient sharedClient] linksInSubredditWithName:@"Dissociated_Press" category:self.currentCategory pagination:weakSelf.currentPagination completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
        if (!error)
        {
            [[weakSelf tableView] beginUpdates];
            
            NSArray *indexPaths = [weakSelf indexPathArrayForRangeFromStart:self.links.count toEnd:self.links.count+collection.count inSection:0];
            [[weakSelf tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            
            weakSelf.links = [[weakSelf links] arrayByAddingObjectsFromArray:collection];
            weakSelf.currentPagination = pagination;
            
            [[weakSelf tableView] endUpdates];
            [weakSelf.refreshControl endRefreshing];
            
            weakSelf.loadingNewLinks = NO;
            [self.footerActivityIndicator stopAnimating];
        }
        else
        {
            NSLog(@"Failed to get links, with error: %@", error);
        }
    }];
}

- (void)setNavigationTitle
{
    switch (self.currentCategory) {
        case 1:
            self.navigationItem.title = @"Hot stories";
            break;
        case 2:
            self.navigationItem.title = @"New stories";
            break;
        case 3:
            self.navigationItem.title = @"Rising stories";
            break;
        case 4:
            self.navigationItem.title = @"Controversial stories";
            break;
        case 5:
            self.navigationItem.title = @"Top stories";
            break;
            
            
        default:
            self.navigationItem.title = @"Shared stories";
            break;
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
    return [self.links count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"LinkCell";
    DSPTopStoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[DSPTopStoriesTableViewCell alloc] initWithReuseIdentifier:cellReuseIdentifier];
    cell.delegate = self;
    
    RKLink *link = self.links[indexPath.row];
    
    cell.link = link;
    cell.indexPath = indexPath;
    [cell configureCell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.loadingNewLinks && indexPath.row >= self.links.count - 1) {
        if (self.currentPagination && [self.currentPagination.after length] > 0) {
            [self loadNewLinks];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKLink *link = self.links[indexPath.row];
    NSNumber *cachedHeight = self.rowHeightCache[link.fullName];
    if (cachedHeight != nil) return [cachedHeight floatValue];
    return UITableViewAutomaticDimension;
//    return 106.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKLink *link = self.links[indexPath.row];
    
    NSNumber *cachedHeight = self.rowHeightCache[link.fullName];
    if (cachedHeight != nil) return [cachedHeight floatValue];
    
    self.autoLayoutCell.link = link;
    [self.autoLayoutCell configureCell];
    
    [self.autoLayoutCell updateConstraints];
    [self.autoLayoutCell setNeedsLayout];
    [self.autoLayoutCell layoutIfNeeded];
    
    CGFloat calculatedHeight = [self.autoLayoutCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    self.rowHeightCache[link.fullName] = @(calculatedHeight);
    
    return calculatedHeight;
}

- (void)promptSignIn
{
    UIAlertView *signInAlert = [[UIAlertView alloc] initWithTitle:@"Sign in to reddit?"
                                                          message:@"You need a reddit account to vote."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Sign in", nil];
    [signInAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Sign in to reddit?"]) {
        if (buttonIndex == 1) {
            DSPAuthenticationTVC *authenticationTVC = [[DSPAuthenticationTVC alloc] init];
            [self.navigationController pushViewController:authenticationTVC animated:YES];
        }
    }
}


#pragma mark - DSPTopStoriesDelegate

- (void)didRevokeVoteInCellAtIndexPath:(NSIndexPath *)indexPath
{
    RKLink *link = self.links[indexPath.row];
    
    if ([[RKClient sharedClient] isSignedIn]) {
        [[RKClient sharedClient] revokeVote:link completion:^(NSError *error) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else {
        [self promptSignIn];
    }
}

- (void)didUpvoteInCellAtIndexPath:(NSIndexPath *)indexPath
{
    RKLink *link = self.links[indexPath.row];
    
    if ([[RKClient sharedClient] isSignedIn]) {
        [[RKClient sharedClient] upvote:link completion:^(NSError *error) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else {
        [self promptSignIn];
    }
}

- (void)didDownvoteInCellAtIndexPath:(NSIndexPath *)indexPath
{
    RKLink *link = self.links[indexPath.row];
    
    if ([[RKClient sharedClient] isSignedIn]) {
        [[RKClient sharedClient] downvote:link completion:^(NSError *error) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else {
        [self promptSignIn];
    }
}

- (void)didTouchCellAtIndexPath:(NSIndexPath *)indexPath
{
    RKLink *link = self.links[indexPath.row];
    NSString *permalinkString = [link.permalink absoluteString];
    NSURL *url;
    //    if ([permalinkString containsString:@"i.reddit.com"]) {
    url = [NSURL URLWithString:permalinkString];
    //    } else if ([permalinkString containsString:@"reddit.com"]) {
    //        url = [NSURL URLWithString:[permalinkString stringByReplacingOccurrencesOfString:@"reddit.com" withString:@"i.reddit.com"]];
    //    }
    
    DSPWebViewController *webVC = [[DSPWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - action sheet

- (void)showSortActionSheet
{
    UIActionSheet *sortActionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort by..."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Hot", @"New", @"Rising", @"Controversial", @"Top", nil];
    [sortActionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    RKSubredditCategoryHot = 1,
    //    RKSubredditCategoryNew,
    //    RKSubredditCategoryRising,
    //    RKSubredditCategoryControversial,
    //    RKSubredditCategoryTop
    
    self.currentCategory = (RKSubredditCategory)buttonIndex + 1;
    [self resetLinks];
}

@end


