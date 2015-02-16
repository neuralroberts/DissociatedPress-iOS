//
//  AppDelegate.m
//  Dissociated Press
//
//  Created by Joseph Wilkerson on 11/10/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import "DSPAppDelegate.h"
#import "DSPNewsTVC.h"
#import "DSPTopStoriesTVC.h"
#import "DSPSettingsVC.h"
#import "DSPAuthenticationManager.h"
#import <RedditKit/RedditKit.h>
#import <Appirater/Appirater.h>
#import "IAPHelper.h"
//#import <SSKeychain/SSKeychain.h>
@interface DSPAppDelegate ()

@end

@implementation DSPAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setupUserDefaults];
    [IAPHelper sharedInstance];
    [self setupReddit];
    
    DSPNewsTVC *newsTVC;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        newsTVC = [[DSPNewsTVC alloc] initWithStyle:UITableViewStylePlain];
    } else {
        //use grouped style for iphone so that header's don't float
        newsTVC = [[DSPNewsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    }
    newsTVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Create" image:[UIImage imageNamed:@"UITabBarSearch"] tag:0];
    UINavigationController *newsNavigationVC = [[UINavigationController alloc] initWithRootViewController:newsTVC];
    
    DSPTopStoriesTVC *topTVC = [[DSPTopStoriesTVC alloc] init];
    topTVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:1];
    UINavigationController *topNavigationVC = [[UINavigationController alloc] initWithRootViewController:topTVC];
    
    DSPSettingsVC *settingsVC = [[DSPSettingsVC alloc] initWithStyle:UITableViewStyleGrouped];
    settingsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"UIButtonBarGear"] tag:2];
    UINavigationController *settingsNavigationVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];

    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.tabBar.translucent = NO;
    tabController.viewControllers = @[newsNavigationVC, topNavigationVC, settingsNavigationVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabController;
    self.window.tintColor = [UIColor darkGrayColor];
    [self.window makeKeyAndVisible];
    
    [self setupAppirater];

    return YES;
}

- (void)setupUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"hasLaunched"]) {
        [defaults setInteger:4 forKey:@"tokenSizeParameter"];
        [defaults setBool:NO forKey:@"dissociateByWordParameter"];
        [defaults setBool:YES forKey:@"includeComment"];
    }
    [defaults setBool:YES forKey:@"hasLaunched"];
}

- (void)setupReddit
{
//    for (NSDictionary *account in [SSKeychain accountsForService:@"DissociatedPress"]) {
//        NSError *error;
//        [SSKeychain deletePasswordForService:@"DissociatedPress" account:account[@"acct"] error:&error];
//        if (error) NSLog(@"%@",error);
//    }
    
    [[RKClient sharedClient] setUserAgent:@"User-Agent: Dissociated Press-iOS/0.6 /r/Dissociated_Press"];
    [DSPAuthenticationManager loginWithKeychainWithCompletion:nil];
}


- (void)setupAppirater
{
    [Appirater setAppId:@"962909584"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:16];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
