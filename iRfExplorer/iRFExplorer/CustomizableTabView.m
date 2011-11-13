//
//  CustomizableTabView.m
//  CustomizableTabView
//
//  Copyright 2011 WebWeaving. All rights reserved.
//                 Dirk-Willem van Gulik <dirkx(at)webweaving(dot)org>
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 

#import "CustomizableTabView.h"

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "NSColorExtensions.h"
#import "NSViewExtensions.h"

@implementation CustomizableTabView
@synthesize segmentedControl;

const double kSegHeight = 32.f;
const double kRadius = 8.f;

-(void)rework {
    
    NSArray * items = self.tabViewItems;
    NSUInteger n = [items count];

    double h = kSegHeight, w = MIN(12 + 70 * n,self.frame.size.width-kSegHeight);
    NSRect segmentedControlFrame;
    segmentedControlFrame.size.width = w;
    segmentedControlFrame.size.height = h;
    segmentedControlFrame.origin.x = self.bounds.origin.x + 
                (self.bounds.size.width - segmentedControlFrame.size.width) / 2;
    segmentedControlFrame.origin.y = self.bounds.origin.y;

    [segmentedControl removeFromSuperview];
    [segmentedControl release];
    
    segmentedControl = [[NSSegmentedControl alloc] initWithFrame:segmentedControlFrame];                              
    [segmentedControl setSegmentStyle:NSSegmentStyleTexturedSquare];
    [segmentedControl setSegmentCount:n];

    for(NSUInteger i = 0; i < n; i++) {
        NSTabViewItem * item = (NSTabViewItem *)[items objectAtIndex:i];

        [segmentedControl setLabel:item.label forSegment:i];
        [segmentedControl setWidth:0 forSegment:i];
        [segmentedControl setTarget:self];
        [segmentedControl setAction:@selector(ctrlSelected:)];
    }
    [self addSubview:segmentedControl];
    
#if 0
    if (backgroundColor == nil) {
        NSView * v = self;
        while((v = v.superview) != nil) {
            if ([v respondsToSelector:@selector(backgroundColor)]) {
                backgroundColor = [v performSelector:@selector(backGroundColor)];
                break;
            }
        }
    }
#endif
    // Record the 'ideal' max size (and ideally update it when we see
    // more addSubviews coming through).
    //
    NSSize s = ((NSSegmentedCell *)(segmentedControl.cell)).cellSize;
    maxWidth = s.width;
    
    // For some weird reason the NSColour windowBack.. etc colours do not seem to be
    // actual colours - but just transparent. So we hardcode something here for now.
    //
    if (backgroundColor == nil) {
        self.backgroundColor = [NSColor colorWithDeviceRed:228.f/255 
                                                     green:228.f/255 
                                                      blue:228.f/255 
                                                     alpha:1];
    }
    
    if (windowBackgroundColor == nil) {
        self.windowBackgroundColor = [NSColor colorWithDeviceRed:237.f/255 
                                                           green:237.f/255 
                                                            blue:237.f/255 
                                                           alpha:1];
    }
    
    if (bezelColor == nil)
        self.bezelColor = [NSColor darkGrayColor];
    
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
    [self setNeedsDisplay:YES];
}

#pragma standard init and friends.

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self == nil)
        return nil;
    
    [self addTabViewItem:[[[NSTabViewItem alloc] initWithIdentifier:@"1"] autorelease]];
    [self addTabViewItem:[[[NSTabViewItem alloc] initWithIdentifier:@"2"] autorelease]];
    
    [[self tabViewItemAtIndex:0] setLabel:@"Tab"];
    [[self tabViewItemAtIndex:1] setLabel:@"View"];
    
    [self rework];
    return self;
}

-(void)awakeFromNib {
    [self rework];
}

#pragma mark Callback - to link our sgementedControl to the tabViewItems

-(IBAction)ctrlSelected:(NSSegmentedControl *)sender {
    [super selectTabViewItemAtIndex:[sender selectedSegment]];
    [self setNeedsDisplay:YES];
}

// Void some optimizations which miss out redrawing the very
// top and very bottom.
//
-(void)setNeedsDisplayInRect:(NSRect)invalidRect {
    [super setNeedsDisplayInRect:self.bounds];
}

#pragma mark Keep tabs on what gets selected - so our own segmentedControl stays synced.

-(void)selectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super selectTabViewItem:tabViewItem];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

-(void)selectTabViewItemAtIndex:(NSInteger)index {
    [super selectTabViewItemAtIndex:index];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];
}

-(void)selectTabViewItemWithIdentifier:(id)identifier {
    [super selectTabViewItemWithIdentifier:identifier];
    [segmentedControl setSelectedSegment:[self indexOfTabViewItem:[self selectedTabViewItem]]];    
}
// skipping selectNext/PreviousTabViewItem - hoping they use above.

-(void)addTabViewItem:(NSTabViewItem *)anItem {
    [super addTabViewItem:anItem];
    [self rework];
}

-(void)removeTabViewItem:(NSTabViewItem *)anItem {
    [super removeTabViewItem:anItem];
    [self rework];
}

#pragma drawing and alignments

