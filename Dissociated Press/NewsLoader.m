//
//  NewsLoader.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/10/14.
//
//

#import "NewsLoader.h"
#import "NewsStory.h"

@implementation NewsLoader

+ (NSArray *)loadNewsForQuery:(NSString *)query pageNumber:(int)pageNumber
{
    NSString *escapedQuery = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    int start = (pageNumber - 1) * 4;
    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/news?v=1.0&start=%d&q=%@", start, escapedQuery];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&error];
    
    NSArray *associatedResultsArray = [jsonObject valueForKeyPath:@"responseData.results"];
    
    NSMutableArray *associatedResult = [[NSMutableArray alloc] initWithCapacity:associatedResultsArray.count];
    for (NSDictionary *resultDictionary in associatedResultsArray) {
        NSLog(@"%@",resultDictionary);
        NewsStory *story = [[NewsStory alloc] init];
        story.title = resultDictionary[@"titleNoFormatting"];
        story.content = resultDictionary[@"content"];
        story.url = [NSURL URLWithString:resultDictionary[@"unescapedUrl"]];
        
        NSDictionary *imageDictionary = resultDictionary[@"image"];
        if (imageDictionary) {
            story.imageHeight = [imageDictionary[@"tbHeight"] floatValue];
            story.imageWidth = [imageDictionary[@"tbWidth"] floatValue];
            story.imageUrl = [NSURL URLWithString:imageDictionary[@"tbUrl"]];
        }
        
        [associatedResult addObject:story];
    }
    
    return associatedResult;
}
@end
