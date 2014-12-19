//
//  FlashCheckController.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2014/12/04.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import <Sparkle/Sparkle.h>

#import "Safari.h"
#import "FlashCheckController.h"

NSString *const FlashVersionJS = @"(function(){ var plugin = navigator.mimeTypes['application/x-shockwave-flash'].enabledPlugin; return plugin && plugin.description.match(/\\d+/)[0]})()";

NSString *const FlashBlockedJS = @"(function() {var e = document.createElement('embed'); e.style.visibility = 'hidden'; e.type = 'application/x-shockwave-flash'; document.body.appendChild(e); return !('PercentLoaded' in e)})()";

NSString *const FlashBlockedWarning = @"Flash Plugin is blocked by Safari. Please make sure the latest Flash Plugin for Safari is installed and enabled for soundcloud.com.";

NSString *const NoFlashWarning = @"Playing certain tracks on soundcloud.com requires a recent version of Adobe Flash Plugin for Safari.";

NSString *const InstallFlashUrl = @"http://get.adobe.com/flashplayer/";

NSString *const FlashHelpUrl = @"http://helpx.adobe.com/flash-player.html";

NSString *const UnblockFlash = @"Check Flash Player";

NSString *const InstallFlash = @"Start Flash Install";


@implementation FlashCheckController

@synthesize webView;
@synthesize flashPrompt;
@synthesize mainWindow;
@synthesize text;

NSString *buttonUrl;

- (void)check
{
    NSInteger flashVersion = [[webView stringByEvaluatingJavaScriptFromString:FlashVersionJS] integerValue];
    BOOL isFlashBlocked = [[webView stringByEvaluatingJavaScriptFromString:FlashBlockedJS] boolValue];
    
    if (flashVersion < 10) {
        [self showPrompt: NoFlashWarning buttonTitle:InstallFlash url:InstallFlashUrl];
    } else if (isFlashBlocked) {
        [self showPrompt: FlashBlockedWarning buttonTitle:UnblockFlash url:FlashHelpUrl];
    }
}

-(void)showPrompt: (NSString*)message buttonTitle:(NSString*)buttonTitle url:(NSString*)url
{
    if (flashPrompt == nil) {
        [NSBundle loadNibNamed:@"FlashPrompt" owner:self];
    }
    [NSApp beginSheet: flashPrompt
       modalForWindow: mainWindow
        modalDelegate: self
       didEndSelector: @selector(flashPromptDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
    [text setStringValue: message];
    [[self startInstallButton] setTitle: buttonTitle];
    buttonUrl = url;
}

- (void)awakeFromNib
{
    [[self restartButton] setEnabled:FALSE];
    [[self restartButton] setTransparent:TRUE];
}

- (IBAction)restart:(id)sender {
    [NSApp endSheet:flashPrompt];
    [self restartApplication];
}

- (IBAction)notNow:(id)sender
{
    [NSApp endSheet:flashPrompt];
}

- (IBAction)openFlashInstall:(id)sender
{
    [self openSafari:buttonUrl];
    [[self startInstallButton] setEnabled:FALSE];
    [[self startInstallButton] setTransparent:TRUE];
    [[self restartButton] setEnabled:TRUE];
    [[self restartButton] setTransparent:FALSE];
}

- (void)flashPromptDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}
     
-(void)openSafari:(NSString*)url
{
    // see http://stackoverflow.com/questions/21721325
    SafariApplication* sfApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
    NSDictionary *theProperties = [NSDictionary dictionaryWithObject:url forKey:@"URL"];
    SafariDocument *doc = [[[sfApp classForScriptingClass:@"document"] alloc] initWithProperties:theProperties];
    [[sfApp documents] addObject:doc];
    [sfApp activate];
}

-(void)restartApplication
{
    // see http://snipplr.com/view/3923/relaunch-an-application/
    NSString *launcherSource = [[NSBundle bundleForClass:[SUUpdater class]]  pathForResource:@"relaunch" ofType:@""];
    NSString *launcherTarget = [NSTemporaryDirectory() stringByAppendingPathComponent:[launcherSource lastPathComponent]];
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    NSString *processID = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
    
    [[NSFileManager defaultManager] removeItemAtPath:launcherTarget error:NULL];
    [[NSFileManager defaultManager] copyItemAtPath:launcherSource toPath:launcherTarget error:NULL];
    
    [NSTask launchedTaskWithLaunchPath:launcherTarget arguments:[NSArray arrayWithObjects:appPath, processID, nil]];
    [NSApp terminate:NSApp];
}

@end