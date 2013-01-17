//
//  PopupController.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "PopupController.h"
#import "AppDelegate.h"

@implementation PopupController

@synthesize webView;
@synthesize window;
@synthesize isFirstLoad;

- (void) awakeFromNib
{
    [webView setUIDelegate:self];
    [webView setPolicyDelegate:self];
}

- (WebView *)show
{
    NSLog(@"popup/show %@", [self webView]);
    if(webView == nil) {
        [NSBundle loadNibNamed:@"LoginWindow" owner:self];
    }
    [self setIsFirstLoad:TRUE];
    return [self webView];
}

- (void)webViewShow:(WebView *)sender
{
    NSLog(@"popup/webViewShow %@", sender);
}

- (void)webViewClose:(WebView *)sender
{
    NSLog(@"popup/webViewClose %@", sender);
    [window setIsVisible:FALSE];
    [webView close];
    [webView removeFromSuperview];
    [self setWebView:nil];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    // window.open navigation
 	NSLog(@"popup/webView: decidePolicyForNavigationAction: %@\n",  request);
    if(![self isFirstLoad] || [PopupController isLoginURL:[request URL]]) {
        NSLog(@"popup/webView: decidePolicyForNavigationAction local");
        [listener use];
        [self setIsFirstLoad:FALSE];
        [window setIsVisible:TRUE];
    } else {
        NSLog(@"popup/webView: decidePolicyForNavigationAction external");
        [listener ignore];
        // open external links in external browser
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    }
}

+(BOOL)isLoginURL:(NSURL *)url
{
    NSLog(@"popup/isLoginUrl: %@ - %@ - %@", url, [url host], [url pathComponents]);
    return [[url host] isEqualToString: SCHost]
    // for some strange reason, objectAtIndex:0 is "/"
    && [[[url pathComponents] objectAtIndex:1] isEqualToString: @"connect"];
}

@end
