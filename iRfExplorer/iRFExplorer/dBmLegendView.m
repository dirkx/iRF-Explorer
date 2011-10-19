//
//  dBmLegendView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 14/10/2011.
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
//

#import "dBmLegendView.h"
#import "StringScaleDefinition.h"
#import "TickScaler.h"

@implementation dBmLegendView
@synthesize ticks, graphView;

-(RFExplorer *)device { 
    return device; 
}

-(void)setDevice:(RFExplorer *)_device {
    if (device != _device) {
        [device release];
        device = [_device retain];
    };
    
    [self setNeedsDisplay:YES];
}

-(void)setNeedsDisplay:(BOOL)flag {
    [super setNeedsDisplay:flag];
    
    if (device == nil)
        return;
    
    if (device.fAmplitudeBottom == device.fAmplitudeTop) 
        return;
        
    NumericScaleDefinition * ns = [TickScaler calculateIdealScaleFromMin:device.fAmplitudeBottom  
                                                                 withMax:device.fAmplitudeTop
                                   ];
    
    StringScaleDefinition * scale = [[StringScaleDefinition alloc] initWithNumericScaleDefinition:ns 
                                                              withDataMin:device.fAmplitudeBottom 
                                                              withDataMax:device.fAmplitudeTop 
                                                                 withUnit:@"dBm"];
    self.ticks = scale.ticks;
    
    [scale release];
}

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;
    NSRect graphRect = graphView.bounds;
    
    // NSLog(@"drawRect of %@", self.className);
    
    const float kMargin = 4;
 
    
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    if (FALSE) {
        CGContextSetRGBFillColor (cref, 1,1,1,1);
        CGContextFillRect (cref, rect);
    };
    
    /* 2011-10-16 17:27:35.315 iRFExplorer[44812:707] LE: Frame: {{ 4,  5}, { 59, 278}} and bounds {{0, 0}, {59, 278}}
     * 2011-10-16 17:27:35.316 iRFExplorer[44812:707] GR: Frame: {{88, 75}, {355, 180}} and bounds {{0, 0}, {355, 180}}
     */
    float dy = self.graphView.frame.origin.y - self.frame.origin.y + ( self.graphView.frame.size.height - self.frame.size.height);
        
    float height = graphRect.size.height;
    
    float sy = 0.90 * height;
    float Sy = sy / device.fAmplitudeSpan;

    float oy = rect.origin.y + rect.size.height - 0.95 * height + dy;
    float ox = rect.size.width + rect.origin.x - 2*kMargin;
    
    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0.4,0,0,1);

    float y0 = oy;
    float y1 = oy+sy;
    if (ticks == nil || ticks.count == 0) {
        CGPoint v[] = { 
            CGPointMake(ox,y0), 
            CGPointMake(ox,y1) 
        };    
        CGContextStrokeLineSegments(cref, v, 2 );
        return;
    };
    
    // Marks at the actual possible range.
    CGPoint l0[] = { 
        CGPointMake(ox,y0), 
        CGPointMake(ox+kMargin,y0) 
    };    
    CGContextStrokeLineSegments(cref, l0, 2 );
    
    CGPoint l1[] = { 
        CGPointMake(ox,y1), 
        CGPointMake(ox+kMargin,y1) 
    };    
    CGContextStrokeLineSegments(cref, l1, 2 );
    

    CGContextSetRGBStrokeColor(cref, 0,0,0.4,1);

    // Vertical line may be longer if the tick range is rounded
    // to a value just outside the actual data range. But we do
    // up to 4 pixels grace.
    //
    float v0 = ((TickMark*)[ticks objectAtIndex:0]).value;
    float y00 = oy + Sy * (v0 - device.fAmplitudeBottom);
    if (y00 < y0) {
        y0 = MAX(y00, y0 - 4);
    }

    float v1 = ((TickMark*)[ticks lastObject]).value;
    float y11 = oy + Sy * (v1 - device.fAmplitudeBottom);
    if (y11 > y1) {
        y1 = MIN(y11, y1 + 4);
    };

    CGPoint l[] = { 
        CGPointMake(ox,y0), 
        CGPointMake(ox,y1) 
    };    
    CGContextStrokeLineSegments(cref, l, 2 );

    for(NSUInteger i = 0; i < ticks.count; i++) {
        TickMark * m = [ticks objectAtIndex:i];
        float v = m.value;
        float y = oy + Sy * (v - device.fAmplitudeBottom);

        if (y < oy - 4)
            continue;
        if (y > oy + sy + 4)
            continue;
        
        CGPoint l[] = { 
            CGPointMake(ox,y),
            CGPointMake(ox-kMargin,y) 
        };    
        CGContextStrokeLineSegments(cref, l, 2 );
        
        NSSize s = [m.labelStr sizeWithAttributes:nil];
        
        float lx = ox - s.width-2*kMargin;
        float ly = y - s.height / 2.0 + kMargin / 2.0;
        
        [m.labelStr drawAtPoint:NSMakePoint(lx,ly)
               withAttributes:nil];
    };    
    
    // Labeling of the axis. We do this last - so we do not
    // have to bother about restoring the rotation/translation
    // matrix state.
    if (TRUE) {
        NSString * graphLabel = @"signal (dBm)";

        NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                               // [NSFont fontWithName:@"Helvetica" size:36], NSFontAttributeName,
                               [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                               nil];

        NSSize s = [graphLabel sizeWithAttributes:attr];
        NSPoint center = NSMakePoint(self.bounds.origin.x + s.height/2 + 4, self.bounds.origin.y + self.bounds.size.height * 0.55);
        
        NSAffineTransform *rotate = [[NSAffineTransform alloc] init];
        
        [rotate translateXBy:center.x yBy:center.y];
        [rotate rotateByDegrees:-90.f];
        [rotate concat];
        
        [graphLabel drawAtPoint:NSMakePoint(-s.width/2,-s.height/2) withAttributes:attr];
        
        [rotate release];
    }
}
-(void)dealloc {
    self.device = nil;
    self.ticks = nil;
    self.graphView = nil;

    [super dealloc];
}
@end
