//
//  LastfmPromptController.h
//  SoundCleod
//
//  Created by Petr Zvoníček on 08.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastfmPromptController : NSObject

@property (assign) IBOutlet NSWindow *mainWindow;
@property (unsafe_unretained) IBOutlet NSWindow *lastfmPrompt;
@property (weak) IBOutlet NSTextField *usernameLabel;
@property (weak) IBOutlet NSTextField *passwordLabel;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSTextField *password;
@property (weak) IBOutlet NSButton *lastfmEnabled;
@property (weak) IBOutlet NSButton *okButton;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)didChangeEnabled:(id)sender;
- (IBAction)promptForLastfm:(id)sender;
- (IBAction)cancelLastfmPrompt:(id)sender;
- (IBAction)submitLastfmPrompt:(id)sender;

@end
