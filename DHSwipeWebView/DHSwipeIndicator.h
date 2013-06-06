#import <Cocoa/Cocoa.h>
#import "DHSwipeWebView.h"
#import "DHSwipeClipView.h"

@interface DHSwipeIndicator : NSView {
    DHSwipeWebView *webView;
    DHSwipeClipView *clipView;
}

@property (retain) DHSwipeWebView *webView;
@property (retain) DHSwipeClipView *clipView;

- (id)initWithWebView:(DHSwipeWebView *)aWebView;

@end
