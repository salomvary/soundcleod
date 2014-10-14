//
//  AppConstants.h
//  SoundCleod
//
//  Created by Márton Salomváry on 2013/01/17.
//  Copyright (c) 2013 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SCKeyCode) {
    SCKeyCodeNext = 74,
    SCKeyCodePrevious = 75,
    SCKeyCodePlayPause = 32,
    SCKeyCodeHelp = 72
};

extern NSString *const SCHost;
extern NSString *const SCApplicationDidPressSpaceBarKey;
extern NSString *const LastFMApiKey;
extern NSString *const LastFMApiSecret;
