//
//  NSString+UUID.h
//  LastFMAPI
//
//  Created by Nicolas Haunold on 4/26/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UUID)
+ (NSString *)stringWithNewUUID;
- (NSString *)md5sum;
- (BOOL)isPOST;
@end
