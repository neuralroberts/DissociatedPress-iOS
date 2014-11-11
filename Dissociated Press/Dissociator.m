//
//  Dissociator.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//
//

#import "Dissociator.h"
#import "NewsStory.h"

@implementation Dissociator

+ (NSArray *)dissociateNewsResults:(NSArray *)associatedResults
{
    NSMutableArray *dissociatedResults = [[associatedResults subarrayWithRange:NSMakeRange(associatedResults.count - 4, 4)] mutableCopy];
    
    //n-gram size
    int n = 4;
    
    //build the source text
    NSString *titleSourceText = @"";
    NSString *bodySourceText = @"";
    for (NewsStory *story in associatedResults) {
        titleSourceText = [titleSourceText stringByAppendingString:story.title];
        titleSourceText = [titleSourceText stringByAppendingString:@"\n"];
        bodySourceText = [bodySourceText stringByAppendingString:story.content];
        bodySourceText = [bodySourceText stringByAppendingString:@"\n"];
    }
    
    for (NewsStory *story in dissociatedResults) {
        story.title = [Dissociator dissociateSourceText:titleSourceText nGramSize:n];
        story.content = [Dissociator dissociateSourceText:bodySourceText nGramSize:n];
    }
    
    return dissociatedResults;
}

+ (NSString *)dissociateSourceText:(NSString *)sourceText nGramSize:(int)n
{
    //collect n-grams from the source text
    NSMutableDictionary *nGramsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *nGrams = [[NSMutableArray alloc] initWithCapacity:[sourceText length] - n];
    for (int i = 0; i <= [sourceText length] - n; i++) {
        NSString *nGram = [sourceText substringWithRange:NSMakeRange(i, n)];
        if ([nGram containsString:@"\n"]) nGram = [[[nGram componentsSeparatedByString:@"\n"] firstObject] stringByAppendingString:@"\n"];
        [nGrams addObject:nGram];
        if (!nGramsDictionary[nGram]) nGramsDictionary[nGram] = [[NSMutableArray alloc] init];
        [nGramsDictionary[nGram] addObject:[NSNumber numberWithInt:i]];
    }
    
    //build filtered array of ngrams with first letter capitalized
    NSIndexSet *indexSet = [nGrams indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[obj characterAtIndex:0]];
    }];
    NSArray *startingnGrams = [nGrams objectsAtIndexes:indexSet];
    
    
    BOOL success = NO;
    NSString *outString = @"";
    while (!success) {
        outString = @"";
        NSUInteger randomIndex = arc4random() % [startingnGrams count];
        NSString *currentToken = startingnGrams[randomIndex];
        
        while (![currentToken containsString:@"\n"] && [outString length] < 16000) {
            outString = [outString stringByAppendingString:currentToken];
            randomIndex = arc4random() % [nGramsDictionary[currentToken] count];
            randomIndex = [nGramsDictionary[currentToken][randomIndex] intValue] + n;
            if (randomIndex >= [nGrams count]) {
                currentToken = [[nGrams lastObject] substringFromIndex:(randomIndex - [nGrams count] + 1)];
            }
            else currentToken = nGrams[randomIndex];
        }
        outString = [outString stringByAppendingString:currentToken];
        
        NSLog(@"\n%@, %lu",outString, (unsigned long)[outString length]);
        if ([outString length] > n && [outString length] < 150000) {
            success = YES;
        }
    }
    return outString;
}


@end
