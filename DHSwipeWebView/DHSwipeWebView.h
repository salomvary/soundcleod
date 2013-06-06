#import <WebKit/WebKit.h>

@class DHSwipeIndicator;

@interface DHSwipeWebView : WebView {
    DHSwipeIndicator *swipeIndicator;
}

@property (retain) DHSwipeIndicator *swipeIndicator;

@end
