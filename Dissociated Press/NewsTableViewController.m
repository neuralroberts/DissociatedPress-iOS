//
//  NewsTableViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//
//

#import "NewsTableViewController.h"

@interface NewsTableViewController () <UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *newsArray;
@property (nonatomic) int pageNumber;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) dispatch_queue_t globalQueue;
@property (strong, nonatomic) dispatch_queue_t mainQueue;

@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //create and configure the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    //create and configure the search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.navigationItem.titleView = self.searchBar;
    
    self.globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.mainQueue = dispatch_get_main_queue();
    
    [self loadNews];
}

- (void)loadNews
{
    //reset and populate news array
    self.pageNumber = 1;
    self.newsArray = [[NSMutableArray alloc] init];
#warning populate news array
}

- (void)refresh
{
    [self loadNews];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"newsFeedCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
    
#warning populate with item from newsarray
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
#warning should segue to detail view
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    if (indexPath.row >= self.newsArray.count - 1) {
        dispatch_async(self.globalQueue, ^{
            self.pageNumber++;
#warning should append next page to newsarray
            dispatch_async(self.mainQueue, ^{
                [self.tableView reloadData];
            });
        });
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self loadNews];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self loadNews];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}



@end
