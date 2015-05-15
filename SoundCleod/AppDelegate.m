//
//  AppDelegate.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2012/12/11.
//  Copyright (c) 2012 Márton Salomváry. All rights reserved.
//

#import "AppConstants.h"
#import "AppDelegate.h"
#import "NSURL+SCUtils.h"

NSString *const SCTriggerJS = @"e=new Event('keydown');e.keyCode=%d;document.dispatchEvent(e)";
NSString *const SCNavigateJS = @"history.replaceState(null, null, '%@');e=new Event('popstate');window.dispatchEvent(e)";


@interface WebPreferences (WebPreferencesPrivate)
- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void) setLocalStorageEnabled: (BOOL) localStorageEnabled;
@end

@interface AppDelegate()

@property BOOL applicationHasFinishedLaunching;
@property (nonatomic, strong) NSURL *appLaunchURL;

@end

@implementation AppDelegate

+ (void)initialize;
{
	if([self class] != [AppDelegate class]) return;
    
	// Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                             nil]];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Set up so we can handle cleod:// url's
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

//
// Handles cleod:// url's
//
- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];

    NSURL *url = [NSURL URLWithString:urlString];

    //
    // Ignore invalid URL's
    //
    if (!url) {
        return;
    }

    //
    // Handle soundcloud URL's by replacing the "cleod"-scheme with "https", and then loading
    // them normally
    //
    if ([url isSoundCloudURL]) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
        components.scheme = @"https";
        NSURL *actualURL = [components URL];

        if (_applicationHasFinishedLaunching) {
            [self navigate:actualURL.absoluteString];
        } else {
            self.appLaunchURL = actualURL;
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_window setFrameAutosaveName:@"SoundCleod"];
    
    self.mediaKeyListener = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[_mediaKeyListener startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");

    self.mikeyManager = [[AppleMikeyManager alloc] init];
    _mikeyManager.delegate = self;
    [_mikeyManager startListening];
    
    //
    // Set up base URL. It prefers any URL stored in user defaults
    //
    NSURL *storedBaseURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"BaseUrl"]];
    if (storedBaseURL) {
        self.baseURL = storedBaseURL;
    } else {
        self.baseURL = [NSURL URLWithString: [@"https://" stringByAppendingString:SCHost]];
    }

    // Fake UserAgent to real Safari so that brower sniffing does not break (needed for Flash-free playback)
    [_webView setCustomUserAgent: @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/7.1.6 Safari/537.85.15"];

    NSURL *urlToLoad = _appLaunchURL ? _appLaunchURL : _baseURL;
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:urlToLoad]];
    
    WebPreferences *prefs = [WebPreferences standardPreferences];
    
    [prefs setCacheModel:WebCacheModelPrimaryWebBrowser];
    [prefs setPlugInsEnabled:FALSE]; // Prevent loading outdated and disabled Flash plugin (and everything else too:)
    
    [prefs _setLocalStorageDatabasePath:@"~/Library/Application Support/SoundCleod"];
    [prefs setLocalStorageEnabled:YES];
    
    [_webView setPreferences:prefs];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNotification:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didPressSpaceBarKey:)
                                                               name: SCApplicationDidPressSpaceBarKey object: NULL];

    [_window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    _applicationHasFinishedLaunching = YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if(_mikeyManager && _mikeyManager.isListening) {
        [_mikeyManager stopListening];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag == NO)
    {
        [_window makeKeyAndOrderFront:self];
    }

    return YES;
}


