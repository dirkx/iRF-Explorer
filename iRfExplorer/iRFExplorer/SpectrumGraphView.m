//
//  SpectrumGraph.m
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
//

#import "SpectrumGraphView.h"
#import "NSViewExtensions.h"

@implementation SpectrumGraphView

@synthesize decayInSeconds, averagingTimeWindowInSeconds;

const float SOX = 0.0; // spacing left/right (total)
const float SOY = 0.0; // spacing top/bottom (total)
const int OS = 8;      // overshoot axises

-(void)newConfig:(id)sender {
    [super newConfig:sender];
    [self resetCalculations];
}

-(void)newBoard:(id)sender {
    [super newBoard:sender];
    [self resetCalculations];
}
-(Spectrum *)spectrum { 
    return spectrum; 
}

-(void)setSpectrum:(Spectrum *)_spectrum {
    if (spectrum != _spectrum) {
        [spectrum release];
        spectrum = [_spectrum retain];
    };
    
#ifndef UPDATE_TIMER_WINDOW
#define UPDATE_TIMER_WINDOW (100)
#endif
    
    if (lastUpdate) {
        NSTimeInterval d = -[lastUpdate timeIntervalSinceNow];

        if (updateTimeInterval < 0.001)
            updateTimeInterval = d;
        
        updateTimeInterval = (updateTimeInterval * (UPDATE_TIMER_WINDOW-1) + d)/UPDATE_TIMER_WINDOW;
    } else {
        updateTimeInterval = 0.0001;
    };
    
    [lastUpdate release];
    lastUpdate = [[NSDate date] retain];
    
    [self setNeedsDisplay:YES];

    if (!(avgVals|| maxVals))
        return;
    
    for(NSUInteger i = 0; i < spectrum.count; i++) {
        float v = [[spectrum.dbValues objectAtIndex:i] floatValue];
        if (avgVals) {
            float a = [[avgVals objectAtIndex:i] floatValue];
            float samples = averagingTimeWindowInSeconds / updateTimeInterval;
            a = ((samples-1) * a + v)/samples;

            [avgVals replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:a]];                
        }
        if (maxVals) {
            float mm = [[maxVals objectAtIndex:i] floatValue];
            float m = mm;
            if (v > m)
                m = v;
            if (decayInSeconds > 0.0 && decay)
                m -= (m - v) / decayInSeconds * updateTimeInterval;
            if (mm != m)
                [maxVals replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:m]];
        }
    }
}

-(void)resetCalculations {
    [self setAndResetShowAvg:avgVals != nil];
    [self setAndResetShowMax:maxVals != nil];
}

-(void)setAndResetShowMax:(BOOL)newState {
    [maxVals release];
    maxVals = nil;

    if (!newState)
        return;
    
    maxVals = [[NSMutableArray arrayWithArray:spectrum.dbValues] retain];
    
    [self setNeedsDisplay:YES];
}

-(void)setAndResetShowAvg:(BOOL)newState {
    [avgVals release];
    avgVals = nil;
    
    if (!newState)
        return;
    
    averagingTimeWindowInSeconds = 50;
    avgVals = [[NSMutableArray arrayWithArray:spectrum.dbValues] retain];

    [self setNeedsDisplay:YES];
}

