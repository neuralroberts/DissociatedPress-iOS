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
    int n = 2;
    
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
        //get the first n letters of the current title to seed the dissociation
        NSString *seedNGram = [story.title substringWithRange:NSMakeRange(0, n)];
        story.title = [Dissociator dissociateSourceText:titleSourceText nGramSize:n seedNGram:seedNGram];
        
        seedNGram = [story.content substringWithRange:NSMakeRange(0, n)];
        story.content = [Dissociator dissociateSourceText:bodySourceText nGramSize:n seedNGram:seedNGram];
    }
    
    return dissociatedResults;
}

+ (NSString *)dissociateSourceText:(NSString *)sourceText nGramSize:(int)n seedNGram:(NSString *)seedNGram
{
    //collect n-grams from the source text
    NSMutableDictionary *nGramsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *nGrams = [[NSMutableArray alloc] initWithCapacity:[sourceText length] - n];
    for (int i = 0; i <= [sourceText length] - n; i++) {
        NSString *nGram = [sourceText substringWithRange:NSMakeRange(i, n)];
#warning NSString category for containsString
        if ([nGram rangeOfString:@"\n"].location != NSNotFound) nGram = [[[nGram componentsSeparatedByString:@"\n"] firstObject] stringByAppendingString:@"\n"];
        [nGrams addObject:nGram];
        if (!nGramsDictionary[nGram]) nGramsDictionary[nGram] = [[NSMutableArray alloc] init];
        [nGramsDictionary[nGram] addObject:[NSNumber numberWithInt:i]];
    }
    
    BOOL success = NO;
    NSString *outString = @"";
    NSUInteger randomIndex;
    while (!success) {
        outString = @"";
        NSString *currentNGram = seedNGram;
        
        while (!([currentNGram rangeOfString:@"\n"].location != NSNotFound) && [outString length] < 16000) {
            outString = [outString stringByAppendingString:currentNGram];
            randomIndex = arc4random() % [nGramsDictionary[currentNGram] count];
            randomIndex = [nGramsDictionary[currentNGram][randomIndex] intValue] + n;
            if (randomIndex >= [nGrams count]) {
                currentNGram = [[nGrams lastObject] substringFromIndex:(randomIndex - [nGrams count] + 1)];
            }
            else currentNGram = nGrams[randomIndex];
        }
        outString = [outString stringByAppendingString:currentNGram];
        
        NSLog(@"\n%@, %lu",outString, (unsigned long)[outString length]);
        if ([outString length] > n && [outString length] < 150000) {
            success = YES;
        }
    }
    return outString;
}


@end
