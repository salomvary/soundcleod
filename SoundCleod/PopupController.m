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

- (WKWebView *)show:(WKWebViewConfiguration *)configuration
{
    if(webView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LoginWindow" owner:self topLevelObjects:nil];
        
        // Interface builder does not support WKWebView
        webView = [[WKWebView alloc] initWithFrame:[window frame] configuration: configuration];
        [[window contentView] addSubview:webView];
        
        [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(webView);
        
        [[window contentView] addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [[window contentView] addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [webView setUIDelegate:self];
        [webView setNavigationDelegate:self];
    }

    [window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    
    return [self webView];
}

- (void)webViewClose:(WKWebView *)sender
{
    [window orderOut:self];
//    [webView close];
    [webView removeFromSuperview];
    [self setWebView:nil];
}

- (void)webView:(WKWebView *)sender decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // window.open navigation
    NSLog(@"%@", [navigationAction.request URL]);
    if ([navigationAction targetFrame] != nil) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
        // open external links in external browser
        [[NSWorkspace sharedWorkspace] openURL:[navigationAction.request URL]];
    }
}

@end
