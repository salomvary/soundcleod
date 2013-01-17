//
//  PopupController.h
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface PopupController : NSObject

@property (assign) IBOutlet NSPanel *window;
@property (weak) IBOutlet WebView *webView;
@property BOOL isFirstLoad;


- (void)awakeFromNib;
- (WebView *)show;
- (void)webViewShow:(WebView *)sender;
- (void)webViewClose:(WebView *)sender;
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener;
+(BOOL)isLoginURL:(NSURL *)url;

@end
