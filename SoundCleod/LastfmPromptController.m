//
//  LastfmPromptController.m
//  SoundCleod
//
//  Created by Petr Zvoníček on 08.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import "LastfmPromptController.h"
#import "LastfmScrobbler.h"

@implementation LastfmPromptController

-(void)awakeFromNib
{
    [_progressIndicator setDisplayedWhenStopped:NO];
    [self loadSavedState];
    [self reloadStatusTextField];
}

- (void)loadSavedState
{
    NSNumber* lastfmEnabled = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastfmEnabled"];
    NSString* lastfmUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastfmUsername"];
    NSString* lastfmPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastfmPassword"];
    
    if (lastfmEnabled == nil || !lastfmEnabled.boolValue) {
        _lastfmEnabled.state = NSOffState;
    } else {
        _lastfmEnabled.state = NSOnState;
    }
    
    if (lastfmUsername != nil) {
        [_username setStringValue:lastfmUsername];
    } else {
        [_username setStringValue:@""];
    }
    
    if (lastfmPassword != nil) {
        [_password setStringValue:lastfmPassword];
    } else {
        [_password setStringValue:@""];
    }
    
    [self setEnabledState];
}

- (void)setEnabledState
{
    if (_lastfmEnabled.state == NSOffState) {
        _usernameLabel.textColor = [NSColor disabledControlTextColor];
        _passwordLabel.textColor = [NSColor disabledControlTextColor];
        _username.textColor = [NSColor disabledControlTextColor];
        _password.textColor = [NSColor disabledControlTextColor];
        [_username setEditable:NO];
        [_password setEditable:NO];
        [_username setStringValue:@""];
        [_password setStringValue:@""];
    } else {
        _usernameLabel.textColor = [NSColor controlTextColor];
        _passwordLabel.textColor = [NSColor controlTextColor];
        _username.textColor = [NSColor controlTextColor];
        _password.textColor = [NSColor controlTextColor];
        [_username setEditable:YES];
        [_password setEditable:YES];
    }
}

- (IBAction)didChangeEnabled:(id)sender
{
    [self setEnabledState];
}

- (void)reloadStatusTextField
{
    switch ([[LastfmScrobbler sharedManager] scrobblerState]) {
        case LastfmScrobblerStateDisabled:
            [_status setStringValue:@"Disabled"];
            break;
        case LastfmScrobblerStateEnabled:
            [_status setStringValue:@"Logged in"];
            break;
        case LastfmScrobblerStateFailed:
            [_status setStringValue:@"Login failed"];
            break;
        case LastfmScrobblerStateLoading:
            [_status setStringValue:@"Logging in"];
            break;
        default:
            [_status setStringValue:@""];
            break;
    }
}

#pragma mark Controller presentation

- (IBAction)promptForLastfm:(id)sender
{
    if(_lastfmPrompt == nil) {
        [NSBundle loadNibNamed:@"LastfmPrompt" owner:self];
    }
    
    [[LastfmScrobbler sharedManager] addObserver:self forKeyPath:@"scrobblerState" options:0 context:nil];
    
    [NSApp beginSheet: [self lastfmPrompt]
       modalForWindow: [self mainWindow]
        modalDelegate: self
       didEndSelector: @selector(lastfmPromptDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
}

- (IBAction)cancelLastfmPrompt:(id)sender
{
    [_okButton setEnabled:YES];
    [_progressIndicator stopAnimation:nil];

    [self loadSavedState];
    [self hideLastfmPrompt];
}

- (IBAction)submitLastfmPrompt:(id)sender
{
    NSNumber* isEnabled = [NSNumber numberWithBool:_lastfmEnabled.state != NSOffState];
    
    [[NSUserDefaults standardUserDefaults] setValue:isEnabled forKey:@"lastfmEnabled"];
    [[NSUserDefaults standardUserDefaults] setValue:_username.stringValue forKey:@"lastfmUsername"];
    [[NSUserDefaults standardUserDefaults] setValue:_password.stringValue forKey:@"lastfmPassword"];
    
    [_okButton setEnabled:NO];
    [_progressIndicator startAnimation:nil];
    
    [[LastfmScrobbler sharedManager] authentize];
}

- (void)hideLastfmPrompt
{
    [[LastfmScrobbler sharedManager] removeObserver:self forKeyPath:@"scrobblerState"];
    [_lastfmPrompt orderOut:self];
    [NSApp endSheet:_lastfmPrompt returnCode:NSOKButton];
}

- (void)lastfmPromptDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSCancelButton) return;
}

#pragma mark KVO handling

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    LastfmScrobblerState state = [[LastfmScrobbler sharedManager] scrobblerState];
    
    if (state != LastfmScrobblerStateLoading) {
        [_okButton setEnabled:YES];
        [_progressIndicator stopAnimation:nil];
    }
    
    if (state == LastfmScrobblerStateEnabled || state == LastfmScrobblerStateDisabled) {
        [self hideLastfmPrompt];
    }
    
    [self reloadStatusTextField];
}

@end
