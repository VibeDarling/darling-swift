// Darling AppKit methods tests/appkit_popupbutton.swift calls, which the AppKit overlay's shim does not declare.
#import <Foundation/Foundation.h>
@import _DarlingAppKitShims;

@interface NSMenu (DarlingTest)
- (nonnull instancetype)initWithTitle:(NSString *)title;
- (nullable id)addItemWithTitle:(NSString *)title action:(nullable SEL)selector keyEquivalent:(NSString *)charCode;
@end

@interface NSImage (DarlingTest)
- (nonnull instancetype)initWithSize:(NSSize)size;
@end
