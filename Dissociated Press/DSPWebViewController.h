//
//  DSPWebViewController.h
//  DissociatedPress-iOS
//
//  Created by Joe Wilkerson on 12/18/14.
//
//

#import <UIKit/UIKit.h>

@interface DSPWebViewController : UIViewController

@property (strong, nonatomic) UIWebView *webView;

- (instancetype)initWithURL:(NSURL *)url;

@end
