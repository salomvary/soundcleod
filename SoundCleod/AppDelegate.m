//
//  AppDelegate.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "AppConstants.h"
#import "AppDelegate.h"

NSString *const SCTriggerJS = @"$(document.body).trigger($.Event('keydown',{keyCode: %d}))";
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
    [window setFrameAutosaveName:@"SoundCleod"];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");

    [[webView mainFrame] loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString: [@"https://" stringByAppendingString:SCHost]]
    ]];
    
    WebPreferences* prefs = [WebPreferences standardPreferences];
    
    [prefs setCacheModel:WebCacheModelPrimaryWebBrowser];
    [prefs setPlugInsEnabled:TRUE]; // Flash is required for playing sounds in certain cases
    
    [prefs _setLocalStorageDatabasePath:@"~/Library/Application Support/SoundCleod"];
    [prefs setLocalStorageEnabled:YES];
    
    [webView setPreferences:prefs];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNotification:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didPressSpaceBarKey:)
                                                               name: SCApplicationDidPressSpaceBarKey object: NULL];

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

// based on http://stackoverflow.com/questions/5177640
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles
{
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];

    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];

    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];

    // Allow multiple files
    [openDlg setAllowsMultipleSelection:allowMultipleFiles];

    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        // Do something with the filenames.
        [resultListener chooseFilenames:[openDlg filenames]];
    }
}

// stolen from MacGap
- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn)
        return YES;
    else
        return NO;
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

- (IBAction)restoreWindow:(id)sender
{
    [window makeKeyAndOrderFront:self];
}

- (IBAction)reload:(id)sender
{
    [webView reload:self];
}

- (void)next
{
    [self trigger:74];
}

- (void)prev
{
    [self trigger:75];
}

- (void)playPause
{
    [self trigger:32];
}

- (void)help
{
    [self trigger:72];
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


#pragma mark - Notifications
- (void)didPressSpaceBarKey:(NSNotification *)notification
{
    NSEvent *event = (NSEvent *)notification.object;
    [self.window sendEvent:event];
}


@end
