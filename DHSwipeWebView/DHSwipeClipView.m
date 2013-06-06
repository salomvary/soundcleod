#import "DHSwipeClipView.h"

// Some code taken from https://github.com/kgn/LinenClipView
@implementation DHSwipeClipView

@synthesize drawTimer;
@synthesize currentSum;
@synthesize webView;
@synthesize isHandlingEvent;

- (id)initWithFrame:(NSRect)frame webView:(DHSwipeWebView *)aWebView
{
    if(!(self = [super initWithFrame:frame]))
    {
        return nil;
    }
    self.webView = aWebView;
    
    // In WebHTMLView, we set a clip. This is not typical to do in an
    // NSView, and while correct for any one invocation of drawRect:,
    // it causes some bad problems if that clip is cached between calls.
    // The cached graphics state, which clip views keep around, does
    // cache the clip in this undesirable way. Consequently, we want to
    // release the GState for all clip views for all views contained in
    // a WebHTMLView. Here we do it for subframes, which use WebClipView.
    // See these bugs for more information:
    // <rdar://problem/3409315>: REGRESSSION (7B58-7B60)?: Safari draws blank frames on macosx.apple.com perf page
    [self releaseGState];
    
    return self;
}

- (void)resetAdditionalClip
{
    _haveAdditionalClip = NO;
}

- (void)setAdditionalClip:(NSRect)additionalClip
{
    _haveAdditionalClip = YES;
    _additionalClip = additionalClip;
}

- (BOOL)hasAdditionalClip
{
    return _haveAdditionalClip;
}

- (NSRect)additionalClip
{
    return _additionalClip;
}

// From https://gist.github.com/b6bcb09a9fc0e9557c27
- (NSView *)hitTest:(NSPoint)aPoint
{
    NSEvent *currentEvent = [NSApp currentEvent];
    NSScrollView *scrollView = [self enclosingScrollView];
    if([currentEvent type] == NSLeftMouseDown)
    {
        // if we have a vertical scroller and it accepts the current hit
        if([scrollView hasVerticalScroller] && [[scrollView verticalScroller] hitTest:aPoint] != nil)
        {
            [[scrollView verticalScroller] mouseDown:currentEvent];
        }
        // if we have a horizontal scroller and it accepts the current hit
        if([scrollView hasVerticalScroller] && [[scrollView horizontalScroller] hitTest:aPoint] != nil)
        {
            [[scrollView horizontalScroller] mouseDown:currentEvent];
        }
    }
    return [super hitTest:aPoint];
}

- (void)scrollWheel:(NSEvent *)event
{
    if(![NSEvent isSwipeTrackingFromScrollEventsEnabled])
    {
        [super scrollWheel:event];
        return;
    }
    if([event phase] == NSEventPhaseBegan)
    {
        currentSum = 0;
        NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
        NSRect bounds = [[scrollView contentView] bounds];
        canGoLeft = canGoRight = NO;
        if(bounds.origin.x <= 0)
        {
            canGoLeft = YES; // && [webView canGoBack]
        }
        if(bounds.origin.x + bounds.size.width >= [[scrollView documentView] bounds].size.width)
        {
            canGoRight = YES; // && [webView canGoForward]
        }
        scrollDeltaX = 0;
        scrollDeltaY = 0;
        isHandlingEvent = canGoLeft || canGoRight;
    }
    else if([event phase] == NSEventPhaseChanged)
    {
        if(!isHandlingEvent)
        {
            if(currentSum != 0)
            {
                currentSum = 0;
                [self launchDrawTimer];
            }
        }
        else
        {
            scrollDeltaX += [event scrollingDeltaX];
            scrollDeltaY += [event scrollingDeltaY];
            
            float absoluteSumX = fabsf(scrollDeltaX);
            float absoluteSumY = fabsf(scrollDeltaY);
            if((absoluteSumX < absoluteSumY && currentSum == 0))
            {
                isHandlingEvent = NO;
                if(currentSum != 0)
                {
                    currentSum = 0;
                    [self launchDrawTimer];
                }
            }
            else
            {
                CGFloat flippedDeltaX = scrollDeltaX * -1;
                if(flippedDeltaX == 0 || (flippedDeltaX < 0 && !canGoLeft) || (flippedDeltaX > 0 && !canGoRight))
                {
                    if(currentSum != 0)
                    {
                        currentSum = 0;
                        [self launchDrawTimer];
                    }
                }
                else
                {
                    // Draw the back/forward indicators
                    currentSum = flippedDeltaX/1000;
                    [self launchDrawTimer];
                    return;
                }
            }
        }
    }
    else if([event phase] == NSEventPhaseEnded)
    {
        if(currentSum < -0.3 && canGoLeft && [self.webView canGoBack])
        {
            [self.webView goBack];
        }
        else if(currentSum >= 0.3 && canGoRight && [self.webView canGoForward])
        {
            [self.webView goForward];
        }
        isHandlingEvent = NO;
        if(currentSum != 0)
        {
            currentSum = 0;
            [self launchDrawTimer];
        }
    }
    else if([event phase] == NSEventPhaseCancelled)
    {
        isHandlingEvent = NO;
        if(currentSum != 0)
        {
            currentSum = 0;
            [self launchDrawTimer];
        }
    }
    [super scrollWheel:event];
}

- (void)launchDrawTimer
{
    // a timer is needed because events are queued and processing and drawing
    // takes longer than they are delivered, so the queue fills up
    if(!drawTimer || ![drawTimer isValid])
    {
        self.drawTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/25 target:webView.swipeIndicator selector:@selector(display) userInfo:nil repeats:NO];
    }
}

@end
