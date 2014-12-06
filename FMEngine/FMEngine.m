//
//  FMEngine.m
//  LastFMAPI
//
//  Created by Nicolas Haunold on 4/26/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import "FMEngine.h"
#import "FMCallback.h"
#import "FMEngineURLConnection.h"

@implementation FMEngine

static NSInteger sortAlpha(NSString *n1, NSString *n2, void *context) {
	return [n1 caseInsensitiveCompare:n2];
}

- (id)init {
	if (self = [super init]) {
		connections = [[NSMutableDictionary alloc] init];
	}
	return self;	
}

+ (FMEngine *)engineWithApiKey:(NSString *)key apiSecret:(NSString *)secret {
    FMEngine *engine = [[FMEngine alloc] init];
    engine.apiKey = key;
    engine.apiSecret = secret;
    return engine;
}

- (NSURLRequest *)requestForMethod:(NSString *)method withParameters:(NSDictionary *)params useSignature:(BOOL)useSig httpMethod:(NSString *)httpMethod {
	NSMutableURLRequest *request;
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:params];
	
    [tempDict setObject:self.apiKey forKey:@"api_key"];
	[tempDict setObject:method forKey:@"method"];
	if (useSig) {
		NSString *dataSig = [self generateSignatureFromDictionary:tempDict];
		[tempDict setObject:dataSig forKey:@"api_sig"];
	}
    
#ifdef _USE_JSON_
	if(![httpMethod isPOST]) {
		[tempDict setObject:@"json" forKey:@"format"];
	}
#endif
    
	params = [NSDictionary dictionaryWithDictionary:tempDict];
    
    if(![httpMethod isPOST]) {
		NSURL *dataURL = [self generateURLFromDictionary:params];
		request = [NSURLRequest requestWithURL:dataURL];
	} else {
#ifdef _USE_JSON_
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_LASTFM_BASEURL_ stringByAppendingString:@"?format=json"]]];
#else
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_LASTFM_BASEURL_]];
#endif
		[request setHTTPMethod:httpMethod];
		[request setHTTPBody:[[self generatePOSTBodyFromDictionary:params] dataUsingEncoding:NSUTF8StringEncoding]];
	}
    
    return request;
}

- (void)performMethod:(NSString *)method withTarget:(id)target withParameters:(NSDictionary *)params andAction:(SEL)callback useSignature:(BOOL)useSig httpMethod:(NSString *)httpMethod {
    NSURLRequest *request = [self requestForMethod:method withParameters:params useSignature:useSig httpMethod:httpMethod];

	FMEngineURLConnection *connection = [[FMEngineURLConnection alloc] initWithRequest:request];
	NSString *connectionId = [connection identifier];
	connection.callback = [FMCallback callbackWithTarget:target action:callback userInfo:nil object:connectionId];
	
	if(connection) {
		[connections setObject:connection forKey:connectionId];
	}

}

- (NSData *)dataForMethod:(NSString *)method withParameters:(NSDictionary *)params useSignature:(BOOL)useSig httpMethod:(NSString *)httpMethod error:(NSError **)err {
    NSURLRequest *request = [self requestForMethod:method withParameters:params useSignature:useSig httpMethod:httpMethod];
	NSData *returnData = [FMEngineURLConnection sendSynchronousRequest:request returningResponse:nil error:err];
	return returnData;
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
	return result;
}

- (NSString *)urlEncodedStringWithParameters:(NSDictionary *)params {
    NSMutableArray *encodedParams = [NSMutableArray arrayWithCapacity:params.count];
    Class stringClass = NSString.class;
	for (NSString *key in params) {
		id val = [params objectForKey:key];
		if ([val isKindOfClass:stringClass]) {
			val = [self urlEncodeValue:val];
		}
        [encodedParams addObject:[NSString stringWithFormat:@"%@=%@", key, val]];
	}
    return [encodedParams componentsJoinedByString:@"&"];
}

- (NSString *)generatePOSTBodyFromDictionary:(NSDictionary *)dict {
    return [self urlEncodedStringWithParameters:dict];
}

- (NSURL *)generateURLFromDictionary:(NSDictionary *)dict {
	NSString *encodedURL = [NSString stringWithFormat:@"%@?%@", _LASTFM_BASEURL_, [self urlEncodedStringWithParameters:dict]];
	NSURL *url = [NSURL URLWithString:encodedURL];
    return url;
}

- (NSString *)generateSignatureFromDictionary:(NSDictionary *)dict {
	NSMutableArray *aMutableArray = [[NSMutableArray alloc] initWithArray:[dict allKeys]];
	NSMutableString *rawSignature = [[NSMutableString alloc] init];
	[aMutableArray sortUsingFunction:sortAlpha context:(__bridge void *)self];
	
	for(NSString *key in aMutableArray) {
		[rawSignature appendString:[NSString stringWithFormat:@"%@%@", key, [dict objectForKey:key]]];
	}
	
	[rawSignature appendString:self.apiSecret];
	
	NSString *signature = [rawSignature md5sum];
	
	return signature;
}

- (void)dealloc {
	[[connections allValues] makeObjectsPerformSelector:@selector(cancel)];
}

@end