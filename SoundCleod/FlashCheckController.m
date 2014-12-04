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

@implementation FlashCheckController

@synthesize webView;
@synthesize flashPrompt;
@synthesize mainWindow;

- (void)check
{
    NSInteger flashVersion = [[webView stringByEvaluatingJavaScriptFromString:FlashVersionJS] integerValue];
    if (flashVersion < 10) {
        [self showPrompt];
    }
}

-(void)showPrompt
{
    if (flashPrompt == nil) {
        [NSBundle loadNibNamed:@"FlashPrompt" owner:self];
    }
    [NSApp beginSheet: flashPrompt
       modalForWindow: mainWindow
        modalDelegate: self
       didEndSelector: @selector(flashPromptDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
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
    [self openSafari:@"http://get.adobe.com/flashplayer/"];
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