-(void)viewWillDraw {
    // Recenter the segment box at the top if needed. We prolly should
    // detect when we get resized - and only do this then. How ?
    //
    NSRect segmentedControlFrame;
    segmentedControlFrame.size.width = MIN(maxWidth,self.frame.size.width-kSegHeight);
    segmentedControlFrame.size.height =  ((NSSegmentedCell *)(segmentedControl.cell)).cellSize.height;
    segmentedControlFrame.origin.x = self.bounds.origin.x +
            (self.bounds.size.width - segmentedControlFrame.size.width) / 2;
    segmentedControlFrame.origin.y = self.bounds.origin.y;

    [segmentedControl setFrame:segmentedControlFrame];    
}

#pragma setters and getters for the colours.

-(void)setBackgroundColor:(NSColor *)aColor {
    [backgroundColor release];
    backgroundColor = [aColor retain];
    [self setNeedsDisplay:YES];
}

-(NSColor *)backgroundColor {
    return backgroundColor;
}

-(void)setWindowBackgroundColor:(NSColor *)aColor {
    [windowBackgroundColor release];
    windowBackgroundColor = [aColor retain];
    [self setNeedsDisplay:YES];
}

-(NSColor *)windowBackgroundColor {
    return backgroundColor;
}

-(void)setBezelColor:(NSColor *)aColor {
    [bezelColor release];
    bezelColor = [aColor retain];
    [self setNeedsDisplay:YES];
}

-(NSColor*)bezelColor {
    return bezelColor;
}

// Pain the entire area in the background colour of the main panel
// and then overlay a rectangle with a large 'hole' in the middle which
// casts a shadow on this background. As to make the bezel. And if
// needed - draw the background of the currently visible view 'under' this
// hole -- as to clip it (on OSX the views do not inherit clipping paths
// from each other it seems).
//
-(void)drawRect:(NSRect)dirtyRect {
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];

	CGRect outerside = NSRectToCGRect(self.bounds);
    CGRect inside = NSRectToCGRect(self.bounds);
    
    // We inset the hole by roughly half the hight of the selection bar at the
    // top - with a bit of movement down as to make it look optically pleasing
    // around the shadow cast by the bar itself.
    //
    const double S = kSegHeight / 2;
    inside.origin.x += S/2;
    inside.origin.y += S/2 + 2.0;
    inside.size.width -= S;
    inside.size.height -= S;
    
    NSColor * bgColor = nil;

    NSView * cv = [self selectedTabViewItem].view;
    if ([cv respondsToSelector:@selector(backgroundColor)]) {
        bgColor = (NSColor *)[cv performSelector:@selector(backgroundColor)]; 
    };    

    if (bgColor == nil) {
        bgColor = self.backgroundColor;
    };
    
    if (bgColor) {
        CGContextSetFillColorWithColor(ctx, [bgColor CGColor]);
        CGContextFillRect(ctx, inside);
    }

    CGContextSetStrokeColorWithColor(ctx, [bezelColor CGColor]);
    CGContextSetFillColorWithColor(ctx,[windowBackgroundColor CGColor]);

    CGContextSaveGState(ctx);
    
    self.shadow = [[[NSShadow alloc] init] autorelease];
    [self.shadow setShadowColor:bezelColor /* [NSColor lightGrayColor] */];
    [self.shadow setShadowBlurRadius:3];
    [self.shadow setShadowOffset:NSMakeSize(1,-1)];
    [self.shadow set];
    
	CGPathRef roundedRectPath = [self newPathForRoundedRect:inside radius:kRadius];
    CGContextAddPath(ctx, roundedRectPath);
    CGContextAddReverseRect(ctx,outerside);
    
    CGContextClosePath(ctx);
	CGContextFillPath(ctx);

    // The rounded textured style is semi translucent; so we
    // need to paint a bit of background behind it as to avoid
    // the edge&shadow shining through. We also acknowledge that 
    // it has round edges here. And we need a bit of shadow 
    // behind it too - as the segmentedControl is too transparant
    // do do anything useful here.
    //
    CGRect barFrame =  NSRectToCGRect(segmentedControl.frame);
    barFrame.origin.x += 2.0; 
    barFrame.origin.y += 2.0;
    barFrame.size.width -= 4.0;  
    barFrame.size.height -= 5.0;
	CGPathRef barPath = [self newPathForRoundedRect:barFrame radius:2.0];
    CGContextAddPath(ctx, barPath); CGContextClosePath(ctx);
	CGContextFillPath(ctx);

    // Remove shadow again - and draw a very thin outline around it all.
    //
    self.shadow = nil;
    CGContextRestoreGState(ctx);
    
    CGContextAddPath(ctx, roundedRectPath);
    CGContextClosePath(ctx);
    CGContextSetLineWidth(ctx, 0.2);
	CGContextStrokePath(ctx);

    // and wipe the line behind the bezel again.
    //
    CGContextAddPath(ctx, barPath); CGContextClosePath(ctx);
	CGContextFillPath(ctx);

	CGPathRelease(roundedRectPath);
	CGPathRelease(barPath);
    
}
-(void) dealloc {
    
    self.backgroundColor = nil;
    self.windowBackgroundColor = nil;
    self.bezelColor = nil;
    self.segmentedControl = nil;
    [super dealloc];
}
@end
