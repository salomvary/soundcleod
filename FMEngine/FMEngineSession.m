//
//  FMEngineSession.m
//  FMEngine
//
//  Created by boo on 2013-11-19.
//  Copyright (c) 2013 Darktree. All rights reserved.
//

#import "FMEngineSession.h"
#import "FMEngineTrackParams.h"
#import "FMCallback.h"

@interface FMEngineSession ()

@property (nonatomic, strong) FMCallback *callback;

+ (NSString *)keyFromJSONData:(NSData *)data;
- (void)gotMobileSession:(NSString *)identifier data:(id)data;

@end

@implementation FMEngine (Session)

- (FMEngineSession *)sessionWithUsername:(NSString *)username password:(NSString *)password {
    NSData *data = [self dataForMethod:@"auth.getMobileSession" withParameters:@{@"password": password, @"username": username} useSignature:YES httpMethod:POST_TYPE error:nil];
    return [FMEngineSession sessionWithEngine:self key:[FMEngineSession keyFromJSONData:data]];
}

- (FMEngineSession *)sessionWithTarget:(id)target action:(SEL)callback username:(NSString *)username password:(NSString *)password {
    FMEngineSession *session = [FMEngineSession sessionWithEngine:self key:nil];
    session.callback = [FMCallback callbackWithTarget:target action:callback userInfo:nil];
    [self performMethod:@"auth.getMobileSession" withTarget:session withParameters:@{@"password": password, @"username": username} andAction:@selector(gotMobileSession:data:) useSignature:YES httpMethod:POST_TYPE];
    return session;
}

@end

@implementation FMEngineSession

+ (FMEngineSession *)sessionWithEngine:(FMEngine *)engine key:(NSString *)key {
    FMEngineSession *session = [[FMEngineSession alloc] init];
    session.key = key;
    session.engine = engine;
    return session;
}


+ (NSString *)keyFromJSONData:(NSData *)data {
    NSString *key;
    if (data) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *sessionData = [json objectForKey:@"session"];
        key = [sessionData objectForKey:@"key"];
    }
    return key;
}

- (void)gotMobileSession:(NSString *)identifier data:(id)data {
    self.key = [FMEngineSession keyFromJSONData:data];
    self.callback.identifier = self;
    [self.callback fire];
}

- (void)updateNowPlayingWithTarget:(id)target action:(SEL)callback track:(FMEngineTrackParams *)params {
    params.sk = self.key;
    [self.engine performMethod:@"track.updateNowPlaying" withTarget:target withParameters:[params asDict] andAction:callback useSignature:YES httpMethod:POST_TYPE];
}

- (void)scrobbleWithTarget:(id)target action:(SEL)callback track:(FMEngineTrackParams *)params {
    params.sk = self.key;
    [self.engine performMethod:@"track.scrobble" withTarget:target withParameters:[params asDict] andAction:callback useSignature:YES httpMethod:POST_TYPE];
}

- (void)scrobbleManyWithTarget:(id)target action:(SEL)callback tracks:(NSArray *)trackList {
    if (trackList.count > 50) {
        [NSException raise:@"TrackListTooLarge" format:@"Cannot scrobble more than 50 tracks at once."];
    }
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithCapacity:1 + trackList.count * 3]; // there are 3 unique mandatory parameters, so allParams will be at least 3 * trackList.count + 1 for the session key
    [allParams setObject:self.key forKey:@"sk"];
    for (unsigned i = 0, e = trackList.count; i < e; ++i) {
        FMEngineTrackParams *trackParams = [trackList objectAtIndex:i];
        [allParams addEntriesFromDictionary:[trackParams asDictWithIndex:i]];
    }
    [self.engine performMethod:@"track.scrobble" withTarget:target withParameters:allParams andAction:callback useSignature:YES httpMethod:POST_TYPE];
}

@end