- (void)awakeFromNib
{
    [_webView setUIDelegate:self];
    [_webView setFrameLoadDelegate:self];
    [_webView setPolicyDelegate:self];

    // Workaround for a bug in OSX 10.10 - fixed elements do not work
    // https://bugs.webkit.org/show_bug.cgi?id=137851#c2
    // Credits: https://github.com/scosman
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)])
    {
        // TODO - put an upper limit on this fix once this bug is fixed in OSX since it introduces some flicker
        NSOperatingSystemVersion operatingSystemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
        if (operatingSystemVersion.majorVersion == 10 && operatingSystemVersion.minorVersion == 10)
        {
            [_webView setWantsLayer:YES];
        }
    }

    [_urlPromptController setNavigateDelegate:self];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSScrollView *mainScrollView = [[[[sender mainFrame] frameView] documentView] enclosingScrollView];
    [mainScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    [mainScrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    // request will always be null (probably a bug)
    return [_popupController show];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [_webView mainFrame]) {
        [_window setTitle:title];
        if ([self isPlaying]) {
            title = [title stringByReplacingOccurrencesOfString:@"▶ " withString:@""];
            NSArray *info = [title componentsSeparatedByString:@" by "];
            if (info.count == 1) {
                // current track is part of a set
                info = [title componentsSeparatedByString:@" in "];
            }
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = info[0]; // track
            notification.informativeText = info[1]; // artist
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    // normal in-frame navigation
    if(frame != [_webView mainFrame] || [[request URL] isSoundCloudURL]) {
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
    if([[request URL] isSoundCloudURL]) {
        // open local links in the main frame
        // TODO: maybe maintain a frame stack instead?
        [[_webView mainFrame] loadRequest: [NSURLRequest requestWithURL:
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
    if ( [openDlg runModal] == NSOKButton )
    {
		NSArray *urls = [openDlg URLs];
		NSArray *filenames = [urls valueForKey:@"path"];
        // Do something with the filenames.
        [resultListener chooseFilenames:filenames];
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

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    
    NSMenu *dockMenu = [[NSMenu alloc] init];
    
    NSMenuItem *pausePlayItem = [[NSMenuItem alloc] init];
    pausePlayItem.target = self;
    pausePlayItem.action = @selector(playPause);
    pausePlayItem.title = [self isPlaying] ? NSLocalizedString(@"Pause", @"") : NSLocalizedString(@"Play", @"");
    [dockMenu addItem:pausePlayItem];
    
    [dockMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *nextItem = [[NSMenuItem alloc] init];
    nextItem.target = self;
    nextItem.action = @selector(next);
    nextItem.title = NSLocalizedString(@"Next", @"");
    [dockMenu addItem:nextItem];
    
    NSMenuItem *previousItem = [[NSMenuItem alloc] init];
    previousItem.target = self;
    previousItem.action = @selector(prev);
    previousItem.title = NSLocalizedString(@"Previous", @"");
    [dockMenu addItem:previousItem];
    
    return dockMenu;
}


- (IBAction)showHelp:(id)sender
{
    [self help];
}

- (IBAction)restoreWindow:(id)sender
{
    [_window makeKeyAndOrderFront:self];
}

- (IBAction)reload:(id)sender
{
    [_webView reload:self];
}

- (IBAction)next:(id)sender
{
    [self next];
}

- (IBAction)prev:(id)sender
{
    [self prev];
}

- (IBAction)playPause:(id)sender
{
    [self playPause];
}

- (IBAction)home:(id)sender
{
    [self navigate:@"/"];
}

- (void)next
{
    [self trigger:SCKeyCodeNext];
}

- (void)prev
{
    [self trigger:SCKeyCodePrevious];
}

- (void)playPause
{
    [self trigger:SCKeyCodePlayPause];
}

- (void)help
{
    [self trigger:SCKeyCodeHelp];
}

- (void)trigger:(SCKeyCode)keyCode
{
    NSString *js = [NSString stringWithFormat:SCTriggerJS, (int)keyCode];
    [_webView stringByEvaluatingJavaScriptFromString:js];
}

- (BOOL)isPlaying
{
    // FIXME find a better way to detect playing
    NSString *title = [_window title];
    return [title rangeOfString:@"▶"].location != NSNotFound;
}

- (void)navigate:(NSString*)permalink
{
    NSString *js = [NSString stringWithFormat:SCNavigateJS, permalink];
    [_webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - Notifications
- (void)didPressSpaceBarKey:(NSNotification *)notification
{
    [self playPause];
}

#pragma mark - BMAppleMikeyManagerDelegate

- (void) mikeyDidPlayPause
{
    [self playPause];
}

- (void) mikeyDidNext
{
    [self next];
}

- (void) mikeyDidPrevious
{
    [self prev];
}

@end
