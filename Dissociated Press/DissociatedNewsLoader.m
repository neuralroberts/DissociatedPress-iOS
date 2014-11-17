//
//  Dissociator.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//
//

#import "DissociatedNewsLoader.h"
#import "NewsStory.h"

@interface DissociatedNewsLoader ()

@property (strong, nonatomic) NSMutableArray *titleNGrams;
@property (strong, nonatomic) NSMutableDictionary *titleNGramContext;
@property (strong, nonatomic) NSMutableArray *contentNGrams;
@property (strong, nonatomic) NSMutableDictionary *contentNGramContext;

@property (nonatomic) NSInteger nGramSize;
@property (strong, nonatomic) NSNumber *dissociateByWord;
@end

@implementation DissociatedNewsLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleNGrams = [[NSMutableArray alloc] init];
        self.titleNGramContext = [[NSMutableDictionary alloc] init];
        self.contentNGrams = [[NSMutableArray alloc] init];
        self.contentNGramContext = [[NSMutableDictionary alloc] init];
        self.nGramSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"nGramSizeParameter"];
        self.dissociateByWord = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"]];
    }
    return self;
}


- (NSArray *)loadDissociatedNewsForQuery:(NSString *)query pageNumber:(int)page
{
    NSArray *results = [super loadNewsForQuery:query pageNumber:page];
    
    NSUInteger stringEnumerationOptions = NSStringEnumerationByComposedCharacterSequences;
    if ([self.dissociateByWord boolValue]) {
        stringEnumerationOptions = NSStringEnumerationByWords;
    }
    
    NSMutableArray *nGram;
    NSMutableDictionary *titleSeeds = [[NSMutableDictionary alloc] initWithCapacity:results.count];
    NSMutableDictionary *contentSeeds = [[NSMutableDictionary alloc] initWithCapacity:results.count];
    for (NewsStory *story in results) {
        NSNumber *storyHash  = [NSNumber numberWithUnsignedInteger:[story hash]];
        nGram = [[NSMutableArray alloc] init];
        NSString *title = [story.title stringByAppendingString:@"\n"];
        [title enumerateSubstringsInRange:NSMakeRange(0, title.length) options:stringEnumerationOptions usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            substring = [title substringWithRange:enclosingRange];
            [nGram addObject:substring];
            if (nGram.count > self.nGramSize) [nGram removeObjectAtIndex:0];
            if ([substring rangeOfString:@"\n"].location != NSNotFound) {
                while ([nGram count] > 0) {
                    NSString *nGramString = [nGram componentsJoinedByString:@""];
                    if (!titleSeeds[storyHash]) titleSeeds[storyHash] = nGramString;
                    [self.titleNGrams addObject:nGramString];
                    if (!self.titleNGramContext[nGramString]) self.titleNGramContext[nGramString] = [[NSMutableArray alloc] init];
                    [self.titleNGramContext[nGramString] addObject:[NSNumber numberWithInteger:(self.titleNGrams.count - 1)]];
                    [nGram removeObjectAtIndex:0];
                }
            } else if (nGram.count == self.nGramSize) {
                NSString *nGramString = [nGram componentsJoinedByString:@""];
                if (!titleSeeds[storyHash]) titleSeeds[storyHash] = nGramString;
                [self.titleNGrams addObject:nGramString];
                if (!self.titleNGramContext[nGramString]) self.titleNGramContext[nGramString] = [[NSMutableArray alloc] init];
                [self.titleNGramContext[nGramString] addObject:[NSNumber numberWithInteger:(self.titleNGrams.count - 1)]];
            }
        }];
        nGram = [[NSMutableArray alloc] init];
        NSString *content = [story.content stringByAppendingString:@"\n"];
        [content enumerateSubstringsInRange:NSMakeRange(0, content.length) options:stringEnumerationOptions usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            substring = [content substringWithRange:enclosingRange];
            [nGram addObject:substring];
            if (nGram.count > self.nGramSize) [nGram removeObjectAtIndex:0];
            if ([substring rangeOfString:@"\n"].location != NSNotFound) {
                while ([nGram count] > 0) {
                    NSString *nGramString = [nGram componentsJoinedByString:@""];
                    if (!contentSeeds[storyHash]) contentSeeds[storyHash] = nGramString;
                    [self.contentNGrams addObject:nGramString];
                    if (!self.contentNGramContext[nGramString]) self.contentNGramContext[nGramString] = [[NSMutableArray alloc] init];
                    [self.contentNGramContext[nGramString] addObject:[NSNumber numberWithInteger:(self.contentNGrams.count - 1)]];
                    [nGram removeObjectAtIndex:0];
                }
            } else if (nGram.count == self.nGramSize) {
                NSString *nGramString = [nGram componentsJoinedByString:@""];
                if (!contentSeeds[storyHash]) contentSeeds[storyHash] = nGramString;
                [self.contentNGrams addObject:nGramString];
                if (!self.contentNGramContext[nGramString]) self.contentNGramContext[nGramString] = [[NSMutableArray alloc] init];
                [self.contentNGramContext[nGramString] addObject:[NSNumber numberWithInteger:(self.contentNGrams.count - 1)]];
            }
        }];
    }
    
    for (NewsStory *story in results) {
        NSNumber *storyHash = [NSNumber numberWithUnsignedInteger:[story hash]];
        NSString *titleSeed = titleSeeds[storyHash];
        story.title = [self reassociateWithSeed:titleSeed nGrams:self.titleNGrams context:self.titleNGramContext];
        
        NSString *contentSeed = contentSeeds[storyHash];
        story.content = [self reassociateWithSeed:contentSeed nGrams:self.contentNGrams context:self.contentNGramContext];
        
    }
    return results;
}


- (NSString *)reassociateWithSeed:(NSString *)seed nGrams:(NSArray *)nGrams context:(NSDictionary *)context
{
    BOOL success = NO;
    NSString *outString = @"";
    NSUInteger index;
    while (!success) {
        outString = @"";
        NSString *currentNGram = seed;
        
        while ([currentNGram rangeOfString:@"\n"].location == NSNotFound) {
            outString = [outString stringByAppendingString:currentNGram];
            index = arc4random() % [context[currentNGram] count];
            index = [context[currentNGram][index] intValue] + self.nGramSize;
            if (index >= [nGrams count]) {
                currentNGram = @"\n";
            }
            else currentNGram = nGrams[index];
        }
        outString = [outString stringByAppendingString:currentNGram];
        
        if ([outString length] > self.nGramSize) {
            success = YES;
        }
    }
    return outString;
}

@end
