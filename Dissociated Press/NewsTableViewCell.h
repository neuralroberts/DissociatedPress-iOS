//
//  NewsTableViewCell.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/15/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsStory.h"
#import "NewsLabel.h"

@interface NewsTableViewCell : UITableViewCell

@property (strong, nonatomic) NewsStory *newsStory;
@property (strong, nonatomic) NewsLabel *titleLabel;
@property (strong, nonatomic) NewsLabel *dateLabel;
@property (strong, nonatomic) NewsLabel *contentLabel;
@property (strong, nonatomic) UIImageView *thumbnail;
@property (strong, nonatomic) UIView *cardView;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
