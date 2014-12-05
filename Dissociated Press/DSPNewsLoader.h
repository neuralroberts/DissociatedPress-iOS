//
//  NewsLoader.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSPNewsLoader : NSObject

- (NSArray *)loadNewsForQuery:(NSString *)query pageNumber:(int)page;

@end
