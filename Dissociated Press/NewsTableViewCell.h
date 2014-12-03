//
//  NewsTableViewCell.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/15/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsStory.h"

@interface NewsTableViewCell : UITableViewCell

@property (strong, nonatomic) NewsStory *newsStory;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIImageView *thumbnail;
@property (strong, nonatomic) UIView *cardView;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
