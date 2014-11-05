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
#import "UrlPromptController.h"
#import "../SPMediaKeyTap/SPMediaKeyTap.h"
#import "AppleMikeyManager.h"
#import "AppDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, AppleMikeyManagerDelegate>

@property (nonatomic, strong) NSURL *baseURL;
@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, strong) SPMediaKeyTap *mediaKeyListener;
@property (nonatomic, strong) AppleMikeyManager *mikeyManager;

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet PopupController *popupController;
@property (weak) IBOutlet UrlPromptController *urlPromptController;

@end
