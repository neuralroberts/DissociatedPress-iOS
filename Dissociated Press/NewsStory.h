//
//  NewsStory.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NewsStory : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSURL* url;
@property (nonatomic, assign) BOOL hasThumbnail;
@property (strong, nonatomic) NSURL* imageUrl;
@property (readwrite) CGFloat imageWidth;
@property (readwrite) CGFloat imageHeight;
@property (strong, nonatomic) NSUUID *uniqueIdentifier;
@end
