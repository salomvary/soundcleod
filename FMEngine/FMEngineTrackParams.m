//
//  FMEngineTrackParams.m
//  FMEngine
//
//  Created by boo on 2013-11-19.
//  Copyright (c) 2013 Darktree. All rights reserved.
//

#import "FMEngineTrackParams.h"

@implementation FMEngineTrackParams

+ (FMEngineTrackParams *)paramsWithArtist:(NSString *)artist track:(NSString *)track {
    FMEngineTrackParams *params = [[FMEngineTrackParams alloc] init];
    params.artist = artist;
    params.track = track;
    return params;
}

- (NSDictionary *)asDict {
    return [self asDictWithKeyFormat:@"%@"];
}

- (NSDictionary *)asDictWithIndex:(NSUInteger)index {
    NSString *keyFormat = [NSString stringWithFormat:@"%%@[%u]", index];
    return [self asDictWithKeyFormat:keyFormat];
}

- (NSDictionary *)asDictWithKeyFormat:(NSString *)keyFormat {
    NSArray *keys = @[@"artist", @"track", @"album", @"trackNumber", @"context", @"mbid", @"duration", @"albumArtist", @"sk", @"timestamp", @"streamId", @"chosenByUser"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (NSString *key in keys) {
        id val = [self valueForKey:key];
        if (val) {
            [dict setObject:val forKey:[NSString stringWithFormat:keyFormat, key]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end