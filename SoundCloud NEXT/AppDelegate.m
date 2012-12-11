//
//  AppDelegate.m
//  SoundCloud NEXT
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize webView;
@synthesize popupController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[webView mainFrame] loadRequest:
	 [NSURLRequest requestWithURL:[NSURL URLWithString: @"http://soundcloud.com" ]
    ]];
}

- (void) awakeFromNib
{
    [webView setUIDelegate:self];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    NSLog(@"webView: createWebViewWithRequest %@", request);
    return [popupController show];
}


@end
