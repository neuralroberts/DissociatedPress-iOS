// AuthenticationManager.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/8/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPAuthenticationManager.h"
#import <RedditKit/RedditKit.h>
#import <SSKeychain/SSKeychain.h>


@interface DSPAuthenticationManager ()

@end

@implementation DSPAuthenticationManager

+ (void)loginWithKeychainWithCompletion:(AuthenticationSuccessBlock)completion
{
    NSDictionary *account = [[SSKeychain accountsForService:@"DissociatedPress"] firstObject];
    NSString *username = account[@"acct"];
    NSString *password = [SSKeychain passwordForService:@"DissociatedPress" account:username error:nil];
    if ([username length] > 0 && [password length] > 0) {
        [DSPAuthenticationManager signInWithUsername:username password:password completion:completion];
    }
}

+ (void)signInWithUsername:(NSString *)username password:(NSString *)password completion:(AuthenticationSuccessBlock)completion
{
    [[RKClient sharedClient] signInWithUsername:username password:password completion:^(NSError *error) {
        if (error)
        {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                                     message:error.localizedFailureReason
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [errorAlertView show];
        }
        else
        {
            for (NSString *account in [SSKeychain accountsForService:@"DissociatedPress"]) {
                [SSKeychain deletePasswordForService:@"DissociatedPress" account:account error:nil];
            }
            [SSKeychain setPassword:password forService:@"DissociatedPress" account:username error:nil];
        }
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}

+ (NSString *)passwordForDissociatedPress
{
    NSDictionary *account = [[SSKeychain accountsForService:@"DissociatedPress"] firstObject];
    NSString *username = account[@"acct"];
    NSString *password = [SSKeychain passwordForService:@"DissociatedPress" account:username];
    return password;
}

+ (NSString *)usernameForDissociatedPress
{
    NSDictionary *account = [[SSKeychain accountsForService:@"DissociatedPress"] firstObject];
    NSString *username = account[@"acct"];
    return username;
}

@end
