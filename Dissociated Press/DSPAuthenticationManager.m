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

@property (nonatomic, copy) AuthenticationSuccessBlock authenticationSuccessBlock;

- (UIAlertView *)signInAlertView;

@end

@implementation DSPAuthenticationManager

- (void)signInWithCompletion:(AuthenticationSuccessBlock)completion
{
    self.authenticationSuccessBlock = completion;
    
    NSDictionary *account = [[SSKeychain accountsForService:@"DissociatedPress"] firstObject];
    NSString *username = account[@"acct"];
    NSString *password = [SSKeychain passwordForService:@"DissociatedPress" account:username error:nil];
    if ([username length] == 0 || [password length] == 0)
    {
        [[self signInAlertView] show];
    } else {
        [self signInWithUsername:username password:password];
    }
}

#pragma mark - Private

- (UIAlertView *)signInAlertView
{
    UIAlertView *signInAlert = [[UIAlertView alloc] initWithTitle:@"Reddit Account"
                                                          message:@"Please enter your account credentials."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Sign In", nil];
    signInAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    return signInAlert;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        
        if ([username length] == 0 || [password length] == 0)
        {
            return;
        }
        [self signInWithUsername:username password:password];
    }
}

- (void)signInWithUsername:(NSString *)username password:(NSString *)password
{
    __weak __typeof(self)weakSelf = self;
    [[RKClient sharedClient] signInWithUsername:username password:password completion:^(NSError *error) {
        if (error)
        {
            UIAlertView *errorAlertView = [weakSelf signInAlertView];
            errorAlertView.message = error.localizedFailureReason;
            
            [errorAlertView show];
        }
        else
        {
            [SSKeychain setPassword:password forService:@"DissociatedPress" account:username error:nil];
            if (self.authenticationSuccessBlock)
            {
                dispatch_async(dispatch_get_main_queue(), self.authenticationSuccessBlock);
            }
        }
    }];
}

@end
