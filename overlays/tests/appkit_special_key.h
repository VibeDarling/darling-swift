// Darling AppKit methods tests/appkit_special_key.swift calls, which the AppKit overlay's shim does not declare.
#import <Foundation/Foundation.h>
@import _DarlingAppKitShims;

@interface NSEvent (DarlingTest)
+ (NSEvent *)keyEventWithType:(NSUInteger)type
                     location:(NSPoint)location
                modifierFlags:(NSUInteger)modifierFlags
                    timestamp:(NSTimeInterval)timestamp
                 windowNumber:(NSInteger)windowNumber
                      context:(id)context
                   characters:(NSString *)characters
  charactersIgnoringModifiers:(NSString *)charactersIgnoringModifiers
                    isARepeat:(BOOL)isARepeat
                      keyCode:(unsigned short)keyCode;
@end

@interface NSColor (DarlingTest)
@property (readonly) CGFloat redComponent;
@property (readonly) CGFloat greenComponent;
@property (readonly) CGFloat blueComponent;
@property (readonly) CGFloat alphaComponent;
@end
