//
//  NewsTableViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//
#import <RedditKit/RedditKit.h>

#import "DSPNewsTVC.h"
#import "DSPNewsStory.h"
#import "DSPNewsLoader.h"
#import "DSPDissociatedNewsLoader.h"
#import "DSPSettingsVC.h"
#import "DSPNewsHeaderView.h"
#import "DSPSubmitLinkTVC.h"

@interface DSPNewsTVC () <UISearchBarDelegate>

@property (strong, nonatomic) DSPNewsHeaderView *newsHeaderView;
@property (strong, nonatomic) NSMutableArray *queries; // array of strings;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *newsArray;
@property (strong, nonatomic) DSPDissociatedNewsLoader *newsLoader;
@property (nonatomic) int pageNumber;
@property (strong, nonatomic) dispatch_queue_t newsLoaderQueue;

@property (strong, nonatomic) NSMutableDictionary *rowHeightCache;
@property (strong, nonatomic) DSPNewsTableViewCell *sizingCell;

@end

@implementation DSPNewsTVC

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.newsHeaderView = [[DSPNewsHeaderView alloc] init];
    self.newsHeaderView.tableViewController = self;
    
    /*
     *create a cell instance to use for autolayout sizing
     */
    self.sizingCell = [[DSPNewsTableViewCell alloc] initWithReuseIdentifier:nil];
    self.sizingCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sizingCell.hidden = YES;
    [self.tableView addSubview:self.sizingCell];
    self.sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 300);
    
    self.queries = [NSMutableArray array];
    
    self.newsLoaderQueue = dispatch_queue_create("com.DissociatedPress.newsLoaderQueue", DISPATCH_QUEUE_CONCURRENT);
    
    UIBarButtonItem *parametersBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(pressedParametersBarButtonItem)];
    parametersBarButtonItem.tintColor = [UIColor darkGrayColor];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];
    [parametersBarButtonItem setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = parametersBarButtonItem;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadNews)];
    refreshButton.tintColor = [UIColor darkGrayColor];
    self.navigationItem.leftBarButtonItem = refreshButton;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadNews) forControlEvents:UIControlEventValueChanged];
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
    for (int i = 0; i < self.newsHeaderView.stepper.maximumValue; i++) {
        UISearchBar *searchBar = self.newsHeaderView.searchBars[i];
        self.queries[i] = searchBar.text;
    }
    
    //reset and populate news array
    dispatch_barrier_async(self.newsLoaderQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
            NSArray *rangeToDelete = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
            [self.newsArray removeAllObjects];
            [self.tableView deleteRowsAtIndexPaths:rangeToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        
        self.rowHeightCache = [NSMutableDictionary dictionary];
        self.pageNumber = 1;
        DSPDissociatedNewsLoader *newsLoader = [[DSPDissociatedNewsLoader alloc] init];
        NSArray *newNews = [newsLoader loadDissociatedNewsForQueries:[self.queries subarrayWithRange:NSMakeRange(0, self.newsHeaderView.stepper.value)] pageNumber:self.pageNumber];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.newsLoader = newsLoader;
            self.newsArray = [newNews mutableCopy];
            NSArray *rangeToInsert = [self indexPathArrayForRangeFromStart:0 toEnd:self.newsArray.count inSection:0];
            [self.tableView insertRowsAtIndexPaths:rangeToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
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
    DSPNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[DSPNewsTableViewCell alloc] initWithReuseIdentifier:cellReuseIdentifier];
    
    cell.newsStory = [self.newsArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) return self.newsHeaderView;
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 44.0 * self.newsHeaderView.stepper.value;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DSPNewsStory *story = [self.newsArray objectAtIndex:indexPath.row];
    
    NSNumber *cachedHeight = self.rowHeightCache[story.uniqueIdentifier];
    if (cachedHeight != nil) return [cachedHeight floatValue];
    
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

#pragma mark - Delegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self loadNews];
}

- (void)touchedStepper:(UIStepper *)sender
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)pressedParametersBarButtonItem
{
    DSPSettingsVC *settingsVC = [[DSPSettingsVC alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)didClickActionButtonInCellAtIndexPath:(NSIndexPath *)cellIndex
{
    DSPNewsStory *story = self.newsArray[cellIndex.row];
    
    DSPSubmitLinkTVC *submissionVC = [[DSPSubmitLinkTVC alloc] init];
    submissionVC.story = story;
    [self.navigationController pushViewController:submissionVC animated:YES];
}

@end
