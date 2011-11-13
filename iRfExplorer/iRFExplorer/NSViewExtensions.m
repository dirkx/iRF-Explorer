//
//  NSViewExtensions.m
//  iRFExplorer
//
//  After http://www.cocoabuilder.com/archive/cocoa/71931-setenabled-on-nsview.html

#import "NSViewExtensions.h"

@implementation NSView(MyExtensions)

- (void)setSubViewsEnabled:(BOOL)enabled
{
    /// TODO: XXX add some CoreAnimation layer to fade the current view.
    //
    for(NSView *v in self.subviews) {
        if( [v respondsToSelector:@selector(setEnabled:)] )
        {
            [(NSControl*)v setEnabled:enabled];
        }
        [v setSubViewsEnabled:enabled];
        
        [v display];
    }
}

-(void)drawEmptyRect:(NSRect)dirtyRect {
    double x = self.bounds.origin.x + 8;
    double y = self.bounds.origin.y + 8;

    NSImage * img = [NSApp applicationIconImage];
    [img drawAtPoint:NSMakePoint(x,y) 
            fromRect:NSZeroRect 
           operation:NSCompositeHighlight 
            fraction:1];

    NSString * msg = NSLocalizedString(@"Waiting for connection...",
                                       @"Waiting msg show big in window");
    NSString * subMsg = NSLocalizedString(@"(No RF-Explorer (yet) ? Then hold 'ALT' during startup for an audio demo.)",
                                          @"Demo prompting msg");
    
    NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont fontWithName:@"Helvetica" size:36], NSFontAttributeName,
                           [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                           nil];
    
    NSSize s = [msg sizeWithAttributes:attr];
    
    x = self.bounds.origin.x + (self.bounds.size.width - s.width) * 0.50;
    y = self.bounds.origin.y + (self.bounds.size.height - s.height) * 0.66;
    [msg drawAtPoint:NSMakePoint(x,y) withAttributes:attr];
    
    attr = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont fontWithName:@"Helvetica Oblique" size:10], NSFontAttributeName,
            [NSColor lightGrayColor], NSForegroundColorAttributeName, 
            nil];
    
    s = [subMsg sizeWithAttributes:attr];
    
    x = self.bounds.origin.x + (self.bounds.size.width - s.width) * 0.50;
    y -= s.height + 2;
    


    [msg drawAtPoint:NSMakePoint(x,y) withAttributes:attr];
    return;
}

void CGContextAddReverseRect(CGContextRef ctx,CGRect frame) {
    CGContextMoveToPoint(ctx, frame.origin.x, frame.origin.y);
    CGContextAddLineToPoint(ctx, frame.origin.x, frame.origin.y + frame.size.height);
    CGContextAddLineToPoint(ctx, frame.origin.x + frame.size.width, frame.origin.y+frame.size.height);
    CGContextAddLineToPoint(ctx, frame.origin.x + frame.size.width, frame.origin.y);
    CGContextMoveToPoint(ctx, frame.origin.x, frame.origin.y);
}

- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

@end
