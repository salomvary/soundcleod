//
//  UrlPromptController.m
//  SoundCleod
//
//  Created by Márton Salomváry on 2013/01/17.
//  Copyright (c) 2013 Márton Salomváry. All rights reserved.
//

#import "AppConstants.h"
#import "UrlPromptController.h"
#import "NSURL+SCUtils.h"

@implementation UrlPromptController

@synthesize mainWindow;
@synthesize urlPrompt;
@synthesize urlInput;
@synthesize urlError;
@synthesize navigateDelegate;

- (IBAction)promptForUrl:(id)sender
{
    if(urlPrompt == nil) {
        [NSBundle loadNibNamed:@"UrlPrompt" owner:self];
    }
    [NSApp beginSheet: [self urlPrompt]
       modalForWindow: [self mainWindow]
        modalDelegate: self
       didEndSelector: @selector(urlPromptDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
    [urlInput becomeFirstResponder];
}

- (IBAction)closeUrlPrompt:(id)sender
{
    NSString *value = [[urlInput stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *permalink = nil;
    NSString *error = nil;
    [urlError setHidden:TRUE];
    
    if([sender tag] == 1) {
        if(value.length > 0) {
            NSURL *url = [NSURL URLWithString:value];
            if(url != nil) {
                if([url host] != nil) {
                    if([url isSoundCloudURL]) {
                        permalink = [url path];
                    } else {
                        error = @"This is not a SoundCloud link";
                    }
                } else {
                    permalink = [url path];
                }
            } else {
                permalink = value;
            }
        }
        if(permalink != nil) {
            if([permalink characterAtIndex:0] != '/') {
                permalink = [@"/" stringByAppendingString: permalink];
            }
            [[self navigateDelegate] navigate:permalink];
            [urlInput setStringValue:@""];
            [urlPrompt orderOut:self];
            [NSApp endSheet:urlPrompt returnCode:NSOKButton];
        } else if(error != nil) {
            [urlError setStringValue:error];
            [urlError setHidden:FALSE];
        }
    } else {
        [urlInput setStringValue:@""];
        [urlPrompt orderOut:self];
        [NSApp endSheet:urlPrompt returnCode:NSCancelButton];
    }
    
}

- (void)urlPromptDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSCancelButton) return;
}

@end
