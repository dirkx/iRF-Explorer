// http://johnnytrops.com/blog/wp/2009/05/13/iphone-uicolor-category-making-rgb-colors/

/** NSColor category for converting NSColor<-->CGColor
 */


@interface NSColor (CGColorAdditions)

#if defined(__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__) && __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1070
/**
 Return CGColor representation of the NSColor in the RGB color space
 */
@property (readonly) CGColorRef CGColor;
/**
 Create new NSColor from a CGColorRef
 */
+ (NSColor*)colorWithCGColor:(CGColorRef)aColor;
#endif

@end

