#import "BMAppleMikeyManager.h"
#import "DDHidAppleMikey.h"
#import "sound_up.h"

#pragma mark Private Declaration

@interface BMAppleMikeyManager ()
{
    NSArray *mikeys;            // An array of all the DDHidAppleMikey objects that are being listened to.
                                // nil if the manager is not listening.
    IOHIDManagerRef hidManager; // IOHIDManager to watch for plugging/unplugging mikey.
}

- (void) dealloc;

- (void) hidCallback;

- (void) startListeningToAllMikeys;
- (void) stopListeningToExistingMikeys;
- (void) ddhidAppleMikey:(DDHidAppleMikey *)mikey press:(unsigned int)usageId upOrDown:(BOOL)upOrDown;

- (void) mikeyDidPlayPause;
- (void) mikeyDidNext;
- (void) mikeyDidPrevious;
- (void) mikeyDidSoundUp;
- (void) mikeyDidSoundDown;

@end

#pragma mark Callback Function

static void hidCallback(void *                  context,
                        IOReturn                result,
                        void *                  sender,
                        IOHIDDeviceRef          device)
{
    CFTypeRef val = IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey));
    if(CFGetTypeID(val) == CFStringGetTypeID() && !CFStringCompare(val, CFSTR("Apple Mikey HID Driver"), 0)) {
        [(__bridge BMAppleMikeyManager *)context hidCallback];
    }
}

@implementation BMAppleMikeyManager

#pragma mark Lifecycle

- (instancetype) init
{
    if((self = [super init])) {
        // Initialize allMikeys.
        mikeys = nil;

        // Initialize IOHIDManager, watch for every HID devices.
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
        if (IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone) != kIOReturnSuccess) {
            NSLog(@"BMAppleMikeyManager: Failed to open HID Manager.");
            return nil;
        }
        
        IOHIDManagerSetDeviceMatching(hidManager, NULL);
        IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerRegisterDeviceMatchingCallback(hidManager, hidCallback, (__bridge void *)self);
        IOHIDManagerRegisterDeviceRemovalCallback(hidManager, hidCallback, (__bridge void *)self);
    }
    return self;
}

- (void) dealloc
{
    [self stopListening];
    
    // Cleaning up IOHIDManager.
    IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
    CFRelease(hidManager);
}

#pragma mark Public

- (void) startListening
{
    if(!_isListening) {
        _isListening = YES;
        [self startListeningToAllMikeys];
    }
}

- (void) stopListening
{
    if(_isListening) {
        _isListening = NO;
        [self stopListeningToExistingMikeys];
    }
}

#pragma mark IOHIDManager

- (void) hidCallback
{
    if (_isListening) {
        // Every time either plugging/unplugging Apple Mikey happens,
        // restart listening to all the existing Mikeys.
        @synchronized(self) {
            [self startListeningToAllMikeys];
        }
    }
}

#pragma mark DDHidAppleMikey

- (void) startListeningToAllMikeys
{
    // Stop listening first.
    [self stopListeningToExistingMikeys];
    
    // Gather all the mikeys.
    mikeys = [DDHidAppleMikey allMikeys];
    
    // Start listening.
    for(DDHidAppleMikey *obj in mikeys) {
        [obj setListenInExclusiveMode:YES];
        [obj setDelegate:self];
        [obj startListening];
    }
}

- (void) stopListeningToExistingMikeys
{
    if(mikeys) {
        for(DDHidAppleMikey *obj in mikeys) {
            [obj stopListening];
        }
        mikeys = nil;
    }
}

- (void) ddhidAppleMikey:(DDHidAppleMikey *)mikey press:(unsigned int)usageId upOrDown:(BOOL)upOrDown
{
   if(upOrDown) { // Up state!
       // There are five commands; from 0x89 to 0x8d.
       unsigned command = usageId - 0x89; // from 0 to 4
       
       if(command == 0) {
           [self mikeyDidPlayPause];
       } else if(command == 1) {
           [self mikeyDidNext];
       } else if(command == 2) {
           [self mikeyDidPrevious];
       } else if(command == 3) {
           [self mikeyDidSoundUp];
       } else if(command == 4) {
           [self mikeyDidSoundDown];
       }
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
