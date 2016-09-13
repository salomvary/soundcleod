//
//  PopupController.h
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface PopupController : NSObject <WKUIDelegate, WKNavigationDelegate>

@property (assign) IBOutlet NSPanel *window;
@property WKWebView *webView;

- (WKWebView *)show:(WKWebViewConfiguration *)configuration;
- (void)webViewClose:(WKWebView *)sender;
@end
