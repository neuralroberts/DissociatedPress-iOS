//
//  NSLayoutConstraint+Priority.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/2/14.
//
//

#import "NSLayoutConstraint+Priority.h"

@implementation NSLayoutConstraint (Priority)

+ (id)constraintWithItem:(id)view1
               attribute:(NSLayoutAttribute)attr1
               relatedBy:(NSLayoutRelation)relation
                  toItem:(id)view2
               attribute:(NSLayoutAttribute)attr2
              multiplier:(CGFloat)multiplier
                constant:(CGFloat)c
                priority:(UILayoutPriority)priority {
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1
                                                                  attribute:attr1
                                                                  relatedBy:relation
                                                                     toItem:view2
                                                                  attribute:attr2
                                                                 multiplier:multiplier
                                                                   constant:c];
    constraint.priority = priority;
    
    return constraint;
}

@end
