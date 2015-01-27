//
//  DSPTopicsTVCTableViewController.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/16/14.
//
//

#import "DSPTopicsTVC.h"

@interface DSPTopicsTVC ()

@end

@implementation DSPTopicsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"topicsCell"];
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.topics = @[@"Headlines", @"World", @"Business", @"Nation", @"Technology", @"Elections", @"Politics", @"Entertainment", @"Sports", @"Health"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@ %@",[self class], NSStringFromSelector(_cmd));
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissTopicsTVC)]) {
        [self.delegate didDismissTopicsTVC];
    }
}

- (CGFloat)tableViewHeight
{
    float currentTotal = 0;
    
    //Need to total each section
    for (int i = 0; i < [self.tableView numberOfSections]; i++)
    {
        CGRect sectionRect = [self.tableView rectForSection:i];
        currentTotal += sectionRect.size.height;
    }
    
    return currentTotal;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.topics count];
            break;
        case 1:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicsCell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topicsCell"];
    
    //    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //    cell.contentView.layer.cornerRadius = 5;
    //    cell.contentView.layer.masksToBounds = YES;
    //    cell.contentView.layer.borderWidth = 0.3;
    //    cell.contentView.layer.borderColor = [UIColor grayColor].CGColor;
    //    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 3;
    cell.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0) {
        
        NSString *topic = self.topics[indexPath.row];
        cell.textLabel.text = topic;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if ([self.selectedTopics containsObject:topic]) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else {
        cell.textLabel.text = @"Cancel";
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissTopicsTVC)]) {
                [self.delegate didDismissTopicsTVC];
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        NSString *topic = self.topics[indexPath.row];
        [self.selectedTopics addObject:topic];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *topic = self.topics[indexPath.row];
    [self.selectedTopics removeObject:topic];
}


@end
