//
//  UrlService.h
//  SoundCleod
//
//  Created by Joel Ekström on 2014-10-27.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCURLServiceDelegate;

@interface SCURLService : NSObject

- (void)openURL:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;
@property (nonatomic, weak) id <SCURLServiceDelegate> delegate;

@end

@protocol SCURLServiceDelegate <NSObject>

- (void)URLService:(SCURLService *)service didReceiveURL:(NSURL *)URL;

@end