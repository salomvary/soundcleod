#import <Foundation/Foundation.h>

@protocol BMAppleMikeyReceiverDelegate <NSObject>
@optional
- (void) mikeyDidPlayPause;
- (void) mikeyDidNext;
- (void) mikeyDidPrevious;
- (void) mikeyDidSoundUp;
- (void) mikeyDidSoundDown;
@end

@interface BMAppleMikeyManager : NSObject

- (instancetype) init;

- (void) startListening;
- (void) stopListening;

@property (weak) id<BMAppleMikeyReceiverDelegate> delegate;
@property (readonly) BOOL isListening;

@end
