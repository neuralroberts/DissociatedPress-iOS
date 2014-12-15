//
//  RKClient+DSP.m
//  A category for RKClient which includes a JSON responseObject in the completion block of submitLink methods
//
//  Created by Joseph Wilkerson on 12/12/14.
//
//
// RKClient+Links.m
//
// Copyright (c) 2014 Sam Symons (http://samsymons.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RKClient+DSP.h"

@implementation RKClient (DSP)

#pragma mark - Submitting Links

- (NSURLSessionDataTask *)DSPSubmitLinkPostWithTitle:(NSString *)title subreddit:(RKSubreddit *)subreddit URL:(NSURL *)URL captchaIdentifier:(NSString *)captchaIdentifier captchaValue:(NSString *)captchaValue completion:(RKRequestCompletionBlock)completion
{
    return [self DSPSubmitLinkPostWithTitle:title subredditName:subreddit.name URL:URL captchaIdentifier:captchaIdentifier captchaValue:captchaValue completion:completion];
}

- (NSURLSessionDataTask *)DSPSubmitLinkPostWithTitle:(NSString *)title subredditName:(NSString *)subredditName URL:(NSURL *)URL captchaIdentifier:(NSString *)captchaIdentifier captchaValue:(NSString *)captchaValue completion:(RKRequestCompletionBlock)completion
{
    return [self DSPSubmitLinkPostWithTitle:title subredditName:subredditName URL:URL resubmit:NO captchaIdentifier:captchaIdentifier captchaValue:captchaValue completion:completion];
}

- (NSURLSessionDataTask *)DSPSubmitLinkPostWithTitle:(NSString *)title subredditName:(NSString *)subredditName URL:(NSURL *)URL resubmit:(BOOL)resubmit captchaIdentifier:(NSString *)captchaIdentifier captchaValue:(NSString *)captchaValue completion:(RKRequestCompletionBlock)completion
{
    NSParameterAssert(title);
    NSParameterAssert(subredditName);
    NSParameterAssert(URL);
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:7];
    
    [parameters setObject:title forKey:@"title"];
    [parameters setObject:subredditName forKey:@"sr"];
    [parameters setObject:[URL absoluteString] forKey:@"url"];
    [parameters setObject:[self stringFromBoolean:resubmit] forKey:@"resubmit"];
    
    if (captchaIdentifier) [parameters setObject:captchaIdentifier forKey:@"iden"];
    if (captchaValue) [parameters setObject:captchaValue forKey:@"captcha"];
    
    [parameters setObject:@"link" forKey:@"kind"];
    
    return [self DSPBasicPostTaskWithPath:@"api/submit" parameters:parameters completion:completion];
}


#pragma mark - requests
- (NSURLSessionDataTask *)DSPBasicPostTaskWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(RKRequestCompletionBlock)completion
{
    NSParameterAssert(path);
    
    if (![self isSignedIn])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(nil, nil, [RKClient authenticationRequiredError]);
            }
        });
        
        return nil;
    }
    
    return [self postPath:path parameters:parameters completion:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(response, responseObject, error);
            }
        });
    }];
}

@end

