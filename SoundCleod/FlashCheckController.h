//
//  FlashCheckController.h
//  SoundCleod
//
//  Created by Márton Salomváry on 2014/12/04.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//
#import <WebKit/WebKit.h>

@interface FlashCheckController : NSObject

@property (assign) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet WebView *webView;
@property (strong) IBOutlet NSWindow *flashPrompt;
@property (weak) IBOutlet NSButtonCell *startInstallButton;
@property (weak) IBOutlet NSButtonCell *restartButton;
@property (weak) IBOutlet NSTextField *text;

- (void)check;

@end
