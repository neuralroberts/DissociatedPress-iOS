//
//  Dissociator.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPDissociatedNewsLoader.h"

@interface DSPDissociatedNewsLoader ()

@property (strong, nonatomic) NSMutableArray *titleTokens;
@property (strong, nonatomic) NSMutableDictionary *titleTokenContext;
@property (strong, nonatomic) NSMutableDictionary *titleSourceText;
@property (strong, nonatomic) NSMutableArray *contentTokens;
@property (strong, nonatomic) NSMutableDictionary *contentTokenContext;
@property (strong, nonatomic) NSMutableDictionary *contentSourceText;

@property (nonatomic) NSInteger tokenSize;
@property (strong, nonatomic) NSNumber *dissociateByWord;
@end

@implementation DSPDissociatedNewsLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleTokens = [NSMutableArray array];
        self.titleTokenContext = [NSMutableDictionary dictionary];
        self.titleSourceText = [NSMutableDictionary dictionary];
        self.contentTokens = [NSMutableArray array];
        self.contentTokenContext = [NSMutableDictionary dictionary];
        self.contentSourceText = [NSMutableDictionary dictionary];
        self.tokenSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"tokenSizeParameter"];
        self.dissociateByWord = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"dissociateByWordParameter"]];
    }
    return self;
}

- (NSArray *)loadDissociatedNewsForTopics:(NSArray *)topics pageNumber:(int)pageNumber
{
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSString *topic in topics) {
        [results addObjectsFromArray:[super loadNewsForTopic:topic pageNumber:pageNumber]];
    }
    
    for (DSPNewsStory *story in results) {
        story.titleSeed = [self addString:story.title toSourceText:self.titleSourceText];
        story.contentSeed = [self addString:story.content toSourceText:self.contentSourceText];
    }
    
    for (DSPNewsStory *story in results) {
        story.dissociatedTitle = [self dissociatedTitleForStory:story];
        story.dissociatedContent = [self dissociatedContentForStory:story];
    }
    
    return results;
    
    //    return [self dissociateResults:results];
}

- (NSArray *)loadDissociatedNewsForQueries:(NSArray *)queries pageNumber:(int)pageNumber
{
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSString *query in queries) {
        [results addObjectsFromArray:[super loadNewsForQuery:query pageNumber:pageNumber]];
    }
    
    for (DSPNewsStory *story in results) {
        story.titleSeed = [self addString:story.title toSourceText:self.titleSourceText];
        story.contentSeed = [self addString:story.content toSourceText:self.contentSourceText];
    }
    
    for (DSPNewsStory *story in results) {
        story.dissociatedTitle = [self dissociatedTitleForStory:story];
        story.dissociatedContent = [self dissociatedContentForStory:story];
    }
    
    return results;

    //    return [self dissociateResults:results];
}

- (NSString *)addString:(NSString *)sourceString toSourceText:(NSMutableDictionary *)sourceText
{
    /*tokenizes the given string and builds a markov chain representation of it,
     where each token is a key in a dictionary, whose value is an array of tokens which followed it in the source string.
     This representation is added to the passed sourceText dictionary
     
     //returns the first token from the string, which can be used as a seed
     */
    NSString *escapedSourceString = [sourceString stringByAppendingString:@"\n"];
    __block NSString *seedToken;
    
    NSUInteger stringEnumerationOptions = NSStringEnumerationByComposedCharacterSequences;
    if ([self.dissociateByWord boolValue]) {
        stringEnumerationOptions = NSStringEnumerationByWords;
    }
    NSMutableArray *token = [NSMutableArray array];
    [escapedSourceString enumerateSubstringsInRange:NSMakeRange(0, escapedSourceString.length) options:stringEnumerationOptions usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        substring = [escapedSourceString substringWithRange:enclosingRange];
        if ([token count] == 0) {
            seedToken = substring;
        } else {
            NSString *tokenString = [token componentsJoinedByString:@""];
            if (!sourceText[tokenString]) sourceText[tokenString] = [NSMutableArray array];
            [sourceText[tokenString] addObject:substring];
        }
        
        [token addObject:substring];
        if ([token count] > self.tokenSize) [token removeObjectAtIndex:0];
    }];
    
    return seedToken;
}


- (NSString *)dissociatedTitleForStory:(DSPNewsStory *)story
{
    return [self dissociatedStringWithSeed:story.titleSeed sourceText:self.titleSourceText];
}

- (NSString *)dissociatedContentForStory:(DSPNewsStory *)story
{
    return [self dissociatedStringWithSeed:story.contentSeed sourceText:self.contentSourceText];
}

