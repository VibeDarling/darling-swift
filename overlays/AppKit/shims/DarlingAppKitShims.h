// Declarations the AppKit Swift overlay needs, written for Darling from AppKit's public API documentation. The overlay
// imports this only when the SDK has no AppKit Clang module; with one it re-exports that instead. The functions are
// exported by Darling's AppKit.framework.
#ifndef DARLING_APPKIT_SHIMS_H
#define DARLING_APPKIT_SHIMS_H

#import <Foundation/Foundation.h>

// Where the SDK has AppKit's headers (without a module map), use them: cocotron declares every one of these six
// itself (NSGraphics.h, NSCell.h, AppKit.h), so redeclaring them is an ODR clash on the classes
// and an ambiguity on the enum and the functions, not a duplicate definition.
#if __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#else
// A named enum (like NS_ENUM) is imported as a nominal type and mangled `So22NSCompositingOperationV`, matching the
// symbols apps built against the macOS SDK import. An anonymous `typedef enum { } X` would mangle as a typealias.
typedef enum NSCompositingOperation : NSUInteger {
	NSCompositingOperationClear = 0,
	NSCompositingOperationCopy = 1,
	NSCompositingOperationSourceOver = 2,
} NSCompositingOperation;

// Named for the same reason as NSCompositingOperation: a named enum imports as the nominal Clang
// type `So12NSBezelStyleV`, which is what macOS 26 apps import for the glass button styles. The
// values mirror Darling's own header (NSButtonCell.h), plus NSBezelStyleGlass, which is new in the
// macOS 26 SDK.
typedef enum NSBezelStyle : NSUInteger {
	NSRoundedBezelStyle = 1,
	NSRegularSquareBezelStyle = 2,
	NSThickSquareBezelStyle = 3,
	NSThickerSquareBezelStyle = 4,
	NSDisclosureBezelStyle = 5,
	NSShadowlessSquareBezelStyle = 6,
	NSCircularBezelStyle = 7,
	NSTexturedSquareBezelStyle = 8,
	NSHelpButtonBezelStyle = 9,
	NSSmallSquareBezelStyle = 10,
	NSTexturedRoundedBezelStyle = 11,
	NSRoundRectBezelStyle = 12,
	NSRecessedBezelStyle = 13,
	NSRoundedDisclosureBezelStyle = 14,
	NSInlineBezelStyle = 15,
	NSBezelStyleGlass = 16,

	// Names used by the macOS 10.14+ SDK.
	NSBezelStyleRounded = NSRoundedBezelStyle,
	NSBezelStyleRegularSquare = NSRegularSquareBezelStyle,
	NSBezelStyleDisclosure = NSDisclosureBezelStyle,
	NSBezelStyleShadowlessSquare = NSShadowlessSquareBezelStyle,
	NSBezelStyleCircular = NSCircularBezelStyle,
	NSBezelStyleTexturedSquare = NSTexturedSquareBezelStyle,
	NSBezelStyleHelpButton = NSHelpButtonBezelStyle,
	NSBezelStyleSmallSquare = NSSmallSquareBezelStyle,
	NSBezelStyleTexturedRounded = NSTexturedRoundedBezelStyle,
	NSBezelStyleRoundRect = NSRoundRectBezelStyle,
	NSBezelStyleRecessed = NSRecessedBezelStyle,
	NSBezelStyleRoundedDisclosure = NSRoundedDisclosureBezelStyle,
	NSBezelStyleInline = NSInlineBezelStyle,
} NSBezelStyle;

@interface NSSound : NSObject
@end

@interface NSImage : NSObject
+ (nullable instancetype)imageNamed:(NSString *)name;
@end

void NSRectFillUsingOperation(NSRect rect, NSCompositingOperation operation);
void NSFrameRectWithWidthUsingOperation(NSRect rect, CGFloat frameWidth, NSCompositingOperation operation);
void NSBeep(void);
int NSApplicationMain(int argc, const char *argv[]);
#endif

#endif
