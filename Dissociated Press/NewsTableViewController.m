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
#import "DPNewsHeaderView.h"

@interface NewsTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) DPNewsHeaderView *newsHeaderView;
@property (strong, nonatomic) NSMutableArray *queries; // array of strings;

@property (strong, nonatomic) NSMutableArray *newsArray;
@property (strong, nonatomic) DissociatedNewsLoader *newsLoader;
@property (nonatomic) int pageNumber;
@property (strong, nonatomic) dispatch_queue_t newsLoaderQueue;

@property (strong, nonatomic) NSMutableDictionary *rowHeightCache;
@property (strong, nonatomic) NewsTableViewCell *sizingCell;
@end

@implementation NewsTableViewController

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.newsHeaderView = [[DPNewsHeaderView alloc] init];
    self.newsHeaderView.tableViewController = self;
    self.tableView.tableHeaderView = self.newsHeaderView;
    
    /*
     *create a cell instance to use for autolayout sizing
     */
    self.sizingCell = [[NewsTableViewCell alloc] initWithReuseIdentifier:nil];
    self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sizingCell.hidden = YES;
    [self.tableView addSubview:self.sizingCell];
    self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0);
    
    self.queries = [NSMutableArray array];
    
    //create and configure the parameter control
    UIBarButtonItem *parametersBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(pressedParametersBarButtonItem)];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];
    [parametersBarButtonItem setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = parametersBarButtonItem;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadNews)];
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    self.newsLoaderQueue = dispatch_queue_create("com.DissociatedPress.newsLoaderQueue", DISPATCH_QUEUE_CONCURRENT);
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
    NSArray *rangeToDelete = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
    self.newsArray = nil;
    self.newsLoader = nil;
    [self.tableView deleteRowsAtIndexPaths:rangeToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)loadNews
{
    for (int i = 0; i < 5; i++) {
        UISearchBar *searchBar = self.newsHeaderView.searchBars[i];
        self.queries[i] = searchBar.text;
    }
    
    //reset and populate news array
    dispatch_barrier_async(self.newsLoaderQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *rangeToDelete = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
            [self.newsArray removeAllObjects];
            [self.tableView deleteRowsAtIndexPaths:rangeToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        
        self.rowHeightCache = [NSMutableDictionary dictionary];
        self.pageNumber = 1;
        DissociatedNewsLoader *newsLoader = [[DissociatedNewsLoader alloc] init];
        NSArray *newNews = [newsLoader loadDissociatedNewsForQueries:[self.queries subarrayWithRange:NSMakeRange(0, self.newsHeaderView.stepper.value)] pageNumber:self.pageNumber];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.newsLoader = newsLoader;
            self.newsArray = [newNews mutableCopy];
            NSArray *rangeToInsert = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
            [self.tableView insertRowsAtIndexPaths:rangeToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return [self.newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"NewsFeedCell";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[NewsTableViewCell alloc] initWithReuseIdentifier:cellReuseIdentifier];
    
    cell.newsStory = [self.newsArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsStory *story = [self.newsArray objectAtIndex:indexPath.row];
    
    NSNumber *cachedHeight = self.rowHeightCache[story.uniqueIdentifier];
    
    if (cachedHeight != nil) {
        return [cachedHeight floatValue];
    }
    
    self.sizingCell.newsStory = story;
    
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];
    
    CGFloat calculatedHeight = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    self.rowHeightCache[story.uniqueIdentifier] = @(calculatedHeight);
    
    return calculatedHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pageNumber < 16) {
        if (indexPath.row >= self.newsArray.count - 1) {
            dispatch_barrier_async(self.newsLoaderQueue, ^{
                self.pageNumber++;
                NSArray *newNews = [self.newsLoader loadDissociatedNewsForQueries:[self.queries subarrayWithRange:NSMakeRange(0, self.newsHeaderView.stepper.value)] pageNumber:self.pageNumber];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *rangeToInsert = [self indexPathArrayForRangeFromStart:self.newsArray.count toEnd:(self.newsArray.count + newNews.count) inSection:0];
                    [self.newsArray addObjectsFromArray:newNews];
                    [self.tableView insertRowsAtIndexPaths:rangeToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            });
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self loadNews];
}

- (void)touchedStepper:(UIStepper *)sender
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    NSLog(@"%@",self.newsHeaderView.tableViewController);
    self.newsHeaderView.frame = CGRectMake(self.newsHeaderView.frame.origin.x,
                                           self.newsHeaderView.frame.origin.y,
                                           self.newsHeaderView.frame.size.width,
                                           44.0 * sender.value);
    
    self.tableView.tableHeaderView = self.newsHeaderView;
    
    [self.newsHeaderView setNeedsUpdateConstraints];
    [self.newsHeaderView setNeedsLayout];
    
    [self loadNews];
}

- (void)pressedParametersBarButtonItem
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

@end
