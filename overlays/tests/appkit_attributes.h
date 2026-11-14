// Darling AppKit methods tests/appkit_attributes.swift calls, which the AppKit overlay's shim does not declare.
#import <Foundation/Foundation.h>
@import _DarlingAppKitShims;

@interface NSFont (DarlingTest)
+ (nonnull NSFont *)systemFontOfSize:(CGFloat)size;
+ (nonnull NSFont *)boldSystemFontOfSize:(CGFloat)size;
@end
