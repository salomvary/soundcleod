//
//  AppDelegate.h
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "PopupController.h"
#import "../SPMediaKeyTap/SPMediaKeyTap.h"

NSString *const SCTriggerJS;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    SPMediaKeyTap *keyTap;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet PopupController *popupController;

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request;
-(void)next;
-(void)prev;
-(void)playPause;
-(void) trigger: (int) keyCode;

@end
