//
//  LastfmScrobbler.m
//  SoundCleod
//
//  Created by Petr Zvoníček on 02.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//
//  This class handles last.fm scrobbling. Parsing and cleaning SoundCloud data so as to be suitable
//  for last.fm adopted from web-scrobbler by David Sabata: https://github.com/david-sabata/web-scrobbler
//

#import "AppConstants.h"

#import "LastfmScrobbler.h"

#import "FMEngine.h"
#import "FMEngine+Cancel.h"
#import "FMEngineSession.h"
#import "FMEngineExtendedTrackParams.h"

@interface LastfmScrobbler ()

@property (nonatomic, strong) FMEngine* fmEngine;
@property (nonatomic, strong) FMEngineSession* fmSession;
@property (nonatomic, strong) FMEngineExtendedTrackParams* currentTrack;

@property (nonatomic, strong) NSDate* currentTrackStart;
@property (nonatomic, strong) NSDate* currentTrackPausedDate;
@property (nonatomic) NSTimeInterval currentTrackPauseTime;

@end

@implementation LastfmScrobbler

+ (id)sharedManager
{
    static LastfmScrobbler *sharedLastfmScrobbler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLastfmScrobbler = [[self alloc] init];
    });
    return sharedLastfmScrobbler;
}

- (id)init
{
    if (self = [super init]) {
        _fmEngine = [FMEngine engineWithApiKey:LastFMApiKey apiSecret:LastFMApiSecret];
        [self setScrobblerState:LastfmScrobblerStateDisabled];
    }
    return self;
}

- (void)authentize
{
    NSNumber* lastfmEnabled = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastfmEnabled"];
    NSString* lastfmUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastfmUsername"];
    NSString* lastfmPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastfmPassword"];
    
    if (lastfmEnabled != nil && lastfmEnabled.boolValue) {
        _fmSession = [_fmEngine sessionWithTarget:self action:@selector(sessionEstablished:) username:lastfmUsername password:lastfmPassword];
        [self setScrobblerState:LastfmScrobblerStateLoading];
    } else {
        _fmSession = nil;
        [self setScrobblerState:LastfmScrobblerStateDisabled];
    }
}

- (void)sessionEstablished:(FMEngineSession *)session
{
    _fmSession = session;

    if (session.key != nil) {
        [self setScrobblerState:LastfmScrobblerStateEnabled];
    } else {
        [self setScrobblerState:LastfmScrobblerStateFailed];
    }
}

- (void)scrobbleForArtist:(NSString*)artist track:(NSString*)title
{
    FMEngineExtendedTrackParams* params = [[FMEngineExtendedTrackParams alloc] init];
    params.artist = @"";
    params.track = @"";
    params.timestamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    [self setTrackMetadata:params forArtist:artist title:title];
     
    // check if we resume the track from pause or start a new one
    if (_currentTrack != nil && [_currentTrack.artist isEqualToString:params.artist] && [_currentTrack.track isEqualToString:params.track]) {
        [self resumeFromPause];
    } else {
        [self startTrack:params];
    }
}

#pragma mark - callbacks

// callback with track info form last.fm. If last.fm recognizes the track, save its duration and update nowPlaying status, else do not scrobble
- (void)didReceiveTrackInfoResponse:(NSString*)identifier data:(id)data
{
    if ([data isKindOfClass:[NSData class]]) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
        
        NSString* durationString = [[json objectForKey:@"track"] objectForKey:@"duration"];
        
        if (![durationString isEqualToString:@"0"]) {
            _currentTrack.duration = [NSNumber numberWithInteger:durationString.integerValue];
        }
        
        [_fmSession updateNowPlayingWithTarget:self action:@selector(didReceiveNowPlayingResponse:data:) track:_currentTrack];
    } else {
        // track was not recognized by last.fm, do not scrobble
        _currentTrack = nil;
    }
}

- (void)didReceiveNowPlayingResponse:(NSString*)identifier data:(id)data
{
}

- (void)didReceiveScrobbleResponse:(NSString*)identifier data:(id)data
{
}

#pragma mark - scrobbling

- (void)startTrack:(FMEngineExtendedTrackParams*)params
{
    // cancel all unfinished track info requests, prevents race condition
    [_fmEngine cancelTrackInfoConnections];
    
    if (_currentTrack != nil) {
        // if the track was paused, subtract the paused time from total time
        if (_currentTrackPausedDate != nil) {
            [self resumeFromPause];
        }
        
        [self scrobbleCurrentTrackIfNeeded];
    }
        
    _currentTrack = params;
    _currentTrackStart = [NSDate date];
    _currentTrackPausedDate = nil;
    _currentTrackPauseTime = 0;
    
    // get track info from last.fm and update nowPlaying status
    [_fmEngine performMethod:@"track.getInfo" withTarget:self withParameters:@{@"artist":params.artist, @"track":params.track, @"autocorrect": @"0"} andAction:@selector(didReceiveTrackInfoResponse:data:) useSignature:YES httpMethod:POST_TYPE];
}

