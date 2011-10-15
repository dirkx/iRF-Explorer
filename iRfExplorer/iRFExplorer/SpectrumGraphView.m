//
//  SpectrumGraph.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 11/10/2011.
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

#import "SpectrumGraphView.h"

@implementation SpectrumGraphView

@synthesize device;

const float SOX = 12.0; // spacing left/right (total)
const float SOY = 12.0; // spacing top/bottom (total)
const int OS = 8;


-(Spectrum *)spectrum { 
    return spectrum; 
}

-(void)setSpectrum:(Spectrum *)_spectrum {
    [spectrum release];
    spectrum = [_spectrum retain];
    
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;

    NSLog(@"Drawrect of %@", self.className);

    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];

    if (0) {
        CGContextSetRGBFillColor (cref, 1,1,1,1);
        CGContextFillRect (cref, rect);
    };
    
    float sx = (rect.size.width-SOX) / device.fSpanMhz;
    float sy = 0.90*rect.size.height / device.fAmplitudeSpan;
    
    float ox = SOX/2 + rect.origin.x;
    float oy = 0.05*rect.size.height + rect.origin.y;

    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0.4,1);

    if (FALSE) {
        CGPoint hl[] = { 
            CGPointMake(ox-OS*10,oy), 
            CGPointMake(ox+sx*spectrum.count+OS*10, oy) 
        };    
        CGContextStrokeLineSegments(cref, hl, 2 );

        CGPoint hl2[] = { 
            CGPointMake(ox-10*OS,                   oy + sy*device.fAmplitudeSpan),
            CGPointMake(ox+sx*spectrum.count+OS*10, oy + sy*device.fAmplitudeSpan) 
        };    
        CGContextStrokeLineSegments(cref, hl2, 2 );

        CGPoint vl[] = { 
            CGPointMake(ox,oy-OS*20), 
            CGPointMake(ox, oy + sy * device.fAmplitudeSpan + OS) 
        };    
        CGContextStrokeLineSegments(cref, vl, 2 );
    };
    
    
    for(NSUInteger i = 0; i < spectrum.count; i++) {
        float v = [[spectrum.dbValues objectAtIndex:i] floatValue] - device.fAmplitudeMin;
        float f = [[spectrum.frequenciesMhz objectAtIndex:i] floatValue];
        
        double x = ox + (f - device.fStartMhz) * sx;
        double y = oy + v * sy;
        
        CGContextStrokeRect(cref, CGRectMake(x-2, y-2, 4,4));
    };

    CGContextSetLineWidth(cref, 2.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);
    
    CGContextBeginPath(cref);    
    for(NSUInteger i = 0; i < spectrum.count; i++) {
        float v = [[spectrum.dbValues objectAtIndex:i] floatValue] - device.fAmplitudeMin;
        float f = [[spectrum.frequenciesMhz objectAtIndex:i] floatValue];
        
        double x = ox + (f - device.fStartMhz) * sx;
        double y = oy + v * sy;
                
        if (i == 0)
            CGContextMoveToPoint(cref, x, y);
        else
            CGContextAddLineToPoint(cref, x, y);        
    };
    CGContextDrawPath(cref,kCGPathStroke);
}

@end
