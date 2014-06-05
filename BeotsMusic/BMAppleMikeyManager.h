#import <Foundation/Foundation.h>

@protocol BMAppleMikeyManagerDelegate <NSObject>
@optional
- (void) mikeyDidPlayPause;
- (void) mikeyDidNext;
- (void) mikeyDidPrevious;
- (void) mikeyDidSoundUp;
- (void) mikeyDidSoundDown;
@end

@interface BMAppleMikeyManager : NSObject

- (void) startListening;
- (void) stopListening;

@property (weak) id<BMAppleMikeyManagerDelegate> delegate;
@property (readonly) BOOL isListening;

@end
