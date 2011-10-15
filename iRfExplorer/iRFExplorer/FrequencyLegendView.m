//
//  FrequencyLegendView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 12/10/2011.
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
    [device release];
    device = [_device retain];
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
    
    const float OS = 8.0;

    NSLog(@"drawRect of %@", self.className);

    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    if (0) {
        CGContextSetRGBFillColor (cref, 1,1,1,1);
        CGContextFillRect (cref, rect);
    };
    
    

    float Sx = (rect.size.width-SOX);
    float sx = Sx/device.fSpanMhz;
    
    float ox = SOX/2 + rect.origin.x;
    float oy = 0.95 * rect.size.height+ rect.origin.y;

    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);
    
    CGPoint hl[] = { CGPointMake(ox-OS,oy), CGPointMake(ox+Sx+OS, oy) };    
    CGContextStrokeLineSegments(cref, hl, 2 );
    
    if (ticks == nil || ticks.count == 0)
        return;
    
    for(int i = 0; i < ticks.count; i++) {
        TickMark * m = [ticks objectAtIndex:i];
        float v = m.value;
        
        float x = ox + (v - device.fStartMhz) * sx;
        
        CGPoint tick[] = { CGPointMake(x,oy), CGPointMake(x, oy-OS * ((i % 5) ? 1 : 2)) };    
        CGContextStrokeLineSegments(cref, tick, 2 );
        
        NSSize s = [m.labelStr sizeWithAttributes:nil];
        
        float lx = x - s.width/2.0;
        float ly = oy - s.height - OS*2;
        
        [m.labelStr drawAtPoint:NSMakePoint(lx,ly) 
                 withAttributes:nil];
    }    
}

@end
