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
#import "PreferenceConstants.h"
#import "SpectrumGraphView.h"
#import "NSViewExtensions.h"
#import "NSStringExtensions.h"

@implementation SpectrumGraphView

@synthesize decayInSeconds, averagingTimeWindowInSeconds;

const CGFloat SOX = 0.f; // spacing left/right (total)
const CGFloat SOY = 0.f; // spacing top/bottom (total)
const int OS = 8;      // overshoot axises

#define CGPointMakeFromDoubles(x,y) CGPointMake((CGFloat)(x),(CGFloat)(y))

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
    
    if (spectrum == nil || [spectrum count] == 0)
        return;
    
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

    if (avgVals == nil && maxVals == nil)
        return;
    
    if (avgVals && avgVals.count == 0) {
        [avgVals setArray:spectrum.dbValues];
        for(int i = 0; i < avgVals.count; i++)
            [sdVals addObject:[NSNumber numberWithDouble:0.0]];
    }
    
    if (maxVals && maxVals.count == 0) 
        [maxVals setArray:spectrum.dbValues];

    for(NSUInteger i = 0; i < spectrum.dbValues.count; i++) {
        double v = [[spectrum.dbValues objectAtIndex:i] doubleValue];
        
        if (avgVals && i < avgVals.count) {
            double a = [[avgVals objectAtIndex:i] doubleValue];
            double olda = a;
            double sd = [[sdVals objectAtIndex:i] doubleValue];
            double samples = averagingTimeWindowInSeconds / updateTimeInterval;

            a = ((samples-1) * a + v)/samples;
            [avgVals replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:a]];                
            
            sd =((samples-1) * sd  + (v - olda)*(v - a))/ samples ;
            [sdVals replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:sd]];                
        }
        if (maxVals && i < maxVals.count) {
            double mm = [[maxVals objectAtIndex:i] doubleValue];
            double m = mm;
            if (v > m)
                m = v;
            if (decayInSeconds > 0.0 && decay)
                m -= (m - v) / decayInSeconds * updateTimeInterval;
            if (mm != m)
                [maxVals replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:m]];
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
    
    maxVals = [[NSMutableArray array] retain];    
    [self setNeedsDisplay:YES];
}

