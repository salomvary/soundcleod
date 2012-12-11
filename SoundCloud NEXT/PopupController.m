//
//  PopupController.m
//  SoundCloud NEXT
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "PopupController.h"

@implementation PopupController

@synthesize webView;
@synthesize window;

- (void) awakeFromNib
{
    [webView setUIDelegate:self];
    [webView setPolicyDelegate:self];
}

- (WebView *)show
{
    NSLog(@"popup/show %@", webView);
    [window setIsVisible:TRUE];
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
    
 	NSLog(@"popup/webView: decidePolicyForNavigationAction: %@\n",  request);
	[listener use];
}

@end
