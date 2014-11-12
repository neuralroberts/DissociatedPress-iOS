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
    //check that query isn't empty
    if (![[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {
        return nil;
    }
    
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
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:associatedResultsArray.count];
    for (NSDictionary *resultDictionary in associatedResultsArray) {
        NewsStory *story = [[NewsStory alloc] init];
#warning NSString category for stripping html
        story.title = [[[NSAttributedString alloc] initWithData:[resultDictionary[@"title"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil] string];
        story.content = [[[NSAttributedString alloc] initWithData:[resultDictionary[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil] string];
        story.url = [NSURL URLWithString:resultDictionary[@"unescapedUrl"]];
        
        NSDictionary *imageDictionary = resultDictionary[@"image"];
        if (imageDictionary) {
            story.imageHeight = [imageDictionary[@"tbHeight"] floatValue];
            story.imageWidth = [imageDictionary[@"tbWidth"] floatValue];
            story.imageUrl = [NSURL URLWithString:imageDictionary[@"tbUrl"]];
        }
        
        [result addObject:story];
    }
    
    return result;
}

@end