-(void)setAndResetShowAvg:(BOOL)newState {
    [avgVals release]; [sdVals release];
    avgVals = nil; sdVals = nil;
    
    if (!newState)
        return;
    
    avgVals = [[NSMutableArray array] retain];
    sdVals = [[NSMutableArray array] retain];
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
        CGContextFillRect(cref, NSRectToCGRect(rect));
    };
    
    double sx = (rect.size.width-SOX) / device.fSpanHz;
    double sy = (rect.size.height-SOY) / device.fAmplitudeSpan;
    
    CGFloat ox = SOX/2 + rect.origin.x;
    CGFloat oy = SOY/2 + rect.origin.y;

    // Draw axises used - to verify alighment with scales.
    //    
    if (FALSE) {
        CGContextSetLineWidth(cref, 1.0f);
        CGContextSetRGBStrokeColor(cref, 0.f,0.f,0.4f,1.f);
        
        CGPoint hl[] = { 
            CGPointMakeFromDoubles(ox-OS*10,oy), 
            CGPointMakeFromDoubles(ox+sx*spectrum.count+OS*10, oy) 
        };    
        CGContextStrokeLineSegments(cref, hl, 2 );

        CGPoint hl2[] = { 
            CGPointMakeFromDoubles(ox-10*OS,                   oy + sy*device.fAmplitudeSpan),
            CGPointMakeFromDoubles(ox+sx*spectrum.count+OS*10, oy + sy*device.fAmplitudeSpan) 
        };    
        CGContextStrokeLineSegments(cref, hl2, 2 );

        CGPoint vl[] = { 
            CGPointMakeFromDoubles(ox,oy-OS*20), 
            CGPointMake(ox, oy + sy * device.fAmplitudeSpan + OS) 
        };    
        CGContextStrokeLineSegments(cref, vl, 2 );
    };
    
    NSUInteger hi = 0;
    double ha = 0;
    int src = 0;
    
    // Drawing of the vertial spectrum lines.
    //    
    if (TRUE) {
        for(NSUInteger i = 0; i < spectrum.count; i++) {
            double f = [[spectrum.frequenciesHz objectAtIndex:i] doubleValue];
            double x = ox + (device.fStepHz/2 + f - device.fStartHz) * sx;
            
            double v = [[spectrum.dbValues objectAtIndex:i] doubleValue];
            
            if (i == 0 || v > ha) {
                ha = v; hi = i; 
            }
            
            if (v <  device.fAmplitudeBottom)
                v = device.fAmplitudeBottom;
            
            if (v > device.fAmplitudeTop)
                v = device.fAmplitudeTop;
            
            v -= device.fAmplitudeBottom;
            double y = oy + v * sy;
            
            CGContextMoveToPoint(cref, (CGFloat)x,oy);
            CGContextAddLineToPoint(cref, (CGFloat)x, (CGFloat)y);
            
        };
        CGContextSetLineWidth(cref, (CGFloat)(0.42 * rect.size.width / device.nFreqSpectrumSteps));
        CGContextSetRGBStrokeColor(cref, 0,0,0,1);
        CGContextStrokePath(cref);
    }
    
    // Blue Average line
    //
    if (avgVals && avgVals.count>0) {
        double bot[avgVals.count];
        double xv[avgVals.count];
        
        CGMutablePathRef topPath = CGPathCreateMutable();
        CGMutablePathRef botPath = CGPathCreateMutable();
        CGMutablePathRef encPath = CGPathCreateMutable();
        
        for(NSUInteger i = 0; i < avgVals.count; i++) {
            double f = [[spectrum.frequenciesHz objectAtIndex:i] doubleValue];
            double x = ox + (device.fStepHz/2 + f - device.fStartHz) * sx;
            
            double v = [[avgVals objectAtIndex:i] doubleValue];
            double sd = [[sdVals  objectAtIndex:i] doubleValue];
 
            if (v >= ha) {
                ha = v; hi = i; src = 1;
            }
            
            if (v <  device.fAmplitudeBottom)
                v = device.fAmplitudeBottom;
            
            if (v > device.fAmplitudeTop)
                v = device.fAmplitudeTop;
            
            v -= device.fAmplitudeBottom;
            double y = oy + v * sy;
            double sdy =   sd * sy;
            
            if (i == 0)
                CGContextMoveToPoint(cref,x,y);
            else
                CGContextAddLineToPoint(cref,x,y);
            
            // Already draw the left to right top part of the
            // SD area - and keep data so we can create the 
            // reverse path once we have all the values.
            xv[i] = x;
            bot[i] = y - sqrt(sdy);
            y = y + sqrt(sdy);
            if (i == 0) {
                CGPathMoveToPoint(topPath, nil, x, y);
                CGPathMoveToPoint(encPath, nil, x, y);
            } else {
                CGPathAddLineToPoint(topPath, nil, x, y);
                CGPathAddLineToPoint(encPath, nil, x, y);
            }
        };
        
        // And creation of the mirror path from right to left
        // along with the enclosing area.
        //
        for(NSUInteger i = avgVals.count; i > 0; i--) {
            double y = bot[i-1];
            double x = xv[i-1];
            if (i ==  avgVals.count) {
                CGPathMoveToPoint(botPath, nil, x, y);
                CGPathAddLineToPoint(encPath, nil, x, y);
            } else {
                CGPathAddLineToPoint(botPath, nil, x, y);
                CGPathAddLineToPoint(encPath, nil, x, y);
            }
        };
        CGPathCloseSubpath(encPath);
        
        CGContextSetLineWidth(cref, MIN(3.0, 2.0 * rect.size.width / 480.0));
        CGContextSetRGBStrokeColor(cref, 0,0,0.8,0.7);
        CGContextStrokePath(cref);
        
        CGContextSetRGBFillColor(cref, 0,0,0.8,0.3);
        CGContextAddPath(cref, encPath);
        CGContextFillPath(cref);

        CGContextSetLineWidth(cref, MIN(1.0, 1.0 * rect.size.width / 480.0));
        CGContextSetRGBStrokeColor(cref, 0,0,0.8,0.5);
        CGContextAddPath(cref, topPath);
        CGContextAddPath(cref, botPath);
        CGContextStrokePath(cref);
        
        CGPathRelease(topPath);
        CGPathRelease(botPath);
        CGPathRelease(encPath);
    };
            
    // Red Average line
    //
    if (maxVals) {
        for(NSUInteger i = 0; i < maxVals.count; i++) {
            double f = [[spectrum.frequenciesHz objectAtIndex:i] doubleValue];
            double x = ox + (device.fStepHz/2 +f - device.fStartHz) * sx;
            
            double v = [[maxVals objectAtIndex:i] doubleValue];
            
            if (v >= ha) {
                ha = v; hi = i; src = 2;
            }
            if (v <  device.fAmplitudeBottom)
                v = device.fAmplitudeBottom;
            
            if (v > device.fAmplitudeTop)
                v = device.fAmplitudeTop;
            
            v -= device.fAmplitudeBottom;
            double y = oy + v * sy;
            
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
        double f = [[spectrum.frequenciesHz objectAtIndex:hi] doubleValue];
        double x = ox + (device.fStepHz/2 + f - device.fStartHz) * sx;
        
        double v = ha;
        double V = v; //  + device.fAmplitudeBottom;
        double y = oy + (v - device.fAmplitudeBottom) * sy;
        
        y += OS + 2;

        NSString * lf = [NSString stringFromHz:f];
        NSString * la = [NSString stringWithFormat:@"%.1f dBm", V];
        
        NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSFont fontWithName:kMainFont size:kMainMediumFontSize], NSFontAttributeName,
                               [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                               nil];
        
        NSSize sa = [la sizeWithAttributes:attr];
        NSSize sf = [lf sizeWithAttributes:attr];
        
        double h = sa.height + sf.height + 3 * OS;

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
        
        double ss = MAX(sa.width, sf.width);
        double xa = x - sa.width/2;
        double xf = x - sf.width/2;
        
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
    [sdVals release];
    [device release];
    [lastUpdate release];
    
    [super dealloc];
}

@end
