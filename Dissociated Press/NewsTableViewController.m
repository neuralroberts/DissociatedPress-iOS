//
//  NewsTableViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "NewsTableViewController.h"
#import "NewsStory.h"
#import "NewsLoader.h"
#import "DissociatedNewsLoader.h"
#import "SettingsViewController.h"
#import "NewsTableViewCell.h"

@interface NewsTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) UIView *newsHeaderView;
@property (strong, nonatomic) NSMutableArray *searchBars; // array of uisearchbars
@property (strong, nonatomic) NSMutableArray *queries; // array of strings;
@property (strong, nonatomic) UIStepper *headerStepper;

@property (strong, nonatomic) NSMutableArray *newsArray;
@property (strong, nonatomic) DissociatedNewsLoader *newsLoader;
@property (nonatomic) int pageNumber;
@property (strong, nonatomic) dispatch_queue_t newsLoaderQueue;
@property (strong, nonatomic) dispatch_queue_t mainQueue;

@property (strong, nonatomic) NewsTableViewCell *sizingCell;
@end

@implementation NewsTableViewController

#pragma mark - properties

- (UIView *)newsHeaderView
{
    if (!_newsHeaderView) {
        self.queries = [[NSMutableArray alloc] initWithObjects:@"florida man",@"prophecy",@"lagos",@"ebola",@"endangered", nil];
        UIView *newsHeaderView = [[UIView alloc] init];
        _newsHeaderView = newsHeaderView;
    }
    return _newsHeaderView;
}

- (NSMutableArray *)searchBars
{
    if (!_searchBars) {
        NSMutableDictionary *nameMap = [NSMutableDictionary dictionary];
        NSMutableArray *searchBars = [NSMutableArray array];
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
        headerStepper.value = 1;
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
    
    /*
     *create a cell instance to use for autolayout sizing
     */
    self.sizingCell = [[NewsTableViewCell alloc] initWithReuseIdentifier:nil];
    self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sizingCell.hidden = YES;
    [self.tableView addSubview:self.sizingCell];
    self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0);
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSLog(@"%@",self.searchBars);
    
    self.tableView.tableHeaderView = self.newsHeaderView;
    
    //create and configure the parameter control
    UIBarButtonItem *parametersBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(pressedParametersBarButtonItem)];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];
    [parametersBarButtonItem setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = parametersBarButtonItem;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadNews)];
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    self.newsLoaderQueue = dispatch_queue_create("com.DissociatedPress.newsLoaderQueue", DISPATCH_QUEUE_CONCURRENT);
    self.mainQueue = dispatch_get_main_queue();
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger tokenSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"tokenSizeParameter"];
    NSString *dissociateBy = [[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"] ? @"word" : @"character";
    self.navigationItem.title = [NSString stringWithFormat:@"n = %ld, dissociate by %@",(long)tokenSize,dissociateBy];
    [self loadNews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //set datasource to nil for cleaner look during segue
    self.navigationController.title = nil;
    
    NSArray *rangeArray = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
    self.newsArray = nil;
    self.newsLoader = nil;
    [self.tableView deleteRowsAtIndexPaths:rangeArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    //reload data so that cells are layed out properly after rotation
////    [self.tableView reloadData];
////    [self.tableView setNeedsUpdateConstraints];
////    [self.tableView layoutSubviews];
////    [self.tableView beginUpdates];
////    [self.tableView endUpdates];
//}
//

- (void)pressedParametersBarButtonItem
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)loadNews
{
    //reset and populate news array
    dispatch_barrier_async(self.newsLoaderQueue, ^{
        NSLog(@"%@",NSStringFromSelector(_cmd));
        
        dispatch_async(self.mainQueue, ^{
            NSArray *rangeArray = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
            [self.newsArray removeAllObjects];
            [self.tableView deleteRowsAtIndexPaths:rangeArray withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        
        self.pageNumber = 1;
        DissociatedNewsLoader *newsLoader = [[DissociatedNewsLoader alloc] init];
        NSArray *newNews = [newsLoader loadDissociatedNewsForQueries:[self.queries subarrayWithRange:NSMakeRange(0, self.headerStepper.value)] pageNumber:self.pageNumber];
        
        dispatch_async(self.mainQueue, ^{
            self.newsLoader = newsLoader;
            self.newsArray = [newNews mutableCopy];
            NSArray *rangeArray = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
            [self.tableView insertRowsAtIndexPaths:rangeArray withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [self.tableView reloadData];
            NSLog(@"finished loadNews");
        });
    });
}

#pragma mark - UITableViewDataSource
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu",(unsigned long)self.newsArray.count);
    return [self.newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"NewsFeedCell";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) {
        cell = [[NewsTableViewCell alloc] initWithReuseIdentifier:cellReuseIdentifier];
    }
    
    cell.newsStory = [self.newsArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.sizingCell.newsStory = [self.newsArray objectAtIndex:indexPath.row];

    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];
    
    CGFloat calculatedHeight = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return calculatedHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pageNumber < 16) {
        if (indexPath.row >= self.newsArray.count - 1) {
            dispatch_barrier_async(self.newsLoaderQueue, ^{
                NSLog(@"%@, %d",NSStringFromSelector(_cmd), indexPath.row);

                self.pageNumber++;
                NSArray *newNews = [self.newsLoader loadDissociatedNewsForQueries:[self.queries subarrayWithRange:NSMakeRange(0, self.headerStepper.value)] pageNumber:self.pageNumber];

                dispatch_async(self.mainQueue, ^{
                    NSArray *rangeArray = [self indexPathArrayForRangeFromStart:self.newsArray.count toEnd:(self.newsArray.count + newNews.count) inSection:0];

                    [self.newsArray addObjectsFromArray:newNews];

//                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:rangeArray withRowAnimation:UITableViewRowAnimationAutomatic];
//                    [self.tableView endUpdates];
//                    [self.tableView reloadData];
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
