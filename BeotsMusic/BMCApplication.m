//
//  SCDApplication.m
//  SoundCleod
//
//  Created by Rafif Yalda on 2013/06/05.
//  Copyright (c) 2013 Rafif Yalda. All rights reserved.
//


#import "AppConstants.h"
#import "BMCApplication.h"


@implementation BMCApplication


- (void)sendEvent:(NSEvent *)theEvent
{
    if (theEvent.type == NSKeyDown &&
        theEvent.keyCode == 49)
    {
        // Handle the space-bar, even if the window is closed
        [[[NSWorkspace sharedWorkspace] notificationCenter] postNotificationName:BMApplicationDidPressSpaceBarKey object:theEvent];
        return;
    }

    [super sendEvent:theEvent];
}


@end
