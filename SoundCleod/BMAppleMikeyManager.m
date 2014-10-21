#import "BMAppleMikeyManager.h"
#import "sound_up.h"
#import <IOKit/hid/IOHIDLib.h>
#import <Carbon/Carbon.h>

typedef NS_ENUM(NSInteger, BMAppleMikeyCommand) {
    BMAppleMikeyPlayPause = 0,
    BMAppleMikeyNext,
    BMAppleMikeyPrevious,
    BMAppleMikeySoundUp,
    BMAppleMikeySoundDown
};

#pragma mark Private Declaration

@interface BMAppleMikeyManager ()
{
    IOHIDManagerRef dummyManager;
    IOHIDManagerRef valueManager;
    NSTimer *secureTimer;
}

- (void) dealloc;

- (void) startDummyManager;
- (void) stopDummyManager;
- (void) startValueManager;
- (void) stopValueManager;
- (void) startSecureTimer;
- (void) stopSecureTimer;

- (void) dummyCallback;
- (void) valueCallback: (BMAppleMikeyCommand) command;
- (void) checkSecureEventInput;

- (void) mikeyDidPlayPause;
- (void) mikeyDidNext;
- (void) mikeyDidPrevious;
- (void) mikeyDidSoundUp;
- (void) mikeyDidSoundDown;

@end

#pragma mark Callback Function

static void dummyCallback(void *                  context,
                          IOReturn                result,
                          void *                  sender,
                          IOHIDValueRef           value)
{
    // val can be in [0, 1, 2, 3], but 1 is always the first data coming; 'down' event.
    long val = IOHIDValueGetIntegerValue(value);

    // Continue only if val is down.
    if (val == 1) {
        [(__bridge BMAppleMikeyManager *)context dummyCallback];
    }
}

static void valueCallback(void *                  context,
                          IOReturn                result,
                          void *                  sender,
                          IOHIDValueRef           value)
{
    // usage should be in range from 0x89 ~ 0x8d.
    uint32_t usage = IOHIDElementGetUsage(IOHIDValueGetElement(value));
    
    // val can be in [0, 1, 2, 3], but 1 is always the first data coming; 'down' event.
    long val = IOHIDValueGetIntegerValue(value);
    
    // Continue only if usage is in the range and val is down.
    if (usage >= 0x89 && usage <= 0x8d && val == 1) {
        [(__bridge BMAppleMikeyManager *)context valueCallback: (BMAppleMikeyCommand)(usage - 0x89)];
    }
}

@implementation BMAppleMikeyManager

#pragma mark Lifecycle

- (void) dealloc
{
    [self stopListening];
}

#pragma mark Public

- (void) startListening
{
    if(!_isListening) {
        /*
         To get commands from Apple Mikey device but not to allow any other applications to receive them, valueManager requests an exclusive access to the device. However, whenever Apple's SecureEventInput gets enabled; every time a password input field in _any_ application gets focus, the exclusivity is cancelled and never recovered. As a result, both valueManager's callback and a system daemon called rcd receive the same remote commands.
         To resolve this issue, dummyManager registers another callback in non-exclusive way, so that as soon as a command without the exclusivity is sent; its callback will also be called for the first time, valueManager can try to re-acquire the access.
         However, this solution can't prevent commands already sent to rcd while re-acquiring the exclusivity. For this problem, secureTimer periodically checks if any secure event input is enabled and takes care of the access.
         */

        [self startDummyManager];
        [self startValueManager];
        [self startSecureTimer];
        
        _isListening = YES;
    }
}

- (void) stopListening
{
    if(_isListening) {
        _isListening = NO;
        
        [self stopDummyManager];
        [self stopValueManager];
        [self stopSecureTimer];
    }
}

#pragma mark Listening

- (void) startDummyManager
{
    dummyManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    if (IOHIDManagerOpen(dummyManager, kIOHIDOptionsTypeNone) != kIOReturnSuccess) {
        NSLog(@"BMAppleMikeyManager: Failed to open dummyManager.");
    } else {
        IOHIDManagerSetDeviceMatching(dummyManager, IOServiceNameMatching("AppleMikeyHIDDriver"));
        IOHIDManagerScheduleWithRunLoop(dummyManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerRegisterInputValueCallback(dummyManager, dummyCallback, (__bridge void *)self);
    }
}

- (void) stopDummyManager
{
    IOHIDManagerClose(dummyManager, kIOHIDOptionsTypeNone);
    CFRelease(dummyManager);
    dummyManager = NULL;
}

- (void) startValueManager
{
    valueManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    if (IOHIDManagerOpen(valueManager, kIOHIDOptionsTypeSeizeDevice) != kIOReturnSuccess) {
        NSLog(@"BMAppleMikeyManager: Failed to open valueManager.");
    } else {
        IOHIDManagerSetDeviceMatching(valueManager, IOServiceNameMatching("AppleMikeyHIDDriver"));
        IOHIDManagerScheduleWithRunLoop(valueManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerRegisterInputValueCallback(valueManager, valueCallback, (__bridge void *)self);
    }
}

- (void) stopValueManager
{
    IOHIDManagerClose(valueManager, kIOHIDOptionsTypeNone);
    CFRelease(valueManager);
    valueManager = NULL;
}

- (void) startSecureTimer
{
    secureTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkSecureEventInput) userInfo:nil repeats:YES];
}

- (void) stopSecureTimer
{
    [secureTimer invalidate];
    secureTimer = nil;
}

#pragma mark Callbacks

- (void) dummyCallback
{
    if (_isListening) {
        // Re-open valueManager to re-acquire the exclusive access.
        [self stopValueManager];
        [self startValueManager];
    }
}

- (void) valueCallback: (BMAppleMikeyCommand) command
{
    if (_isListening) {
        // Route command!
        switch (command) {
            case BMAppleMikeyPlayPause:
                [self mikeyDidPlayPause];
                break;
                
            case BMAppleMikeyNext:
                [self mikeyDidNext];
                break;
                
            case BMAppleMikeyPrevious:
                [self mikeyDidPrevious];
                break;
                
            case BMAppleMikeySoundUp:
                [self mikeyDidSoundUp];
                break;
                
            case BMAppleMikeySoundDown:
                [self mikeyDidSoundDown];
                break;
        }
    }
}

- (void) checkSecureEventInput
{
    // Check if SecureEventInput is currently enabled.
    if(_isListening && IsSecureEventInputEnabled()) {
        [self dummyCallback];
    }
}

#pragma mark BMAppleMikeyManagerDelegate

- (void) mikeyDidPlayPause
{
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate mikeyDidPlayPause];
    } else {
        HIDPostAuxKey(NX_KEYTYPE_PLAY);
    }
}

- (void) mikeyDidNext
{
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate mikeyDidNext];
    } else {
        HIDPostAuxKey(NX_KEYTYPE_FAST);
    }
}

- (void) mikeyDidPrevious
{
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate mikeyDidPrevious];
    } else {
        HIDPostAuxKey(NX_KEYTYPE_REWIND);
    }
}

- (void) mikeyDidSoundUp
{
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate mikeyDidSoundUp];
    } else {
        HIDPostAuxKey(NX_KEYTYPE_SOUND_UP);
    }
}

- (void) mikeyDidSoundDown
{
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate mikeyDidSoundDown];
    } else {
        HIDPostAuxKey(NX_KEYTYPE_SOUND_DOWN);
    }
}

@end
