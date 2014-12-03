//
//  NSLayoutConstraint+Priority.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/2/14.
//
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Priority)

+ (id)constraintWithItem:(id)view1
               attribute:(NSLayoutAttribute)attr1
               relatedBy:(NSLayoutRelation)relation
                  toItem:(id)view2
               attribute:(NSLayoutAttribute)attr2
              multiplier:(CGFloat)multiplier
                constant:(CGFloat)c
                priority:(UILayoutPriority)priority;

@end
