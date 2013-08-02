//
// http://johnnytrops.com/blog/wp/2009/05/13/iphone-uicolor-category-making-rgb-colors/


#import "NSColorExtensions.h"

@implementation NSColor (CGColorAdditions)

#if defined(__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__) && __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1070

- (CGColorRef)CGColor
{
    NSColor *colorRGB = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat components[4];
    [colorRGB getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    CGColorSpaceRef theColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorRef theColor = CGColorCreate(theColorSpace, components);
    CGColorSpaceRelease(theColorSpace);
    return (CGColorRef)[(id)theColor autorelease];
}

+ (NSColor*)colorWithCGColor:(CGColorRef)aColor
{
    const CGFloat *components = CGColorGetComponents(aColor);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = components[3];
    return [self colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}
#endif

@end