//
//  LastfmScrobbler.h
//  SoundCleod
//
//  Created by Petr Zvoníček on 02.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LastfmScrobblerState) {
    LastfmScrobblerStateDisabled,
    LastfmScrobblerStateLoading,
    LastfmScrobblerStateEnabled,
    LastfmScrobblerStateFailed
};

@interface LastfmScrobbler : NSObject

@property (nonatomic, assign) LastfmScrobblerState scrobblerState;

+ (id)sharedManager;
- (void)authentize;
- (void)scrobbleForArtist:(NSString*)artist track:(NSString*)title;
- (void)pauseTrack;

@end
