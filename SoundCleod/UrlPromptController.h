//
//  UrlPromptController.h
//  SoundCleod
//
//  Created by Márton Salomváry on 2013/01/17.
//  Copyright (c) 2013 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NavigateDelegate <NSObject>
@required
- (void) navigate: (NSString*) url;
@end

@interface UrlPromptController : NSObject
{
    id <NavigateDelegate> navigateDelegate;
}

@property (assign) IBOutlet NSWindow *mainWindow;
@property (unsafe_unretained) IBOutlet NSWindow *urlPrompt;
@property (unsafe_unretained) IBOutlet NSTextField *urlInput;
@property (unsafe_unretained) IBOutlet NSTextField *urlError;
@property (retain) id navigateDelegate;

- (IBAction)promptForUrl:(id)sender;
- (IBAction)closeUrlPrompt:(id)sender;
@end
