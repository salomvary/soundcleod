#import "DHSwipeIndicator.h"

@implementation DHSwipeIndicator

@synthesize webView;
@synthesize clipView;

#define kSwipeMinimumLength 0.3

- (id)initWithWebView:(DHSwipeWebView *)aWebView
{
    self = [self initWithFrame:NSMakeRect(0, 0, aWebView.frame.size.width, aWebView.frame.size.height)];
    if(self)
    {
        self.webView = aWebView;
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self setWantsLayer:YES];
        [aWebView addSubview:self];
        id docView = [[[webView mainFrame] frameView] documentView];
        NSScrollView *scrollView = [docView enclosingScrollView];
        self.clipView = [[DHSwipeClipView alloc] initWithFrame:[[scrollView contentView] frame] webView:webView];
        [scrollView setContentView:clipView];
        [scrollView setDocumentView:docView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(clipView.currentSum != 0 && clipView.isHandlingEvent)
    {
        CGFloat sum = clipView.currentSum;
        NSRect drawRect = NSZeroRect;
        CGFloat absoluteSum = fabsf(sum);
        CGFloat percent = (absoluteSum) / kSwipeMinimumLength;
        percent = (percent > 1.0) ? 1.0 : percent;
        
        CGFloat alphaPercent = (percent == 1.0) ? 1.0 : (percent <= 0.7) ? percent : 0.7f;
        if(sum < 0)
        {
            drawRect = NSMakeRect(0-(49-49*percent), self.frame.size.height/2, 49*percent, 100);
            NSRect frame = NSIntegralRect(drawRect);
            //// Semicircle Drawing
            NSBezierPath* semicirclePath = [NSBezierPath bezierPath];
            [semicirclePath moveToPoint: NSMakePoint(NSMinX(frame) + 34.65, NSMaxY(frame) - 14.64)];
            [semicirclePath curveToPoint: NSMakePoint(NSMinX(frame) + 34.65, NSMaxY(frame) - 85.36) controlPoint1: NSMakePoint(NSMinX(frame) + 53.78, NSMaxY(frame) - 34.17) controlPoint2: NSMakePoint(NSMinX(frame) + 53.78, NSMaxY(frame) - 65.83)];
            [semicirclePath curveToPoint: NSMakePoint(NSMinX(frame), NSMaxY(frame) - 100) controlPoint1: NSMakePoint(NSMinX(frame) + 25.08, NSMaxY(frame) - 95.12) controlPoint2: NSMakePoint(NSMinX(frame) + 12.54, NSMaxY(frame) - 100)];
            [semicirclePath lineToPoint: NSMakePoint(NSMinX(frame), NSMaxY(frame))];
            [semicirclePath curveToPoint: NSMakePoint(NSMinX(frame) + 34.65, NSMaxY(frame) - 14.64) controlPoint1: NSMakePoint(NSMinX(frame) + 12.54, NSMaxY(frame)) controlPoint2: NSMakePoint(NSMinX(frame) + 25.08, NSMaxY(frame) - 4.88)];
            [semicirclePath closePath];
            [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alphaPercent] setFill];
            [semicirclePath fill];
            
            //// Arrow Drawing
            NSBezierPath* arrowPath = [NSBezierPath bezierPath];
            [arrowPath moveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 37.93)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 42.17) controlPoint1: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 39.1) controlPoint2: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 41)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 19.24, NSMaxY(frame) - 47)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 37, NSMaxY(frame) - 47)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 38.66, NSMaxY(frame) - 47) controlPoint2: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 48.34)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 37, NSMaxY(frame) - 53) controlPoint1: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 51.66) controlPoint2: NSMakePoint(NSMinX(frame) + 38.66, NSMaxY(frame) - 53)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 19.24, NSMaxY(frame) - 53)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 57.83)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 59) controlPoint2: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 60.9)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 19.83, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 22.9, NSMaxY(frame) - 63.24) controlPoint2: NSMakePoint(NSMinX(frame) + 21, NSMaxY(frame) - 63.24)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 9.93, NSMaxY(frame) - 52.17)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 9.35, NSMaxY(frame) - 51.6) controlPoint2: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 50.84)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 9.9, NSMaxY(frame) - 47.85) controlPoint1: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 49.16) controlPoint2: NSMakePoint(NSMinX(frame) + 9.35, NSMaxY(frame) - 48.4)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 19.83, NSMaxY(frame) - 37.93)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 37.93) controlPoint1: NSMakePoint(NSMinX(frame) + 21, NSMaxY(frame) - 36.76) controlPoint2: NSMakePoint(NSMinX(frame) + 22.9, NSMaxY(frame) - 36.76)];
            [arrowPath closePath];
            [[NSColor whiteColor] setFill];
            [arrowPath fill];        }
        else
        {
            drawRect = NSMakeRect(self.frame.size.width-(49*percent), self.frame.size.height/2, 49*percent, 100);
            NSRect frame = drawRect;
            //// Semicircle Drawing
            NSBezierPath* semicirclePath = [NSBezierPath bezierPath];
            [semicirclePath moveToPoint: NSMakePoint(NSMinX(frame) + 14.35, NSMaxY(frame) - 14.64)];
            [semicirclePath curveToPoint: NSMakePoint(NSMinX(frame) + 14.35, NSMaxY(frame) - 85.36) controlPoint1: NSMakePoint(NSMinX(frame) - 4.78, NSMaxY(frame) - 34.17) controlPoint2: NSMakePoint(NSMinX(frame) - 4.78, NSMaxY(frame) - 65.83)];
            [semicirclePath curveToPoint: NSMakePoint(NSMinX(frame) + 49, NSMaxY(frame) - 100) controlPoint1: NSMakePoint(NSMinX(frame) + 23.92, NSMaxY(frame) - 95.12) controlPoint2: NSMakePoint(NSMinX(frame) + 36.46, NSMaxY(frame) - 100)];
            [semicirclePath lineToPoint: NSMakePoint(NSMinX(frame) + 49, NSMaxY(frame))];
            [semicirclePath curveToPoint: NSMakePoint(NSMinX(frame) + 14.35, NSMaxY(frame) - 14.64) controlPoint1: NSMakePoint(NSMinX(frame) + 36.46, NSMaxY(frame)) controlPoint2: NSMakePoint(NSMinX(frame) + 23.92, NSMaxY(frame) - 4.88)];
            [semicirclePath closePath];
            [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alphaPercent] setFill];
            [semicirclePath fill];
            
            
            //// Arrow Drawing
            NSBezierPath* arrowPath = [NSBezierPath bezierPath];
            [arrowPath moveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 37.93)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 42.17) controlPoint1: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 39.1) controlPoint2: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 41)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 29.76, NSMaxY(frame) - 47)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 12, NSMaxY(frame) - 47)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 10.34, NSMaxY(frame) - 47) controlPoint2: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 48.34)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 12, NSMaxY(frame) - 53) controlPoint1: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 51.66) controlPoint2: NSMakePoint(NSMinX(frame) + 10.34, NSMaxY(frame) - 53)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 29.76, NSMaxY(frame) - 53)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 57.83)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 59) controlPoint2: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 60.9)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 29.17, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 26.1, NSMaxY(frame) - 63.24) controlPoint2: NSMakePoint(NSMinX(frame) + 28, NSMaxY(frame) - 63.24)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 39.07, NSMaxY(frame) - 52.17)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 39.65, NSMaxY(frame) - 51.6) controlPoint2: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 50.84)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 39.1, NSMaxY(frame) - 47.85) controlPoint1: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 49.16) controlPoint2: NSMakePoint(NSMinX(frame) + 39.65, NSMaxY(frame) - 48.4)];
            [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 29.17, NSMaxY(frame) - 37.93)];
            [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 37.93) controlPoint1: NSMakePoint(NSMinX(frame) + 28, NSMaxY(frame) - 36.76) controlPoint2: NSMakePoint(NSMinX(frame) + 26.1, NSMaxY(frame) - 36.76)];
            [arrowPath closePath];
            [[NSColor whiteColor] setFill];
            [arrowPath fill];
        }
    }
    else
    {
        [[[webView mainFrame] frameView] setAllowsScrolling:YES];
    }
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    return nil;
}

@end
