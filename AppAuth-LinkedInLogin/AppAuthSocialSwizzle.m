#import "AppAuthSocialSwizzle.h"
#import <objc/runtime.h>

@import AppAuth;

@class OIDAuthorizationFlowSessionImplementation;

@implementation AppAuthSocialSwizzle

// To prevent needing for fork AppAuth, we will swizzle the shouldHandleURL method.
// This method validates that the URL is in the same format as the redirect URL we specified to do oauth with.
// However, our redirect URL is to our backend, which will redirect back to the app.
// Instead, we want to validate that it's the oauthredirect URL to our app.
+(void)swizzle {
    Method original, swizzle;
    
    original = class_getInstanceMethod([OIDAuthorizationService class], @selector(shouldHandleURL:));
    swizzle = class_getInstanceMethod(self, @selector(swizzled_shouldHandleURL:));
    
    method_exchangeImplementations(original, swizzle);
}

-(BOOL)swizzled_shouldHandleURL:(NSURL*)url {
    // The URL scheme to handle MUST be one of our app schemes
    NSURL *standardizedURL = [url standardizedURL];
    NSArray<NSString*> *urlSchemes = NSBundle.mainBundle.infoDictionary[@"CFBundleURLSchemes"];
    if(![urlSchemes containsObject:standardizedURL.scheme]) {
        return NO;
    }
    
    // The path must be equal to our expected redirect path
    NSString *redirectPath = @"oauthredirect";
    if(![url.host.lowercaseString isEqualToString:redirectPath]) {
        return NO;
    }
    
    return YES;
}

@end
