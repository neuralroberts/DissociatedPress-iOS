//
//  NewsStory.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPNewsStory.h"

@implementation DSPNewsStory

- (void)setDissociatedTitle:(NSString *)dissociatedTitle
{
    _dissociatedTitle = dissociatedTitle;
    
    if ([dissociatedTitle length] > 0) {
        self.displayTitle = dissociatedTitle;
    } else {
        self.displayTitle = self.title;
    }
}

- (void)setDissociatedContent:(NSString *)dissociatedContent
{
    _dissociatedContent = dissociatedContent;
    
    if ([dissociatedContent length] > 0) {
        self.displayContent = dissociatedContent;
    } else {
        self.displayContent = self.content;
    }
}

@end
