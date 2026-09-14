// Declarations the AppKit Swift overlay needs, written for Darling from AppKit's public API documentation. Darling's
// AppKit (Cocotron) has no Clang module, so the overlay imports these instead of <AppKit/AppKit.h>. The functions
// are exported by Darling's AppKit.framework.
#ifndef DARLING_APPKIT_SHIMS_H
#define DARLING_APPKIT_SHIMS_H

#import <Foundation/Foundation.h>

// A named enum (like NS_ENUM) is imported as a nominal type and mangled `So22NSCompositingOperationV`, matching the
// symbols apps built against the macOS SDK import. An anonymous `typedef enum { } X` would mangle as a typealias.
typedef enum NSCompositingOperation : NSUInteger {
	NSCompositingOperationClear = 0,
	NSCompositingOperationCopy = 1,
	NSCompositingOperationSourceOver = 2,
} NSCompositingOperation;

@interface NSSound : NSObject
@end

void NSRectFillUsingOperation(NSRect rect, NSCompositingOperation operation);
void NSFrameRectWithWidthUsingOperation(NSRect rect, CGFloat frameWidth, NSCompositingOperation operation);
void NSBeep(void);

#endif
