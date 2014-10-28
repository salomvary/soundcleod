//
//  FMEngineExtendedTrackParams.m
//  SoundCleod
//
//  Created by Petr Zvoníček on 08.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import "FMEngineExtendedTrackParams.h"

@implementation FMEngineExtendedTrackParams

- (double)convertedDuration
{
    if (self.duration != nil) {
        return self.duration.doubleValue;
    } else {
        return 0;
    }
}

@end

