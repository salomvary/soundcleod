//
//  FMEngineURLConnection.h
//  LastFMAPI
//
//  Created by Nicolas Haunold on 4/28/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+FMEngine.h"
#import "FMCallback.h"

@interface FMEngineURLConnection : NSURLConnection;

@property (nonatomic, strong) FMCallback *callback;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate;
- (id)initWithRequest:(NSURLRequest *)request;
- (void)appendData:(NSData *)moreData;
- (NSData *)data;
- (NSString *)identifier;

@end