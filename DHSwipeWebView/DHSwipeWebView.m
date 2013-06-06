#import "DHSwipeWebView.h"
#import "DHSwipeIndicator.h"

@implementation DHSwipeWebView

@synthesize swipeIndicator;

- (void)awakeFromNib
{
    [super awakeFromNib];
    if(NSClassFromString(@"NSPopover")) // this is my dumb way of checking if 10.7+
    {
        self.swipeIndicator = [[DHSwipeIndicator alloc] initWithWebView:self];
    }
}

@end
