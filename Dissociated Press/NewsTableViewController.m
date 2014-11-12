//
//  NewsTableViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//
//

#import "NewsTableViewController.h"
#import "NewsStory.h"
#import "NewsLoader.h"
#import "Dissociator.h"

@interface NewsTableViewController () <UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSMutableArray *associatedNewsArray;
@property (strong, nonatomic) NSMutableArray *dissociatedNewsArray;
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
    self.query = @"florida man";
    self.searchBar.text = self.query;
    self.navigationItem.titleView = self.searchBar;
    
    self.globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.mainQueue = dispatch_get_main_queue();
    
    [self loadNews];
}

- (void)loadNews
{
    //reset and populate news array
    self.pageNumber = 1;
    
    self.associatedNewsArray = [[NSMutableArray alloc] init];
    self.dissociatedNewsArray = [[NSMutableArray alloc] init];
    
    [self.associatedNewsArray addObjectsFromArray:[NewsLoader loadNewsForQuery:self.query pageNumber:self.pageNumber]];
    [self.dissociatedNewsArray addObjectsFromArray:[Dissociator dissociateNewsResults:self.associatedNewsArray]];
    [self.tableView reloadData];
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
    return [self.dissociatedNewsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"newsFeedCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
    
    NewsStory *story = [self.dissociatedNewsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = story.title;
    cell.textLabel.numberOfLines = 3;
    cell.detailTextLabel.text = story.content;
    cell.detailTextLabel.numberOfLines = 5;
    
    if (story.imageUrl) {
        dispatch_async(self.globalQueue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:story.imageUrl];
            
            dispatch_async(self.mainQueue, ^{
                cell.imageView.image = [[UIImage alloc] initWithData:imageData];
                [cell layoutSubviews];
            });
        });
    } else cell.imageView.image = nil;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning should segue to detail view
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.dissociatedNewsArray.count - 1) {
        dispatch_async(self.globalQueue, ^{
            self.pageNumber++;
            [self.associatedNewsArray addObjectsFromArray:[NewsLoader loadNewsForQuery:self.query pageNumber:self.pageNumber]];
            [self.dissociatedNewsArray addObjectsFromArray:[Dissociator dissociateNewsResults:self.associatedNewsArray]];
            dispatch_async(self.mainQueue, ^{
                [self.tableView reloadData];
            });
        });
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    [self loadNews];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [searchBar resignFirstResponder];
    self.query = self.searchBar.text;
    [self loadNews];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}



@end
