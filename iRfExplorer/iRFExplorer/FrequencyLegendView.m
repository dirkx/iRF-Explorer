//
//  FrequencyLegendView.m
//  iRFExplorer
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

#import "FrequencyLegendView.h"
#import "TickScaler.h"

@implementation FrequencyLegendView

@synthesize graphView, ticks;

extern const float SOX;
extern float SOY;

-(RFExplorer *)device { 
    return device; 
}

-(void)setDevice:(RFExplorer *)_device {
    if (device != _device) {
        [device release];
        device = [_device retain];
    };
    
    [self setNeedsLayout:TRUE];
}

-(void)setNeedsDisplay:(BOOL)flag {
    [super setNeedsDisplay:flag];

    if (!device || device.fStartMhz == device.fEndMhz)
        return;
        
    float min = device.fStartMhz;
    float max = device.fEndMhz;
        
    NumericScaleDefinition * ns = [TickScaler calculateIdealScaleFromMin:min
                                                                 withMax:max
                                   ];
    
    StringScaleDefinition * scale = [[StringScaleDefinition alloc] initWithNumericScaleDefinition:ns 
                                                                                      withDataMin:min
                                                                                      withDataMax:max
                                                                                         withUnit:@"Mhz"];
    
    self.ticks = scale.ticks;
    [scale release];
}

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;
    NSRect spectrumRect = graphView.bounds;
    
    const float OS = 8.0;

    // NSLog(@"drawRect of %@", self.className);

    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    if (0) {
        CGContextSetRGBFillColor (cref, 1,1,.2,1);
        CGContextFillRect (cref, rect);
    };

    float Sx = (spectrumRect.size.width-SOX);
    float sx = Sx/device.fSpanMhz;

    /* 2011-10-16 14:46:42.245 iRFExplorer[39566:707] LE: Frame: {{63, 5}, {394, 54}} and bounds {{0, 0}, {394, 54}}
     * 2011-10-16 14:46:42.246 iRFExplorer[39566:707] GR: Frame: {{88, 75}, {355, 180}} and bounds {{0, 0}, {355, 180}}
     */
    float dX = self.graphView.frame.origin.x - self.frame.origin.x;
    
    float ox = SOX/2 + rect.origin.x + dX;
    float oy = 0.95 * rect.size.height+ rect.origin.y;

    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);
    
    // Line actual range
    CGPoint hl[] = { CGPointMake(ox,oy), CGPointMake(ox+Sx, oy) };    
    CGContextStrokeLineSegments(cref, hl, 2 );
    
    // show actual range
    //
    if (TRUE) {
        float v0 = device.fStartMhz;
        float v1 = device.fEndMhz;

        float x0 = ox + (v0 - device.fStartMhz) * sx;
        float x1 = ox + (v1 - device.fStartMhz) * sx;
        
        CGPoint vt0[] = { CGPointMake(x0,oy), CGPointMake(x0,oy+OS) };    
        CGContextStrokeLineSegments(cref, vt0, 2 );

        CGPoint vt1[] = { CGPointMake(x1,oy), CGPointMake(x1,oy+OS) };    
        CGContextStrokeLineSegments(cref, vt1, 2 );
    }

    
    if (ticks == nil || ticks.count == 0)
        return;

    // Labeling of the axis.
    //
    if (TRUE) {
        NSString * l = @"frequency (Mhz)";
        NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                               // [NSFont fontWithName:@"Helvetica" size:36], NSFontAttributeName,
                               [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                               nil];
        
        NSSize s = [l sizeWithAttributes:attr];
        NSPoint center = NSMakePoint(self.bounds.origin.x + (self.bounds.size.width - s.width)/2, 
                                     self.bounds.origin.y + OS);
        [l drawAtPoint:center withAttributes:attr];
    }    
    
    // Line first/last tick.
    //
    CGPoint hl2[] = { 
        CGPointMake(ox + (((TickMark *)[ticks objectAtIndex:0]).value - device.fStartMhz) * sx,oy), 
        CGPointMake(ox + (((TickMark *)[ticks lastObject]).value - device.fStartMhz) * sx,oy), 
    };    
    CGContextStrokeLineSegments(cref, hl2, 2 );

    for(int i = 0; i < ticks.count; i++) {
        TickMark * m = [ticks objectAtIndex:i];
        float v = m.value;
        
        float x = ox + (v - device.fStartMhz) * sx;
        
        if (x < ox - 4)
            continue;
        if (x > ox + Sx + 4)
            continue;
        
        CGPoint tick[] = { CGPointMake(x,oy), CGPointMake(x, oy-OS * ((i % 5) ? 1 : 2)) };    
        CGContextStrokeLineSegments(cref, tick, 2 );
        
        NSSize s = [m.labelStr sizeWithAttributes:nil];
        
        float lx = x - s.width/2.0;
        float ly = oy - s.height - OS*2;
        
        [m.labelStr drawAtPoint:NSMakePoint(lx,ly) 
                 withAttributes:nil];
        
    }    
}

-(void)dealloc {
    [device release];
    [graphView release];
    [ticks release];
    
    [super dealloc];
}
@end
