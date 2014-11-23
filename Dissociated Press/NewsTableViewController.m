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

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIView *newsHeaderView;
@property (strong, nonatomic) NSMutableArray *searchBars; // array of uisearchbars
@property (strong, nonatomic) NSMutableArray *queries; // array of strings;
@property (strong, nonatomic) UIStepper *headerStepper;

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

- (UIView *)newsHeaderView
{
    if (!_newsHeaderView) {
        self.queries = [[NSMutableArray alloc] initWithObjects:@"florida man",@"prophecy",@"lagos",@"piracy",@"endangered", nil];
        UIView *newsHeaderView = [[UIView alloc] init];
        _newsHeaderView = newsHeaderView;
    }
    return _newsHeaderView;
}

- (NSMutableArray *)searchBars
{
    if (!_searchBars) {
        NSMutableDictionary *nameMap = [[NSMutableDictionary alloc] init];
        NSMutableArray *searchBars = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            [self.newsHeaderView addSubview:searchBar];
            [searchBars addObject:searchBar];
            searchBar.delegate = self;
            [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
            [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            searchBar.placeholder = [NSString stringWithFormat:@"Query %lu",(unsigned long)searchBars.count];
            if ([self.queries[i] length] > 0) {
                searchBar.text = self.queries[i];
            }
            searchBar.translatesAutoresizingMaskIntoConstraints = NO;
            [searchBar setContentCompressionResistancePriority:(UILayoutPriorityDefaultHigh - i) forAxis:UILayoutConstraintAxisVertical];
            [nameMap setObject:searchBar forKey:[NSString stringWithFormat:@"searchBar%d",i]];
        }
        NSMutableString *verticalConstraintsString = [[NSMutableString alloc] initWithString:@"V:|"];
        for (int i = 0; i < searchBars.count; i++) {
            NSString *horizontalConstraintsString = [NSString stringWithFormat:@"H:|-110.0-[searchBar%d]|",i];
            NSArray *horizontalContraints = [NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraintsString
                                                                                    options:0 metrics:nil views:nameMap];
            
            [self.newsHeaderView addConstraints:horizontalContraints];
            [verticalConstraintsString appendString:[NSString stringWithFormat:@"[searchBar%d]",i]];
            
        }
        [verticalConstraintsString appendString:@"|"];
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalConstraintsString
                                                                               options:0 metrics:nil views:nameMap];
        [self.newsHeaderView addConstraints:verticalConstraints];
        
        UIStepper *headerStepper = [[UIStepper alloc] initWithFrame:CGRectMake(_newsHeaderView.frame.origin.x,
                                                                               _newsHeaderView.frame.origin.y,
                                                                               94.0, 29.0)];
        headerStepper.translatesAutoresizingMaskIntoConstraints = NO;
        headerStepper.minimumValue = 1;
        headerStepper.maximumValue = 5;
        [headerStepper addTarget:self action:@selector(touchedStepper:) forControlEvents:UIControlEventValueChanged];
        [self.newsHeaderView addSubview:headerStepper];
        headerStepper.value = 2;
        self.headerStepper = headerStepper;
        self.newsHeaderView.frame = CGRectMake(self.newsHeaderView.frame.origin.x,
                                               self.newsHeaderView.frame.origin.y,
                                               self.newsHeaderView.frame.size.width,
                                               44.0 * headerStepper.value);
        
        [nameMap setObject:headerStepper forKey:@"headerStepper"];
        NSArray *stepperHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[headerStepper]-8-[searchBar0]|"
                                                                                        options:0 metrics:nil views:nameMap];
        NSArray *stepperVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[headerStepper]"
                                                                                      options:0 metrics:nil views:nameMap];
        [self.newsHeaderView addConstraints:stepperHorizontalConstraints];
        [self.newsHeaderView addConstraints:stepperVerticalConstraints];
        _searchBars = searchBars;
    }
    return _searchBars;
}

- (void)touchedStepper:(UIStepper *)sender
{
    self.newsHeaderView.frame = CGRectMake(self.newsHeaderView.frame.origin.x,
                                           self.newsHeaderView.frame.origin.y,
                                           self.newsHeaderView.frame.size.width,
                                           44.0 * sender.value);
    
    self.tableView.tableHeaderView = self.newsHeaderView;
    
    [self.newsHeaderView layoutSubviews];
    [self loadNews];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",self.searchBars);
    
    self.tableView.tableHeaderView = self.newsHeaderView;
    
        [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsFeedCell"];
 //   [self.tableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:@"NewsFeedCell"];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView addSubview:self.refreshControl];
    self.navigationItem.title = @"Dissociated Press";
    
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView reloadData];
}


- (void)pressedParametersBarButtonItem
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)loadNews
{
    [self.refreshControl beginRefreshing];
    
    dispatch_async(self.globalQueue, ^{
        //reset and populate news array
        self.pageNumber = 1;
        self.newsLoader = [[DissociatedNewsLoader alloc] init];
//        self.newsArray = [[NSMutableArray alloc] init];
        
        self.newsArray = [[self.newsLoader loadDissociatedNewsForQueries:[self.queries subarrayWithRange:NSMakeRange(0, self.headerStepper.value)] pageNumber:self.pageNumber] mutableCopy];
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
    
    cell.titleLabel.text = [story.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.titleLabel.numberOfLines = 0;
    cell.contentLabel.text = [story.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.contentLabel.numberOfLines = 8;
    
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
    } else {
        cell.image.image = nil;
        cell.image.frame = CGRectMake(0, 0, 0, 0);
    }
    [cell layoutSubviews];
    return cell;
}


#pragma mark - UITableViewDelegate
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 300.0;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 160;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = (NewsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.contentLabel.numberOfLines = 0;
    [tableView beginUpdates];
    [tableView endUpdates];
//    [self.tableView layoutSubviews];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = (NewsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.contentLabel.numberOfLines = 2;
    [tableView beginUpdates];
    [tableView endUpdates];
//    [self.tableView layoutSubviews];
 //   [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pageNumber < 16) {
        if (indexPath.row >= self.newsArray.count - 1) {
            dispatch_async(self.globalQueue, ^{
                
                self.pageNumber++;
                [self.newsArray addObjectsFromArray:[self.newsLoader loadDissociatedNewsForQueries:[self.queries subarrayWithRange:NSMakeRange(0, self.headerStepper.value)] pageNumber:self.pageNumber]];
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
    for (int i = 0; i < 5; i++) {
        UISearchBar *searchBar = self.searchBars[i];
        self.queries[i] = searchBar.text;
    }
    [self loadNews];
}

@end
