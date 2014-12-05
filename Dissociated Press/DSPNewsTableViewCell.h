//
//  NewsTableViewCell.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/15/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPNewsStory.h"
#import "DSPNewsLabel.h"

@interface DSPNewsTableViewCell : UITableViewCell

@property (strong, nonatomic) DSPNewsStory *newsStory;
@property (strong, nonatomic) DSPNewsLabel *titleLabel;
@property (strong, nonatomic) DSPNewsLabel *dateLabel;
@property (strong, nonatomic) DSPNewsLabel *contentLabel;
@property (strong, nonatomic) UIImageView *thumbnail;
@property (strong, nonatomic) UIView *cardView;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
