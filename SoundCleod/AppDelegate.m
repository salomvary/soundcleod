//
//  AppDelegate.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "AppConstants.h"
#import "AppDelegate.h"
#import <Foundation/NSNotification.h>

NSString *const SCTriggerJS = @"$(document).trigger($.Event('keydown',{keyCode: %d}))";
NSString *const SCNavigateJS = @"history.replaceState(null, null, '%@');$(window).trigger('popstate')";

@interface WebPreferences (WebPreferencesPrivate)
- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void) setLocalStorageEnabled: (BOOL) localStorageEnabled;
@end

@implementation AppDelegate

@synthesize webView;
@synthesize popupController;
@synthesize window;
@synthesize urlPromptController;

+ (void)initialize;
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
     [NSURLRequest requestWithURL:[NSURL URLWithString: [@"http://" stringByAppendingString:SCHost]]
    ]];
    WebPreferences* prefs = [webView preferences];
    [prefs setCacheModel:WebCacheModelPrimaryWebBrowser];
    [prefs setPlugInsEnabled:FALSE]; // fixes the FlashBlock issue
    
    [prefs _setLocalStorageDatabasePath:@"~/Library/Application Support/SoundCleod"];
    [prefs setLocalStorageEnabled:YES];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNotification:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    [window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag == NO)
    {
        [window makeKeyAndOrderFront:self];
    }

    return YES;
}


- (void)awakeFromNib
{
    [webView setUIDelegate:self];
    [webView setFrameLoadDelegate:self];
    [webView setPolicyDelegate:self];
    [urlPromptController setNavigateDelegate:self];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    // request will always be null (probably a bug)
    return [popupController show];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [webView mainFrame]) {
        [window setTitle:title];
        if ([title rangeOfString:@"▶"].location != NSNotFound) {
            title = [title stringByReplacingOccurrencesOfString:@"▶ " withString:@""];
            NSArray *info = [title componentsSeparatedByString:@" by "];
            [self showNotification:info[0] withArtist:info[1]];
        }
    }
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    // normal in-frame navigation
    if(frame != [webView mainFrame] || [AppDelegate isSCURL:[request URL]]) {
        // allow loading urls in sub-frames OR when they are sc urls
        [listener use];
    } else {
        [listener ignore];
        // open external links in external browser
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    }
}

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    // target=_blank or anything scenario
    [listener ignore];
    if([AppDelegate isSCURL:[request URL]]) {
        // open local links in the main frame
        // TODO: maybe maintain a frame stack instead?
        [[webView mainFrame] loadRequest: [NSURLRequest requestWithURL:
                                           [actionInformation objectForKey:WebActionOriginalURLKey]]];
    } else {
        // open external links in external browser
        [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    }

}

- (void)receiveSleepNotification:(NSNotification*)note
{
    if([self isPlaying]) {
        [self playPause];
    }
}

- (void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
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


- (IBAction)showHelp:(id)sender
{
    [self help];
}

- (void)next
{
    [self trigger:48]; // set time on current song back to 0 before switching track
    [self trigger:74];
}

- (void)prev
{
    // if the track is < 5 seconds in, go to the previous song, otherwise skip back to start
    if ([self checkTrackProgress] < 5000) {
        [self trigger:48]; // set time on current song back to 0 before switching track
        [self trigger:75];
    } else {
        [self trigger:48];
    }
}

- (void)swipeWithEvent:(NSEvent *)event {
    NSLog(@"swiped");
}

- (void)playPause
{
    [self trigger:32];
}

- (void)help
{
    [self trigger:72];
}

- (NSInteger) checkTrackProgress {
    NSString *js = @"\
    (function() {\
        for (sound in soundManager.sounds) {\
            var currentSound = soundManager.sounds[sound];\
            if(currentSound.playState == 1 && currentSound.paused === false) {\
                return currentSound.position;\
            }\
        }\
        return -1;\
    })();";
    return [[webView stringByEvaluatingJavaScriptFromString:js] integerValue];
}

- (void)trigger:(int)keyCode
{
    NSString *js = [NSString stringWithFormat:SCTriggerJS, keyCode];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

- (BOOL)isPlaying
{
    // FIXME find a better way to detect playing
    NSString *title = [window title];
    return [title rangeOfString:@"▶"].location != NSNotFound;
}

- (void)navigate:(NSString*)permalink
{
    NSString *js = [NSString stringWithFormat:SCNavigateJS, permalink];
    [webView stringByEvaluatingJavaScriptFromString:js];
}


- (void)showNotification:(NSString*)song withArtist:(NSString*)artist{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = artist;
    notification.informativeText = song;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}


+ (BOOL)isSCURL:(NSURL *)url
{
    if(url != nil) {
        if([url host] != nil) {
            if([[url host] isEqualToString:SCHost]) {
                return TRUE;
            }
        }
    }
    return FALSE;
}

@end
