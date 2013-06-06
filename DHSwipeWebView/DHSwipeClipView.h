#import <Cocoa/Cocoa.h>
#import "DHSwipeWebView.h"

@interface DHSwipeClipView : NSClipView {
    CGFloat currentSum;
    NSTimer *drawTimer;
    BOOL canGoLeft;
    BOOL canGoRight;
    DHSwipeWebView *webView;
    BOOL isHandlingEvent;
    BOOL _haveAdditionalClip;
    NSRect _additionalClip;
    CGFloat scrollDeltaX;
    CGFloat scrollDeltaY;
}

@property (retain) NSTimer *drawTimer;
@property (assign) CGFloat currentSum;
@property (retain) DHSwipeWebView *webView;
@property (assign) BOOL isHandlingEvent;

- (id)initWithFrame:(NSRect)frame webView:(DHSwipeWebView *)aWebView;

@end
