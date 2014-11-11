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

+ (NSArray *)dissociateResult:(NSArray *)associatedResult pageNumber:(int)page
{
    //n-gram size
    int n = 3;
    
    //build the source text
    NSString *titleText = @"";
    for (NewsStory *story in associatedResult) {
        titleText = [titleText stringByAppendingString:story.title];
        titleText = [titleText stringByAppendingString:@"\n"];
    }
    
    //collect n-grams from the source text
    NSMutableDictionary *nGramsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *nGrams = [[NSMutableArray alloc] initWithCapacity:[titleText length] - n];
    for (int i = 0; i <= [titleText length] - n; i++) {
        NSString *nGram = [titleText substringWithRange:NSMakeRange(i, n)];
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
    
    
    for (int i = 0; i < [associatedResult count]; i++) {
        BOOL success = NO;
        while (!success) {
            NSString *outString = @"";
            NSUInteger randomIndex = arc4random() % [startingnGrams count];
            NSString *currentToken = startingnGrams[randomIndex];
            
            while (![currentToken containsString:@"\n"] && [outString length] < 210) {
                outString = [outString stringByAppendingString:currentToken];
                randomIndex = arc4random() % [nGramsDictionary[currentToken] count];
                randomIndex = [nGramsDictionary[currentToken][randomIndex] intValue] + n;
                if (randomIndex >= [nGrams count]) {
                    currentToken = [[nGrams lastObject] substringFromIndex:(randomIndex - [nGrams count] + 1)];
                }
                else currentToken = nGrams[randomIndex];
            }
            outString = [outString stringByAppendingString:currentToken];
            
            NSLog(@"\n%@",outString);
            if ([outString length] > 10 && [outString length] < 200) {
                success = YES;
            }
        }
    }
    
    return associatedResult;
}

@end
