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

- (NSMutableArray *)titleNGrams
{
    if (!_titleNGrams) {
        _titleNGrams = [[NSMutableArray alloc] init];
    }
    return _titleNGrams;
}

- (NSMutableDictionary *)titleNGramContext
{
    if (!_titleNGramContext) {
        _titleNGramContext = [[NSMutableDictionary alloc] init];
    }
    return _titleNGramContext;
}

- (NSMutableArray *)contentNGrams
{
    if (!_contentNGrams) {
        _contentNGrams = [[NSMutableArray alloc] init];
    }
    return _contentNGrams;
}

- (NSMutableDictionary *)contentNGramContext
{
    if (!_contentNGramContext) {
        _contentNGramContext = [[NSMutableDictionary alloc] init];
    }
    return _contentNGramContext;
}

- (NSInteger)nGramSize
{
    if (!_nGramSize) {
        _nGramSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"nGramSizeParameter"];
    }
    return _nGramSize;
}

- (NSNumber *)dissociateByWord
{
    if (!_dissociateByWord) {
        _dissociateByWord = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"]];
    }
    return _dissociateByWord;
}

- (NSArray *)loadDissociatedNewsForQuery:(NSString *)query pageNumber:(int)page
{
    NSArray *results = [super loadNewsForQuery:query pageNumber:page];
    
    NSUInteger stringEnumerationOptions = NSStringEnumerationByComposedCharacterSequences;
    NSString *joinString = @"";
    if ([self.dissociateByWord boolValue]) {
        stringEnumerationOptions = NSStringEnumerationByWords;
        joinString = @"";
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
            if (nGram.count == self.nGramSize || [substring rangeOfString:@"\n"].location != NSNotFound) {
                NSString *nGramString = [[nGram componentsJoinedByString:joinString] stringByAppendingString:joinString];
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
            if (nGram.count == self.nGramSize || [substring rangeOfString:@"\n"].location != NSNotFound) {
                NSString *nGramString = [[nGram componentsJoinedByString:joinString] stringByAppendingString:joinString];
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
        story.title = [self dissociateWithSeed:titleSeed nGrams:self.titleNGrams context:self.titleNGramContext];
        
        NSString *contentSeed = contentSeeds[storyHash];
        story.content = [self dissociateWithSeed:contentSeed nGrams:self.contentNGrams context:self.contentNGramContext];

    }
    return results;
}

- (NSString *)dissociateWithSeed:(NSString *)seed nGrams:(NSArray *)nGrams context:(NSDictionary *)context
{
    BOOL success = NO;
    NSString *outString = @"";
    NSUInteger randomIndex;
    while (!success) {
        outString = @"";
        NSString *currentNGram = seed;
        
        while (!([currentNGram rangeOfString:@"\n"].location != NSNotFound)) {
            outString = [outString stringByAppendingString:currentNGram];
            randomIndex = arc4random() % [context[currentNGram] count];
            randomIndex = [context[currentNGram][randomIndex] intValue] + self.nGramSize;
            if (randomIndex >= [nGrams count]) {
                currentNGram = [[nGrams lastObject] substringFromIndex:(randomIndex - [nGrams count] + 1)];
            }
            else currentNGram = nGrams[randomIndex];
        }
        outString = [outString stringByAppendingString:currentNGram];
        
        if ([outString length] > self.nGramSize) {
            success = YES;
        }
    }
    return outString;
}

@end
