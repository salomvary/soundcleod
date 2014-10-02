//
//  FMCallback.m
//  FMEngine
//
//  Created by Nicolas Haunold on 5/2/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import "FMCallback.h"

@implementation FMCallback
@synthesize target = _target;
@synthesize selector = _selector;
@synthesize userInfo = _userInfo;
@synthesize identifier = _identifier;

+ (id)callbackWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo {
	return [[FMCallback alloc] initWithTarget:target action:action userInfo:userInfo];
}

+ (id)callbackWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo object:(id)identifier {
	return [[FMCallback alloc] initWithTarget:target action:action userInfo:userInfo object:identifier];
}

- (id)initWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo {
	self = [super init];
	if(self) {
		_target = target;
		_selector = action;
		_userInfo = userInfo;
	}
	
	return self;
}

- (id)initWithTarget:(id)target action:(SEL)action userInfo:(id)userInfo object:(id)identifier {
	self = [super init];
	if(self) {
		_target = target;
		_selector = action;
		_userInfo = userInfo;
		_identifier = identifier;
	}
	
	return self;
}

- (void)fire {
	if(_identifier == nil) {
		[_target performSelector:_selector withObject:_userInfo];
	} else {
		[_target performSelector:_selector withObject:_identifier withObject:_userInfo];
	}
}


@end
