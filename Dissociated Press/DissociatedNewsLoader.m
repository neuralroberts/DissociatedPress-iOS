//
//  Dissociator.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//
//

#import "DissociatedNewsLoader.h"
#import "NewsStory.h"

@implementation DissociatedNewsLoader

- (NSArray *)loadNewsForQuery:(NSString *)query pageNumber:(int)page
{
    return [super loadNewsForQuery:query pageNumber:page];
}

+ (NSArray *)dissociateNewsResults:(NSArray *)associatedResults
{
    NSMutableArray *dissociatedResults = [[associatedResults subarrayWithRange:NSMakeRange(associatedResults.count - 4, 4)] mutableCopy];
    
    //n-gram size
    NSInteger n = [[NSUserDefaults standardUserDefaults] integerForKey:@"nGramSizeParameter"];
    BOOL dissociateByWord = [[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"];
    
    //build the source text
    NSString *titleSourceText = @"";
    NSString *bodySourceText = @"";
    for (NewsStory *story in associatedResults) {
        titleSourceText = [titleSourceText stringByAppendingString:story.title];
        titleSourceText = [titleSourceText stringByAppendingString:@"\n "];
        
        bodySourceText = [bodySourceText stringByAppendingString:story.content];
        bodySourceText = [bodySourceText stringByAppendingString:@"\n "];
    }
    
    for (NewsStory *story in dissociatedResults) {
        //get the first n letters of the current title to seed the dissociation
        NSString *seedNGram = [story.title substringWithRange:NSMakeRange(0, n)];
        if (dissociateByWord) seedNGram = [[[story.title componentsSeparatedByString:@" "] subarrayWithRange:NSMakeRange(0, n)] componentsJoinedByString:@" "];
        story.title = [DissociatedNewsLoader dissociateSourceText:titleSourceText nGramSize:n seedNGram:seedNGram];
        
        seedNGram = [story.content substringWithRange:NSMakeRange(0, n)];
        if (dissociateByWord) seedNGram = [[[story.content componentsSeparatedByString:@" "] subarrayWithRange:NSMakeRange(0, n)] componentsJoinedByString:@" "];
        story.content = [DissociatedNewsLoader dissociateSourceText:bodySourceText nGramSize:n seedNGram:seedNGram];
    }
    
    return dissociatedResults;
}

+ (NSString *)dissociateSourceText:(NSString *)sourceText nGramSize:(NSInteger)n seedNGram:(NSString *)seedNGram
{
    BOOL dissociateByWord = [[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"];
    //collect n-grams from the source text
    NSMutableDictionary *nGramsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *nGrams = [[NSMutableArray alloc] init];
    if (dissociateByWord) {
        NSArray *sourceTextArray = [sourceText componentsSeparatedByString:@" "];
        for (int i = 0; i < [sourceTextArray count] - n; i++) {
            NSString *nGram = [[sourceTextArray subarrayWithRange:NSMakeRange(i, n)] componentsJoinedByString:@" "];
            if ([nGram rangeOfString:@"\n"].location != NSNotFound) nGram = [[[nGram componentsSeparatedByString:@"\n"] firstObject] stringByAppendingString:@"\n"];
            [nGrams addObject:nGram];
            if (!nGramsDictionary[nGram]) nGramsDictionary[nGram] = [[NSMutableArray alloc] init];
            [nGramsDictionary[nGram] addObject:[NSNumber numberWithInt:i]];
        }
    } else {
        for (int i = 0; i <= [sourceText length] - n; i++) {
            NSString *nGram = [sourceText substringWithRange:NSMakeRange(i, n)];
#warning NSString category for containsString
            if ([nGram rangeOfString:@"\n"].location != NSNotFound) nGram = [[[nGram componentsSeparatedByString:@"\n"] firstObject] stringByAppendingString:@"\n"];
            [nGrams addObject:nGram];
            if (!nGramsDictionary[nGram]) nGramsDictionary[nGram] = [[NSMutableArray alloc] init];
            [nGramsDictionary[nGram] addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    BOOL success = NO;
    NSString *outString = @"";
    NSUInteger randomIndex;
    while (!success) {
        outString = @"";
        NSString *currentNGram = seedNGram;
        
        while (!([currentNGram rangeOfString:@"\n"].location != NSNotFound) && [outString length] < 16000) {
            if (dissociateByWord) outString = [outString stringByAppendingString:[@" " stringByAppendingString:currentNGram]];
            else outString = [outString stringByAppendingString:currentNGram];
            randomIndex = arc4random() % [nGramsDictionary[currentNGram] count];
            randomIndex = [nGramsDictionary[currentNGram][randomIndex] intValue] + n;
            if (randomIndex >= [nGrams count]) {
                currentNGram = [[nGrams lastObject] substringFromIndex:(randomIndex - [nGrams count] + 1)];
            }
            else currentNGram = nGrams[randomIndex];
        }
        outString = [outString stringByAppendingString:currentNGram];
        
        //        NSLog(@"\n%@, %lu",outString, (unsigned long)[outString length]);
        if ([outString length] > n && [outString length] < 150000) {
            success = YES;
        }
    }
    return outString;
}


@end
