//
//  NSURL+SCUtils.m
//  SoundCleod
//
//  Created by Joel Ekström on 2014-09-25.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import "NSURL+SCUtils.h"
#import "AppConstants.h"
#import "AppDelegate.h"

@implementation NSURL(SCUtils)

- (BOOL)isSoundCloudURL
{
    AppDelegate *sharedDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSURL *baseURL = sharedDelegate.baseURL;
    return [[self host] isEqualToString:SCHost] || [[self host] isEqualToString:[baseURL host]];
}


@end
