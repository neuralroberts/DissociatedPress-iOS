//
//  NewsTableViewCell.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/15/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    //    self.image.translatesAutoresizingMaskIntoConstraints = NO;
}

- (instancetype)init
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
    self = [super init];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
 //   NSLog(@"%@",NSStringFromSelector(_cmd));
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.image.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
    self = [super initWithFrame:frame];
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
 //   NSLog(@"%@",NSStringFromSelector(_cmd));
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//        self.cardView = [[UIView alloc] init];
//        
//        [self.contentView addSubview:self.cardView];
//        self.cardView.backgroundColor = [UIColor greenColor];
//        self.image = [[UIImageView alloc] init];
// //       self.image.contentMode = UIViewContentModeScaleAspectFit;
//        [self.cardView addSubview:self.image];
//        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
//        self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
//        self.image.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        NSDictionary *nameMap = @{@"imageView":self.image,
//                                  @"cardView":self.cardView};
//        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[cardView]-16-|"
//                                                                                 options:0
//                                                                                 metrics:nil
//                                                                                   views:nameMap];
//        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[cardView]-|"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:nameMap];
//        [self.contentView addConstraints:horizontalConstraints];
//        [self.contentView addConstraints:verticalConstraints];
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setupCard];
}

- (void)setupCard
{
    [self.cardView setAlpha:1];
    self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.cornerRadius = 1;
    self.cardView.layer.shadowOffset = CGSizeMake(-.2f, -.2f);
    self.cardView.layer.shadowRadius = 1;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cardView.bounds];
    self.cardView.layer.shadowPath = path.CGPath;
    self.cardView.layer.shadowOpacity = 0.2;
}

@end
