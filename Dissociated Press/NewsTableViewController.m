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
#import "DissociatedNewsLoader.h"
#import "SettingsViewController.h"
#import "NewsTableViewCell.h"

@interface NewsTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSMutableArray *newsArray;
@property (strong, nonatomic) DissociatedNewsLoader *newsLoader;
@property (nonatomic) int pageNumber;
@property (strong, nonatomic) dispatch_queue_t globalQueue;
@property (strong, nonatomic) dispatch_queue_t mainQueue;

@end

@implementation NewsTableViewController

@synthesize refreshControl = _refreshControl;

#pragma mark - properties

- (UIRefreshControl *)refreshControl
{
    if (!_refreshControl) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(loadNews) forControlEvents:UIControlEventValueChanged];
        _refreshControl = refreshControl;
    }
    return _refreshControl;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        searchBar.text = self.query;
        _searchBar = searchBar;
    }
    return _searchBar;
}


#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsFeedCell"];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.query = @"florida man";
    [self.tableView addSubview:self.refreshControl];
    self.navigationItem.titleView = self.searchBar;
    
    //create and configure the parameter control
    UIBarButtonItem *parametersBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(pressedParametersBarButtonItem)];
    self.navigationItem.rightBarButtonItem = parametersBarButtonItem;
    
    self.globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.mainQueue = dispatch_get_main_queue();
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadNews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressedParametersBarButtonItem
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)loadNews
{
    [self.refreshControl beginRefreshing];
    
    //reset and populate news array
    self.pageNumber = 1;
    self.newsLoader = [[DissociatedNewsLoader alloc] init];
    self.newsArray = [[NSMutableArray alloc] init];
    
    dispatch_async(self.globalQueue, ^{
        [self.newsArray addObjectsFromArray:[self.newsLoader loadDissociatedNewsForQuery:self.query pageNumber:self.pageNumber]];
        dispatch_async(self.mainQueue, ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"NewsFeedCell";
    NewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    NewsStory *story = [self.newsArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = story.title;
    cell.titleLabel.numberOfLines = 2;
    cell.contentLabel.text = story.content;
    cell.contentLabel.numberOfLines = 2;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:story.date]];
    
    if (story.imageUrl) {
        dispatch_async(self.globalQueue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:story.imageUrl];
            
            dispatch_async(self.mainQueue, ^{
                cell.image.image = [[UIImage alloc] initWithData:imageData];
                [cell layoutSubviews];
            });
        });
    } else cell.image.image = nil;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pageNumber < 16) {
        if (indexPath.row >= self.newsArray.count - 1) {
            dispatch_async(self.globalQueue, ^{
                
                self.pageNumber++;
                [self.newsArray addObjectsFromArray:[self.newsLoader loadDissociatedNewsForQuery:self.query pageNumber:self.pageNumber]];
                dispatch_async(self.mainQueue, ^{
                    [self.tableView reloadData];
                });
            });
        }
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.query = self.searchBar.text;
    [self loadNews];
}

@end
