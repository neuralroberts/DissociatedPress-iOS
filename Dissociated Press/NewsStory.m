//
//  NewsStory.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//
//

#import "NewsStory.h"

@implementation NewsStory
- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    _attributedTitle = attributedTitle;
    self.title = attributedTitle.string;
}

- (void)setAttributedContent:(NSAttributedString *)attributedContent
{
    _attributedContent = attributedContent;
    self.content = attributedContent.string;
}

@end
