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
    [webView setPolicyDelegate:self];
}

- (WebView *)show
{
    if(webView == nil) {
        [NSBundle loadNibNamed:@"LoginWindow" owner:self];
    }
    [self setIsFirstLoad:TRUE];
    return [self webView];
}

- (void)webViewClose:(WebView *)sender
{
    [window setIsVisible:FALSE];
    [webView close];
    [webView removeFromSuperview];
    [self setWebView:nil];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    // window.open navigation
    if(![self isFirstLoad] || [PopupController isLoginURL:[request URL]]) {
        // new popup can only opened with login url, from there navigation
        // anywhere is allowed
        [listener use];
        [self setIsFirstLoad:FALSE];
        [window setIsVisible:TRUE];
    } else {
        [listener ignore];
        // open external links in external browser
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    }
}

+ (BOOL)isLoginURL:(NSURL *)url
{
    return [[url host] isEqualToString: BMFacebookHost] || [[url host] isEqualToString: BMTwitterHost];
}

@end
