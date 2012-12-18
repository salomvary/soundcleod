//
//  AppDelegate.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "AppDelegate.h"

NSString *const SCTriggerJS = @"$(document).trigger($.Event('keydown',{keyCode: %d}))";

@interface WebPreferences (WebPreferencesPrivate)
- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void) setLocalStorageEnabled: (BOOL) localStorageEnabled;
@end

@implementation AppDelegate
@synthesize webView;
@synthesize popupController;
@synthesize window;

+(void)initialize;
{
	if([self class] != [AppDelegate class]) return;
    
	// Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                             nil]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");

    [[webView mainFrame] loadRequest:
	 [NSURLRequest requestWithURL:[NSURL URLWithString: @"http://soundcloud.com" ]
    ]];
    
    WebPreferences* prefs = [webView preferences];
    [prefs setCacheModel:WebCacheModelPrimaryWebBrowser];
    
    [prefs _setLocalStorageDatabasePath:@"~/Library/Application Support/SoundCleod"];
    [prefs setLocalStorageEnabled:YES];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNotification:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
}

- (void) awakeFromNib
{
    [webView setUIDelegate:self];
    [webView setFrameLoadDelegate:self];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    NSLog(@"webView: createWebViewWithRequest %@", request);
    return [popupController show];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [webView mainFrame]) {
        [window setTitle:title];
    }
}

- (void)receiveSleepNotification:(NSNotification*)note
{
    if([self isPlaying]) {
        [self playPause];
    }
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	//int keyRepeat = (keyFlags & 0x1);
    
	if (keyIsPressed) {
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
                [self playPause];
				break;
                
			case NX_KEYTYPE_FAST:
				[self next];
                break;
                
			case NX_KEYTYPE_REWIND:
                [self prev];
				break;
			default:
				NSLog(@"Key %d pressed", keyCode);
				break;
		}
	}
}

- (IBAction)showHelp:(id)sender {
    [self help];
}

-(void)next
{
    [self trigger:74];
}

-(void)prev
{
    [self trigger:75];
}

-(void)playPause
{
    [self trigger:32];
}

-(void)help
{
    [self trigger:72];
}

-(void) trigger: (int) keyCode
{
    NSString *js = [NSString stringWithFormat:SCTriggerJS, keyCode];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

-(BOOL) isPlaying
{
    // FIXME find a better way to detect playing
    NSString *title = [window title];
    return [title rangeOfString:@"▶"].location != NSNotFound;
}
@end
