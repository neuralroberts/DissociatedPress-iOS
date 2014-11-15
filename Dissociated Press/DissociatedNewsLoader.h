//
//  Dissociator.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//
//

#import <Foundation/Foundation.h>
#import "NewsLoader.h"

@interface DissociatedNewsLoader : NewsLoader

+ (NSArray *)dissociateNewsResults:(NSArray *)associatedResults;
+ (NSString *)dissociateSourceText:(NSString *)sourceText nGramSize:(NSInteger)n seedNGram:(NSString *)seedNGram;
- (NSArray *)loadNewsForQuery:(NSString *)query pageNumber:(int)page;

@end
