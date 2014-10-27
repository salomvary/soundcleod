//
//  UrlService.m
//  SoundCleod
//
//  Created by Joel Ekström on 2014-10-27.
//  Copyright (c) 2014 Márton Salomváry. All rights reserved.
//

#import "SCURLService.h"
#import "NSURL+SCUtils.h"

@implementation SCURLService

- (void)openURL:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {

    NSString *text = [self extractStringsForSupportedTypes:pboard];
    [pboard clearContents];

    NSArray *allURLs = [self findLinksInText:text];

    if (allURLs == nil) {
        *error = @"Error: no URL detected.";
        return;
    }

    // Find the first SoundCloud URL if any
    NSURL *targetURL = nil;
    for (NSURL *URL in allURLs) {
        if ([URL isSoundCloudURL]) {
            targetURL = URL;
            break;
        }
    }

    if (!targetURL) {
        *error = @"Error: No SoundCloud URL detected.";
        return;
    }

    if ([self.delegate respondsToSelector:@selector(URLService:didReceiveURL:)]) {
        [self.delegate URLService:self didReceiveURL:targetURL];
    }
}

/**
 Since NSPasteboard kan contain different types, we need to extract all types
 supported by soundcleod. For example, if you right click a link on a webpage
 <a "href=http://www.apple.com">Apple</a> then NSPasteboardTypeString will contain
 only "Apple", and the actual link will be in the RTF segment.
 */
- (NSString *)extractStringsForSupportedTypes:(NSPasteboard *)pboard
{
    NSMutableString *text = [NSMutableString new];

    if ([pboard stringForType:NSPasteboardTypeString]) {
        [text appendString:[pboard stringForType:NSPasteboardTypeString]];
    }

    if ([pboard stringForType:NSPasteboardTypeRTF]) {
        [text appendString:[pboard stringForType:NSPasteboardTypeRTF]];
    }

    if ([pboard stringForType:NSPasteboardTypeHTML]) {
        [text appendString:[pboard stringForType:NSPasteboardTypeHTML]];
    }

    if ([pboard stringForType:NSPasteboardTypeRTFD]) {
        [text appendString:[pboard stringForType:NSPasteboardTypeRTFD]];
    }

    if (text.length > 0) {
        return [text copy];
    }

    return nil;
}

- (NSArray *)findLinksInText:(NSString *)text
{
    if (!text) {
        return nil;
    }

    NSError *error = nil;
    NSDataDetector *dataDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [dataDetector matchesInString:text options:NULL range:NSMakeRange(0, text.length)];

    NSMutableArray *urls = [NSMutableArray new];
    for (NSTextCheckingResult *result in matches) {
        NSURL *URL = result.URL;
        [urls addObject:URL];
    }

    if (urls.count == 0) {
        return nil;
    }

    return urls;
}

@end
