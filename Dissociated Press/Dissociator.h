//
//  Dissociator.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//
//

#import <Foundation/Foundation.h>

@interface Dissociator : NSObject

+ (NSArray *)dissociateNewsResults:(NSArray *)associatedResults;
+ (NSString *)dissociateSourceText:(NSString *)sourceText nGramSize:(int)n seedNGram:(NSString *)seedNGram;

@end
