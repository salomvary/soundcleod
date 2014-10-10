//
//  FMEngineExtendedTrackParams.h
//  SoundCleod
//
//  Created by Petr Zvoníček on 08.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import "FMEngineTrackParams.h"

@interface FMEngineExtendedTrackParams : FMEngineTrackParams

@property BOOL scrobbled;

- (double)convertedDuation;

@end


