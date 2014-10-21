//
//  Created by
//      George Warner
//      Casey Fleser http://www.somegeekintn.com/blog/2006/03/universal-mediakeys/
//
//  Stolen from http://stackoverflow.com/questions/10273159
//

#import "sound_up.h"

io_connect_t get_event_driver(void)
{
    static  mach_port_t sEventDrvrRef = 0;
    mach_port_t masterPort, service, iter;
    kern_return_t    kr;
    
    if (!sEventDrvrRef)
    {
        // Get master device port
        kr = IOMasterPort( bootstrap_port, &masterPort );
        NSCAssert((KERN_SUCCESS == kr), @"IOMasterPort failed.");
        
        kr = IOServiceGetMatchingServices( masterPort, IOServiceMatching( kIOHIDSystemClass ), &iter );
        NSCAssert((KERN_SUCCESS == kr), @"IOServiceGetMatchingServices failed.");
        
        service = IOIteratorNext( iter );
        NSCAssert((KERN_SUCCESS == kr), @"IOIteratorNext failed.");
        
        kr = IOServiceOpen( service, mach_task_self(),
                           kIOHIDParamConnectType, &sEventDrvrRef );
        NSCAssert((KERN_SUCCESS == kr), @"IOServiceOpen failed.");
        
        IOObjectRelease( service );
        IOObjectRelease( iter );
    }
    return sEventDrvrRef;
}

void HIDPostAuxKey(const UInt8 auxKeyCode)
{
    NXEventData   event;
    kern_return_t kr;
    IOGPoint      loc = { 0, 0 };
    
    // Key press event
    UInt32      evtInfo = auxKeyCode << 16 | NX_KEYDOWN << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
    NSCAssert((KERN_SUCCESS == kr), @"IOHIDPostEvent pressing failed.");
    
    // Key release event
    evtInfo = auxKeyCode << 16 | NX_KEYUP << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
    NSCAssert((KERN_SUCCESS == kr), @"IOHIDPostEvent releasing failed.");
}