- (NSString *)dissociatedStringWithSeed:(NSString *)seed sourceText:(NSDictionary *)sourceText
{
    if ([seed length] <= 0) {
        return nil;
    }
    
    BOOL success = NO;
    NSString *outString = [seed copy];
    NSMutableArray *token = [[NSMutableArray alloc] initWithObjects:seed, nil];
    
    while (!success) {
        NSString *tokenString = [token componentsJoinedByString:@""];
        
        NSArray *tokenPool = sourceText[tokenString];
        NSUInteger index = arc4random() % [tokenPool count];
        NSString *nextToken = tokenPool[index];
        
        outString = [outString stringByAppendingString:nextToken];
        
        if ([nextToken rangeOfString:@"\n"].location == NSNotFound) {
            [token addObject:nextToken];
            if ([token count] > self.tokenSize) [token removeObjectAtIndex:0];
        } else {
            success = YES;
        }

        if ([outString length] >= 300) {
            success = YES;
            outString = [outString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            outString = [outString substringWithRange:NSMakeRange(0, 297)];
            outString = [outString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            outString = [outString stringByAppendingString:@"..."];
        }
    }

    return outString;
}

#pragma mark - old method

- (NSArray *)dissociateResults:(NSArray *)results
{
    NSMutableDictionary *titleSeeds = [[NSMutableDictionary alloc] initWithCapacity:results.count];
    NSMutableDictionary *contentSeeds = [[NSMutableDictionary alloc] initWithCapacity:results.count];
    //tokenize each story and add it to the token lists
    for (DSPNewsStory *story in results) {
        NSNumber *storyHash  = [NSNumber numberWithUnsignedInteger:[story hash]];
        
        NSUInteger seedIndex = [self.titleTokens count]; //index of the first token to be added for story.title
        NSString *title = [story.title stringByAppendingString:@"\n"];
        [self tokenizeString:title toTokenArray:self.titleTokens TokenContext:self.titleTokenContext];
        titleSeeds[storyHash] = self.titleTokens[seedIndex]; //save the first token from this story to seed the dissociation
        
        seedIndex = [self.contentTokens count]; //index of the first token to be added for story.content
        NSString *content = [story.content stringByAppendingString:@"\n"];
        [self tokenizeString:content toTokenArray:self.contentTokens TokenContext:self.contentTokenContext];
        contentSeeds[storyHash] = self.contentTokens[seedIndex]; //save the first token from this story to seed the dissociation
    }
    
    //rewrite each story using the collected tokens
    for (DSPNewsStory *story in results) {
        NSNumber *storyHash = [NSNumber numberWithUnsignedInteger:[story hash]];
        NSString *titleSeed = titleSeeds[storyHash];
        story.title = [self reassociateWithSeed:titleSeed tokens:self.titleTokens context:self.titleTokenContext];
        
        NSString *contentSeed = contentSeeds[storyHash];
        story.content = [self reassociateWithSeed:contentSeed tokens:self.contentTokens context:self.contentTokenContext];
        
    }
    
    return results;
}

- (void)tokenizeString:(NSString *)sourceString toTokenArray:(NSMutableArray *)tokenArray TokenContext:(NSMutableDictionary *)tokenContext
{
    NSUInteger stringEnumerationOptions = NSStringEnumerationByComposedCharacterSequences;
    if ([self.dissociateByWord boolValue]) {
        stringEnumerationOptions = NSStringEnumerationByWords;
    }
    NSMutableArray *token = [NSMutableArray array];
    [sourceString enumerateSubstringsInRange:NSMakeRange(0, sourceString.length) options:stringEnumerationOptions usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        substring = [sourceString substringWithRange:enclosingRange];
        [token addObject:substring];
        if (token.count > self.tokenSize) [token removeObjectAtIndex:0];
        
        if ([substring rangeOfString:@"\n"].location != NSNotFound) {
            //taper off when adding the final token
            while ([token count] > 0) {
                NSString *tokenString = [token componentsJoinedByString:@""];
                [tokenArray addObject:tokenString];
                if (!tokenContext[tokenString]) tokenContext[tokenString] = [NSMutableArray array];
                [tokenContext[tokenString] addObject:[NSNumber numberWithInteger:(tokenArray.count - 1)]];
                [token removeObjectAtIndex:0];
            }
            
        } else if (token.count == self.tokenSize) {
            NSString *tokenString = [token componentsJoinedByString:@""];
            [tokenArray addObject:tokenString];
            if (!tokenContext[tokenString]) tokenContext[tokenString] = [NSMutableArray array];
            [tokenContext[tokenString] addObject:[NSNumber numberWithInteger:(tokenArray.count - 1)]];
        }
    }];
}


- (NSString *)reassociateWithSeed:(NSString *)seed tokens:(NSArray *)tokens context:(NSDictionary *)context
{
    BOOL success = NO;
    NSString *outString = @"";
    NSUInteger index;
    while (!success) {
        outString = @"";
        NSString *currentToken = seed;
        
        while ([currentToken rangeOfString:@"\n"].location == NSNotFound) {
            outString = [outString stringByAppendingString:currentToken];
            index = arc4random() % [context[currentToken] count];
            index = [context[currentToken][index] intValue] + self.tokenSize;
            if (index >= [tokens count]) {
                currentToken = @"\n";
            }
            else currentToken = tokens[index];
        }
        outString = [outString stringByAppendingString:currentToken];
        
        if ([outString length] > self.tokenSize) {
            success = YES;
        }
    }
    return outString;
}

@end
