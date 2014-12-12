//
//  RKClient+DSP.h
//  Pods
//
//  Created by Joseph Wilkerson on 12/12/14.
//
//
// RKClient+Links.h
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

#import <RedditKit/RedditKit.h>

@class RKLink, RKSubreddit, RKMultireddit;

@interface RKClient (DSP)

#pragma mark - Submitting

/**
 Submits a link post.
 
 @param title The title of the post.
 @param subreddit The subreddit in which to submit the post.
 @param URL The URL to submit.
 @param captchaIdentifier The optional identifier of the CAPTCHA you are submitting with this post.
 @param captchaValue The optional value of the CAPTCHA you are submitting with this post.
 @param completion An optional block to be executed upon request completion. Its only argument is any error that occurred.
 
 @note This does not resubmit the link if it already exists.
 */
- (NSURLSessionDataTask *)DSPSubmitLinkPostWithTitle:(NSString *)title subreddit:(RKSubreddit *)subreddit URL:(NSURL *)URL captchaIdentifier:(NSString *)captchaIdentifier captchaValue:(NSString *)captchaValue completion:(RKRequestCompletionBlock)completion;

/**
 Submits a link post.
 
 @param title The title of the post.
 @param subredditName The name of the subreddit in which to submit the post.
 @param URL The URL to submit.
 @param captchaIdentifier The optional identifier of the CAPTCHA you are submitting with this post.
 @param captchaValue The optional value of the CAPTCHA you are submitting with this post.
 @param completion An optional block to be executed upon request completion. Its only argument is any error that occurred.
 
 @note This does not resubmit the link if it already exists.
 */
- (NSURLSessionDataTask *)DSPSubmitLinkPostWithTitle:(NSString *)title subredditName:(NSString *)subredditName URL:(NSURL *)URL captchaIdentifier:(NSString *)captchaIdentifier captchaValue:(NSString *)captchaValue completion:(RKRequestCompletionBlock)completion;

/**
 Submits a link post.
 
 @param title The title of the post.
 @param subredditName The name of the subreddit in which to submit the post.
 @param URL The URL to submit.
 @param resubmit Whether to resubmit the link if it already exists.
 @param captchaIdentifier The optional identifier of the CAPTCHA you are submitting with this post.
 @param captchaValue The optional value of the CAPTCHA you are submitting with this post.
 @param completion An optional block to be executed upon request completion. Its only argument is any error that occurred.
 */
- (NSURLSessionDataTask *)DSPSubmitLinkPostWithTitle:(NSString *)title subredditName:(NSString *)subredditName URL:(NSURL *)URL resubmit:(BOOL)resubmit captchaIdentifier:(NSString *)captchaIdentifier captchaValue:(NSString *)captchaValue completion:(RKRequestCompletionBlock)completion;


/**
 Many of reddit's API methods require a set of parameters and simply return an error if they fail, and nothing of value when they succeed.
 This method eliminates much of the repetition when writing methods around these methods.
 
 @param path The path to request.
 @param parameters The parameters to pass with the request.
 @param completion A block to execute at the end of the request.
 */
- (NSURLSessionDataTask *)DSPBasicPostTaskWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(RKRequestCompletionBlock)completion;
@end