- (void)pauseTrack
{
    _currentTrackPausedDate = [NSDate date];
    
    if (_currentTrack != nil) {
        [self scrobbleCurrentTrackIfNeeded];
    }
}

- (void)resumeFromPause
{
    if (_currentTrackPausedDate != nil) {
        _currentTrackPauseTime += [[NSDate date] timeIntervalSinceDate:_currentTrackPausedDate];
        _currentTrackPausedDate = nil;
    }
}

- (void)scrobbleCurrentTrackIfNeeded
{
    // do not scrobble if the track is already scrobbled
    if (_currentTrack.scrobbled) {
        return;
    }
    
    NSTimeInterval playedTime = [[NSDate date] timeIntervalSinceDate:_currentTrackStart];
    playedTime -= _currentTrackPauseTime;
    
    if ((playedTime > 240) || (playedTime > 30 && playedTime > (_currentTrack.convertedDuation / 2))) {
        [_fmSession scrobbleWithTarget:self action:@selector(didReceiveScrobbleResponse:data:) track:_currentTrack];
        _currentTrack.scrobbled = YES;
    }
}

#pragma mark - metadata cleaning

- (NSRange)findSeparator:(NSString*)title
{
    NSArray* separators = @[@" - ", @" – ", @"-", @"–", @":"];
    
    for (NSString* separator in separators) {
        NSRange range = [title rangeOfString:separator];
        if (range.location != NSNotFound) {
            return range;
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (void)cleanMetadata:(FMEngineExtendedTrackParams *)params
{
    NSDictionary* patterns = @{@"^\\s+|\\s+$" : @"", // cleanup
                               @"^\\d+\\.\\s*" : @"", // 12.
                               @"\\s*\\*+\\s?\\S+\\s?\\*+" : @"", // **NEW**
                               @"\\s*\\[[^\\]]+\\]" : @"", // [whatever]
                               @"\\s*\\([^\\)]*version\\)" : @"", // (whatever version)
                               @"\\s*\\.(avi|wmv|mpg|mpeg|flv)" : @"", // video extensions
                               @"\\s*(of+icial\\s*)?(music\\s*)?video" : @"", // (official)? (music)? video
                               @"\\s*\\(\\s*of+icial\\s*\\)" : @"", // (official)
                               @"\\s*\\(\\s*[0-9]{4}\\s*\\)" : @"", // (1999)
                               @"\\s+(HD|HQ)\\s*$" : @"", // HD (HQ)
                               @"\\s+\\(\\s*(HD|HQ)\\s*\\)" : @"", // HD (HQ)
                               @"\\s*video\\s*clip" : @"", // video clip
                               @"\\(\\s*\\)" : @"", // Leftovers after e.g. (official video)
                               @"^(|.*\\s)\"(.*)\"(\\s.*|)" : @"$2", // Artist - The new "Track title" featuring someone
                               @"^(|.*\\s)'(.*)'(\\s.*|)" : @"$2", // 'Track title'
                               @"^[\\/\\s,:;~-]+" : @"", // trim starting white chars and dash
                               @"[\\/\\s,:;~-]+$" : @"", // trim starting white chars and dash
                               @"\\s*\\([^\\)]*download\\)" : @"" // (FREE DOWNLOAD)
                               };
    
    // clean artist
    NSRegularExpression* artistRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\s+|\\s+$" options:NSRegularExpressionCaseInsensitive error:nil];
    params.artist = [artistRegex stringByReplacingMatchesInString:params.artist options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, params.artist.length) withTemplate:@""];
    
    // clean track
    [patterns enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:key options:NSRegularExpressionCaseInsensitive error:nil];
        params.track = [regex stringByReplacingMatchesInString:params.track options:0 range:NSMakeRange(0, params.track.length) withTemplate:obj];
    }];
}

- (void)setTrackMetadata:(FMEngineExtendedTrackParams *)params forArtist:(NSString*)username title:(NSString*)title
{
    // clean song name from potential track No. e.g. 01 - The Cool Song
    NSRegularExpression* artistRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+(\\.|\\s?-|\\s)\\s*" options:NSRegularExpressionCaseInsensitive error:nil];
    title = [artistRegex stringByReplacingMatchesInString:title options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, title.length) withTemplate:@""];
    
    NSRange separatorRange = [self findSeparator:title];
    
    // if the artist name is in the track title
    if (separatorRange.location != NSNotFound) {
        params.artist = [title substringToIndex:separatorRange.location];
        params.track = [title substringFromIndex:separatorRange.location + separatorRange.length];
    }
    
    if ([params.artist isEqualToString:@""]) {
        params.artist = username;
    }
    
    if ([params.track isEqualToString:@""]) {
        params.track = title;
    }
    
    [self cleanMetadata:params];
}

@end
