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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[webView mainFrame] loadRequest:
	 [NSURLRequest requestWithURL:[NSURL URLWithString: @"http://soundcloud.com" ]
    ]];
}

@end
