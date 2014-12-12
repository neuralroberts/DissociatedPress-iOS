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
#import "DSPAuthenticationManager.h"
#import <RedditKit/RedditKit.h>

@interface DSPAppDelegate ()

@end

@implementation DSPAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupUserDefaults];
    [self setupReddit];
    
    DSPNewsTVC *newsTVC;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        newsTVC = [[DSPNewsTVC alloc] initWithStyle:UITableViewStylePlain];
    } else {
        //use grouped style for iphone so that header's don't float
        newsTVC = [[DSPNewsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    }
    newsTVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    UINavigationController *newsNavigationVC = [[UINavigationController alloc] initWithRootViewController:newsTVC];
    
    DSPTopStoriesTVC *topTVC = [[DSPTopStoriesTVC alloc] init];
    topTVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:1];
    UINavigationController *topNavigationVC = [[UINavigationController alloc] initWithRootViewController:topTVC];
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = @[newsNavigationVC, topNavigationVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)setupUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"hasLaunched"]) {
        [defaults setInteger:3 forKey:@"tokenSizeParameter"];
        [defaults setBool:NO forKey:@"dissociateByWordParameter"];
        [defaults setBool:YES forKey:@"includeComment"];
    }
    [defaults setBool:YES forKey:@"hasLaunched"];
}

- (void)setupReddit
{
    [[RKClient sharedClient] setUserAgent:@"User-Agent: Dissociated Press-iOS/0.333 /r/NewsSalad"];
    [DSPAuthenticationManager loginWithKeychainWithCompletion:nil];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
