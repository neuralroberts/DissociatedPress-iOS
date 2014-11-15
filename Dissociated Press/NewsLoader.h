//
//  NewsLoader.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//
//

#import <Foundation/Foundation.h>

@interface NewsLoader : NSObject

- (NSArray *)loadNewsForQuery:(NSString *)query pageNumber:(int)page;

@end
