//
//  PopupController.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "AppConstants.h"
#import "PopupController.h"

@implementation PopupController

@synthesize webView;
@synthesize window;
@synthesize isFirstLoad;

- (void)awakeFromNib
{
    [webView setUIDelegate:self];
    [webView setNavigationDelegate:self];
}

- (WKWebView *)show
{
    if(webView == nil) {
        [NSBundle loadNibNamed:@"LoginWindow" owner:self];
    }
    [self setIsFirstLoad:TRUE];
    return [self webView];
}

- (void)webViewClose:(WKWebView *)sender
{
    [window setIsVisible:FALSE];
//    [webView close];
    [webView removeFromSuperview];
    [self setWebView:nil];
}

//- (void)webView:(WKWebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
//        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
- (void)webView:(WKWebView *)sender decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // window.open navigation
    if(![self isFirstLoad] || [PopupController isLoginURL:[navigationAction.request URL]]) {
        // new popup can only opened with login url, from there navigation
        // anywhere is allowed
        decisionHandler(WKNavigationActionPolicyAllow);
        [self setIsFirstLoad:FALSE];
        [window setIsVisible:TRUE];
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
        // open external links in external browser
        [[NSWorkspace sharedWorkspace] openURL:[navigationAction.request URL]];
    }
}

+ (BOOL)isLoginURL:(NSURL *)url
{
    return [[url host] isEqualToString: SCHost]
        // for some strange reason, objectAtIndex:0 is "/"
        && [[[url pathComponents] objectAtIndex:1] isEqualToString: @"connect"];
}

@end
