//
//  DSPAuthenticationTVC.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/10/14.
//
//

#import <UIKit/UIKit.h>

typedef void(^LoginSuccessBlock)();

@interface DSPAuthenticationTVC : UITableViewController


+ (void)loginWithKeychainWithCompletion:(LoginSuccessBlock)completion;
+ (void)signInWithUsername:(NSString *)username password:(NSString *)password completion:(LoginSuccessBlock)completion;

@end
