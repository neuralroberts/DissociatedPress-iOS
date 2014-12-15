//
//  NewsLoader.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPNewsLoader.h"
#import "DSPNewsStory.h"
#import "NSString+HTML.h"



@implementation DSPNewsLoader

- (NSArray *)loadNewsForQuery:(NSString *)query pageNumber:(int)pageNumber
{
    if (![[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {
        //check that query isn't empty
        return nil;
    }
    
    NSString *escapedQuery = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    int start = (pageNumber - 1) * 4;
    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/news?v=1.0&start=%d&q=%@", start, escapedQuery];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [self loadNewsForURL:url];
}

- (NSArray *)loadNewsForTopic:(NSString *)topic pageNumber:(int)pageNumber
{    
    NSDictionary *abbreviatedTopics = @{@"Headlines":@"h",
                                        @"World":@"w",
                                        @"Business":@"b",
                                        @"Nation":@"n",
                                        @"Technology":@"t",
                                        @"Elections":@"el",
                                        @"Politics":@"p",
                                        @"Entertainment":@"e",
                                        @"Sports":@"s",
                                        @"Health":@"m"};
    
    NSString *abbreviatedTopic = abbreviatedTopics[topic];
    if (!abbreviatedTopic) {
        return nil;
    }
    
    int start = (pageNumber - 1) * 4;
    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/news?v=1.0&start=%d&q=&topic=%@", start, abbreviatedTopic];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [self loadNewsForURL:url];
}

- (NSArray *)loadNewsForURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"https://github.com/neuralroberts/DissociatedPress-iOS" forHTTPHeaderField:@"Referer"];
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&error];
    
    if ([NSNull null] == [jsonObject valueForKeyPath:@"responseData"]) {
        NSLog(@"%@",jsonObject);
        return nil;
    }
    
    NSArray *associatedResultsArray = [jsonObject valueForKeyPath:@"responseData.results"];
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:associatedResultsArray.count];
    for (NSDictionary *resultDictionary in associatedResultsArray) {
        DSPNewsStory *story = [[DSPNewsStory alloc] init];
        story.uniqueIdentifier = [[NSUUID alloc] init];
        story.title = [resultDictionary[@"titleNoFormatting"] stringByConvertingHTMLToPlainText];
        story.content = [resultDictionary[@"content"] stringByConvertingHTMLToPlainText];
        story.url = [NSURL URLWithString:resultDictionary[@"unescapedUrl"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
        story.date = [dateFormatter dateFromString:resultDictionary[@"publishedDate"]];
        
        NSDictionary *imageDictionary = resultDictionary[@"image"];
        if (imageDictionary) {
            story.hasThumbnail = YES;
            story.imageHeight = [imageDictionary[@"tbHeight"] floatValue];
            story.imageWidth = [imageDictionary[@"tbWidth"] floatValue];
            story.imageUrl = [NSURL URLWithString:imageDictionary[@"tbUrl"]];
        } else {
            story.hasThumbnail = NO;
            story.imageHeight = 0.0;
            story.imageWidth = 0.0;
        }
        
        [result addObject:story];
    }
    
    return result;
}

@end
