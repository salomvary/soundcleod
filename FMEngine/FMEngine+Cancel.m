//
//  FMEngine+Cancel.m
//  SoundCleod
//
//  Created by Petr Zvoníček on 08.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import "FMEngine+Cancel.h"
#import "FMEngineURLConnection.h"

@implementation FMEngine (Cancel)

- (void)cancelAllConnections
{
    [[connections allValues] makeObjectsPerformSelector:@selector(cancel)];
}

-(void)cancelNonScrobbleConnections
{
    [connections enumerateKeysAndObjectsUsingBlock:^(NSString* key, FMEngineURLConnection* obj, BOOL *stop) {
        if (obj.callback.selector != @selector(didReceiveScrobbleResponse:data:)) {
            [obj cancel];
            NSLog(@"cancel %@", obj.identifier);
        } else {
            NSLog(@"do not cancel %@", obj.identifier);
        }
    }];
}

@end