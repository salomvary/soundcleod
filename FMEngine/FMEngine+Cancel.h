//
//  FMEngine+Cancel.h
//  SoundCleod
//
//  Created by Petr Zvoníček on 08.10.14.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMEngine.h"

@interface FMEngine (Cancel)

- (void)cancelAllConnections;
- (void)cancelNonScrobbleConnections;

@end
