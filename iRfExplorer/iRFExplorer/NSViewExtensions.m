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

    NSString * msg = @"Waiting for connection...";
    NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont fontWithName:@"Helvetica" size:36], NSFontAttributeName,
                           [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                           nil];
    
    NSSize s = [msg sizeWithAttributes:attr];
    
    x = self.bounds.origin.x + (self.bounds.size.width - s.width) * 0.50;
    y = self.bounds.origin.y + (self.bounds.size.height - s.height) * 0.66;
    [msg drawAtPoint:NSMakePoint(x,y) withAttributes:attr];
    
    msg = @"(No RF-Explorer (yet) ? Then hold 'ALT' during startup for an audio demo.)";
    attr = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont fontWithName:@"Helvetica Oblique" size:10], NSFontAttributeName,
            [NSColor lightGrayColor], NSForegroundColorAttributeName, 
            nil];
    
    s = [msg sizeWithAttributes:attr];
    
    x = self.bounds.origin.x + (self.bounds.size.width - s.width) * 0.50;
    y -= s.height + 2;
    


    [msg drawAtPoint:NSMakePoint(x,y) withAttributes:attr];
    return;
}
@end
