//
//  DSPTopStoriesTVC.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/5/14.
//
//

#import "DSPTopStoriesTVC.h"

#import <RedditKit/RedditKit.h>

@interface DSPTopStoriesTVC ()
@property (nonatomic, strong) RKPagination *currentPagination;
@property (strong, nonatomic) NSArray *links;
@property (strong, nonatomic) dispatch_queue_t linkLoaderQueue;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, getter = isLoadingNewLinks) BOOL loadingNewLinks;

@end

@implementation DSPTopStoriesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Top Stories";
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.linkLoaderQueue = dispatch_queue_create("com.DissociatedPress.newsLoaderQueue", DISPATCH_QUEUE_CONCURRENT);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(resetLinks) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self resetLinks];
}

- (void)resetLinks
{
    [self.refreshControl beginRefreshing];
    
    NSArray *indexPathsToDelete = [self indexPathArrayForRangeFromStart:0 toEnd:self.links.count inSection:0];

    self.links = @[];
    self.currentPagination = nil;
    
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self loadNewLinks];
}

- (void)loadNewLinks
{
    self.loadingNewLinks = YES;
    
    __weak __typeof(self)weakSelf = self;
    
    [[RKClient sharedClient] linksInSubredditWithName:@"NewsSalad" pagination:self.currentPagination completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
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
        }
        else
        {
            NSLog(@"Failed to get links, with error: %@", error);
        }
    }];
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
    return [self.links count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellReuseIdentifier = @"LinkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    
    RKLink *link = self.links[indexPath.row];

    cell.textLabel.text = link.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.loadingNewLinks && indexPath.row >= self.links.count - 1) {
        [self loadNewLinks];
    }
}



@end
