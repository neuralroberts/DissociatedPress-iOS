//
//  NewsLabel.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/3/14.
//
//

#import "DSPLabel.h"

@implementation DSPLabel

- (id)init {
    self = [super init];
    
    // required to prevent Auto Layout from compressing the label (by 1 point usually) for certain constraint solutions
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisVertical];
    
    return self;
}

- (void)layoutSubviews {
//    NSLog(@"%@",self.text);
//    NSLog(@"%@",NSStringFromCGSize(self.intrinsicContentSize));
    [super layoutSubviews];

//    NSLog(@"%f, %f",self.bounds.size.width, self.frame.size.width);
    self.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
//    NSLog(@"%@",NSStringFromCGSize(self.intrinsicContentSize));

    [super layoutSubviews];
//    NSLog(@"%@\n\n\n",NSStringFromCGSize(self.intrinsicContentSize));
}


@end
