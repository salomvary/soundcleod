//
//  Created by
//      George Warner
//      Casey Fleser http://www.somegeekintn.com/blog/2006/03/universal-mediakeys/
//
//  Stolen from http://stackoverflow.com/questions/10273159
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/IOHIDLib.h>
#import <IOKit/hidsystem/ev_keymap.h>

io_connect_t get_event_driver(void);
void HIDPostAuxKey(const UInt8 auxKeyCode);