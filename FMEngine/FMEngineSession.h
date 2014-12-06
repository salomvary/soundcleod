//
//  FMEngineSession.h
//  FMEngine
//
//  Created by boo on 2013-11-19.
//  Copyright (c) 2013 Darktree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMEngine.h"

@class FMEngineSession, FMEngineTrackParams;

@interface FMEngine (Session)

- (FMEngineSession *)sessionWithUsername:(NSString *)username password:(NSString *)password;
- (FMEngineSession *)sessionWithTarget:(id)target action:(SEL)callback username:(NSString *)username password:(NSString *)password;

@end

@interface FMEngineSession : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, weak) FMEngine *engine;

+ (FMEngineSession *)sessionWithEngine:(FMEngine *)engine key:(NSString *)key;

- (void)updateNowPlayingWithTarget:(id)target action:(SEL)callback track:(FMEngineTrackParams *)trackParams;
- (void)scrobbleWithTarget:(id)target action:(SEL)callback track:(FMEngineTrackParams *)trackParams;
- (void)scrobbleManyWithTarget:(id)target action:(SEL)callback tracks:(NSArray *)trackList;

@end