-(void)setAndResetDecay:(BOOL)newState {
    decay = newState;
}

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;

    if (device == nil)
        return;
    
    // NSLog(@"Drawrect of %@", self.className);

    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];

    // Background
    
    if (FALSE) {
        CGContextSetRGBFillColor (cref, 1,1,1,1);
        CGContextFillRect (cref, rect);
    };
    
    float sx = (rect.size.width-SOX) / device.fSpanHz;
    float sy = (rect.size.height-SOY) / device.fAmplitudeSpan;
    
    float ox = SOX/2 + rect.origin.x;
    float oy = SOY/2 + rect.origin.y;

    // Draw axises used - to verify alighment with scales.
    //    
    if (FALSE) {
        CGContextSetLineWidth(cref, 1.0);
        CGContextSetRGBStrokeColor(cref, 0,0,0.4,1);
        
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
    
    NSUInteger hi = 0;
    float ha = 0;
    int src = 0;
    
    // Drawing of the vertial spectrum lines.
    //    
    if (TRUE) {
        for(NSUInteger i = 0; i < spectrum.count; i++) {
            float f = [[spectrum.frequenciesHz objectAtIndex:i] floatValue];
            double x = ox + (f - device.fStartHz) * sx;
            
            float v = [[spectrum.dbValues objectAtIndex:i] floatValue] - device.fAmplitudeMin;
            double y = oy + v * sy;
            
            if (i == 0 || v > ha) {
                ha = v; hi = i; 
            }
            
            CGContextMoveToPoint(cref, x,oy);
            CGContextAddLineToPoint(cref, x, y);
            
        };
        
        CGContextSetLineWidth(cref, 0.42 * rect.size.width / device.nFreqSpectrumSteps);
        CGContextSetRGBStrokeColor(cref, 0,0,0,1);
        CGContextStrokePath(cref);
    }
    
    // Blue Average line
    //
    if (avgVals) {
        for(NSUInteger i = 0; i < spectrum.count; i++) {
            float f = [[spectrum.frequenciesHz objectAtIndex:i] floatValue];
            double x = ox + (f - device.fStartHz) * sx;
            
            float v = [[avgVals objectAtIndex:i] floatValue] - device.fAmplitudeMin;
            double y = oy + v * sy;

            if (v >= ha) {
                ha = v; hi = i; src = 1;
            }
            
            if (i == 0)
                CGContextMoveToPoint(cref,x,y);
            else
                CGContextAddLineToPoint(cref,x,y);
        };
        
        CGContextSetLineWidth(cref, 2.0 * rect.size.width / 480.0);
        CGContextSetRGBStrokeColor(cref, 0,0,0.8,0.7);
        CGContextStrokePath(cref);
    };
    
    // Red Average line
    //
    if (maxVals) {
        for(NSUInteger i = 0; i < spectrum.count; i++) {
            float f = [[spectrum.frequenciesHz objectAtIndex:i] floatValue];
            double x = ox + (f - device.fStartHz) * sx;
            
            float v = [[maxVals objectAtIndex:i] floatValue] - device.fAmplitudeMin;
            double y = oy + v * sy;
            
            if (v >= ha) {
                ha = v; hi = i; src = 2;
            }
            
            if (i == 0)
                CGContextMoveToPoint(cref,x,y);
            else
                CGContextAddLineToPoint(cref,x,y);
        };
        
        CGContextSetLineWidth(cref, 1.0 * rect.size.width / 480.0);
        CGContextSetRGBStrokeColor(cref, 0.8,0,0,1);
        CGContextStrokePath(cref);
    };
    
    // drawing of small arrow at the 'max' value; along with
    // a transp. white rectangle with the value/frequency.
    //
    if (TRUE) {
        float f = [[spectrum.frequenciesHz objectAtIndex:hi] floatValue];
        double x = ox + (f - device.fStartHz) * sx;
        
        float v = ha;
        float V = v + device.fAmplitudeMin;
        double y = oy + v * sy;
        
        y += OS + 2;

        NSString * lf = [NSString stringWithFormat:@"%.2f Hz", f];
        NSString * la = [NSString stringWithFormat:@"%.1f dBm", V];
        
        NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                               // [NSFont fontWithName:@"Helvetica" size:36], NSFontAttributeName,
                               [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                               nil];
        
        NSSize sa = [la sizeWithAttributes:attr];
        NSSize sf = [lf sizeWithAttributes:attr];
        
        float h = sa.height + sf.height + 3 * OS;

        // using colour to indicate source of this value.
        //
        CGContextSetRGBStrokeColor(cref, 
                                   (src == 2) ? 0.8 : 0,
                                   0,
                                   (src == 1) ? 0.8 : 0,
                                   1);
        CGContextSetLineWidth(cref, 1.0 * rect.size.width / 480.0);

        if (y + h > rect.origin.y + rect.size.height) {
            
            y = rect.origin.y + rect.size.height - OS;

            CGContextMoveToPoint(cref,x,y);
            CGContextAddLineToPoint(cref,x+OS,y-OS * 1.5);
            CGContextAddLineToPoint(cref,x-OS,y-OS * 1.5);
            CGContextAddLineToPoint(cref,x,y);            
            CGContextStrokePath(cref);
            
            y = rect.origin.y + rect.size.height - h;
            
        } else {

            CGContextMoveToPoint(cref,x,y);
            CGContextAddLineToPoint(cref,x+OS,y+OS * 1.5);
            CGContextAddLineToPoint(cref,x-OS,y+OS * 1.5);
            CGContextAddLineToPoint(cref,x,y);
            
            CGContextStrokePath(cref);
            
            y += OS *1.5 + 4;
        };        
        
        float ss = MAX(sa.width, sf.width);
        float xa = x - sa.width/2;
        float xf = x - sf.width/2;
        
        if (xa < OS || xf < OS) {
            xa = xf = OS;
        }
        
        if (MAX(xa,xf) +ss  > rect.origin.x + rect.size.width) {
            xa = rect.origin.x + rect.size.width - sa.width - OS;
            xf = rect.origin.x + rect.size.width - sf.width - OS;
        };
#if 0
        CGContextSetRGBFillColor(cref, 1,1,1,0.7);
        CGContextFillRect(cref, CGRectMake(xa-OS, y, ss+2*OS, sa.height + sf.height + 2));
#endif   
        [la drawAtPoint:NSMakePoint(xa,y) withAttributes:attr];
        y += sa.height + 2;
        
        [lf drawAtPoint:NSMakePoint(xf,y) withAttributes:attr];
    }
    
}
-(void)dealloc {
    self.spectrum = nil;
    [avgVals release];
    [maxVals release];
    [device release];
    [lastUpdate release];
    
    [super dealloc];
}

@end
