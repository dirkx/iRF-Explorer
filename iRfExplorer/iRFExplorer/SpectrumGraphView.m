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

@synthesize minSetpoint, maxSetPoint, fixedRange, device;

-(Spectrum *)spectrum { 
    return spectrum; 
}

-(void)setSpectrum:(Spectrum *)_spectrum {
    [spectrum release];
    spectrum = [_spectrum retain];
    
    if (fixedRange) {
        min = minSetpoint;
        max = maxSetPoint;
    } else {
        min = device.fAmplitudeBottom;
        max = device.fAmplitudeTop;
    };
    
    if (min == max)
        max = min + 1.0;

#if 0
    NSLog(@"First/Last %f, %f - min/max %f,%f -- %d",
          [[arr objectAtIndex:0] floatValue],
          [[arr objectAtIndex:arr.count -1 ] floatValue],
          min,max, arr.count);
#endif
    
    [self setNeedsDisplay:YES];
}

-(NSRect)rectFoStartFreqMhz:(float)fMhz {
    NSRect rect = self.bounds;
    
    float sx = 0.90 * rect.size.width/device.fFullRangeMhz;
    float ox = 0.05 * rect.size.width + rect.origin.x;
    
    rect.origin.x = ox + (fMhz - device.fMinFreqMhz) * sx;
    
    rect.origin.y = self.visibleRect.origin.y;
    rect.size = self.visibleRect.size;

    NSLog(@"VPort at %f,%f x %f,%f",
          self.visibleRect.origin.x, self.visibleRect.origin.y, 
          self.visibleRect.size.width, self.visibleRect.size.height);

    NSLog(@"Directing to %f,%f x %f,%f",
          rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    return rect;
}

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;

    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];

    if (0) {
    CGContextSetRGBFillColor (cref, 1,1,1,1);
    CGContextFillRect (cref, rect);
    };
    
    if (spectrum.count == 0)
        return;
    
    float sx = 0.90 * rect.size.width/device.fFullRangeMhz;
    float sy = 0.90 * rect.size.height / (max - min);
    
    float ox = 0.05 * rect.size.width + rect.origin.x;
    float oy = 0.05 * rect.size.height+ rect.origin.y;

    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0.4,1);

    const int OS = 16;

    CGPoint hl[] = { CGPointMake(ox-OS,oy), CGPointMake(ox+sx*spectrum.count+OS, oy) };    
    CGContextStrokeLineSegments(cref, hl, 2 );

    // enable to check correct alignment dBm frequency legend. We have two magic
    // constants there (30,1). Scroll all the way to the lowest frequency to check
    // that the top/bottom lines match those of the dBm scale.
    //
    if (1) {
        CGPoint hl2[] = { 
            CGPointMake(ox-OS,oy + sy*(max-min)),
            CGPointMake(ox+sx*spectrum.count+OS, oy+sy* (max-min)) 
        };    
        CGContextStrokeLineSegments(cref, hl2, 2 );
    };
    
    CGPoint vl[] = { CGPointMake(ox,oy-OS*20), CGPointMake(ox, oy + sy * (max - min) + OS) };    
    CGContextStrokeLineSegments(cref, vl, 2 );
    
    for(NSUInteger i = 0; i < spectrum.count; i++) {
        float v = [[spectrum.dbValues objectAtIndex:i] floatValue] - min;
        float f = [[spectrum.frequenciesMhz objectAtIndex:i] floatValue];
        
        double x = ox + (f - device.fMinFreqMhz) * sx;
        double y = oy + v * sy;
        
        CGContextStrokeRect(cref, CGRectMake(x-2, y-2, 4,4));
    };

    CGContextSetLineWidth(cref, 2.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);
    
    CGContextBeginPath(cref);    
    for(NSUInteger i = 0; i < spectrum .count; i++) {
        float v = [[spectrum.dbValues objectAtIndex:i] floatValue] - min;
        float f = [[spectrum.frequenciesMhz objectAtIndex:i] floatValue];

        double x = ox + (f - device.fMinFreqMhz) * sx;
        double y = oy + v * sy;
        
        if (i == 0)
            CGContextMoveToPoint(cref, x, y);
        else
            CGContextAddLineToPoint(cref, x, y);        
    };
    CGContextDrawPath(cref,kCGPathStroke);
}

@end
