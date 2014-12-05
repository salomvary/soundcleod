#import <Foundation/Foundation.h>

@protocol AppleMikeyManagerDelegate <NSObject>
@optional
- (void) mikeyDidPlayPause;
- (void) mikeyDidNext;
- (void) mikeyDidPrevious;
- (void) mikeyDidSoundUp;
- (void) mikeyDidSoundDown;
@end

@interface AppleMikeyManager : NSObject

- (void) startListening;
- (void) stopListening;

@property (weak) id<AppleMikeyManagerDelegate> delegate;
@property (readonly) BOOL isListening;

@end
