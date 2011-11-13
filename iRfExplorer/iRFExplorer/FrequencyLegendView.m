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
#import "SpectrumGraphView.h"
#import "TickScaler.h"

@implementation FrequencyLegendView

@synthesize ticks, subTicks, fullRange, graphLabel;

const double kWifiMin = 2412000000.0;
const double kWifiStep = 5000000.0;

-(void)setNeedsDisplay:(BOOL)flag {
    [super setNeedsDisplay:flag];

    if (!device || device.fStartHz == device.fEndHz)
        return;
        
    min = fullRange ? device.fMinFreqHz : device.fStartHz;
    max = fullRange ? device.fMaxFreqHz : device.fEndHz;
    span = fullRange ? (max-min) : device.fSpanHz;
    
    if (wifi) {
        // Note - the curent firmware only goes up to channel 13 it seems.
        int N = (device.fEndHz - kWifiMin) / kWifiStep;
        
        NSMutableArray * am = [NSMutableArray arrayWithCapacity:13];
        for(int i = 1; i <= N; i++) {
            NSString * label = [NSString stringWithFormat:@"%d",i];
            TickMark * tm = [[TickMark alloc] initWithLabelStr:label
                                                    withSiUnit:@"" 
                                                  withSiPrefix:@"" 
                                                     withValue:kWifiMin + kWifiStep * (i-1)
                             ];
            [am addObject:tm];
            [tm release];
        }
        self.ticks = [NSArray arrayWithArray:am];
        self.subTicks = nil;
        self.graphLabel = NSLocalizedString(@"Wifi Channel #", @"Frequency legegend when Wifi channels are shown");
    } else {
        NumericScaleDefinition * ns = [TickScaler calculateIdealScaleFromMin:min
                                                                     withMax:max
                                       ];
        
        StringScaleDefinition * scale = [[StringScaleDefinition alloc] 
                      initWithNumericScaleDefinition:ns 
                                         withDataMin:min
                                         withDataMax:max
                                         withUnit:@"Hz"];
        
        self.ticks = scale.ticks;
        self.subTicks = ns.subTicks;
        self.graphLabel = [NSString stringWithFormat:NSLocalizedString(@"Frequency (%@)",@"Frequency legend when frequencies are shown; Si prefix added"), scale.commonSIprefix];
        [scale release];
    }
}

-(void)setWifi:(BOOL)isWifi {
    wifi = isWifi;
    [self setNeedsDisplay:YES];
}

-(BOOL) wifi { 
    return wifi;
}

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;
    NSRect spectrumRect = graphView.bounds;
        
    if (device == nil || [self.ticks count] == 0)
        return;
    
    const float OS = 2;

    // NSLog(@"drawRect of %@", self.className);

    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    if (FALSE) {
        CGContextSetRGBFillColor (cref, 1,1,.2,1);
        CGContextFillRect (cref, NSRectToCGRect(rect));
    };

    float Sx = (spectrumRect.size.width-SOX);
    float sx = Sx/span;

    /* 2011-10-16 14:46:42.245 iRFExplorer[39566:707] LE: Frame: {{63, 5}, {394, 54}} and bounds {{0, 0}, {394, 54}}
     * 2011-10-16 14:46:42.246 iRFExplorer[39566:707] GR: Frame: {{88, 75}, {355, 180}} and bounds {{0, 0}, {355, 180}}
     */
    float dX = self.graphView.frame.origin.x - self.frame.origin.x;
    
    float ox = SOX/2 + rect.origin.x + dX;
    float oy = rect.size.height+ rect.origin.y - 2;

    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);

    // double scaler = MAX(0.7,MIN(MIN(rect.size.width / 471.0, rect.size.height / 50.0),2.5));
    double scaler = MAX(0.8, MIN(1.2, spectrumRect.size.width/400));
    
    // Line actual range
    CGPoint hl[] = { 
        CGPointMake(ox,oy), 
        CGPointMake(ox+Sx, oy) 
    };    
    CGContextStrokeLineSegments(cref, hl, 2 );
    
    // show actual range
    //
    if (FALSE) {
        float v0 = min;
        float v1 = max;

        float x0 = ox + (v0 - min) * sx;
        float x1 = ox + (v1 - min) * sx;
        
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

        NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSFont fontWithName:@"Helvetica" size:14.0 * scaler], NSFontAttributeName,
                               [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                               nil];
        
        NSSize s = [graphLabel sizeWithAttributes:attr];
        NSPoint p = NSMakePoint(self.bounds.origin.x + (self.bounds.size.width - s.width)/2 , 
                                self.bounds.origin.y + OS+2);
        
        [graphLabel drawAtPoint:p withAttributes:attr];        
    }    
    
    // Line first/last tick.
    //
    if (FALSE) {
        CGPoint hl2[] = { 
            CGPointMake(ox + (((TickMark *)[ticks objectAtIndex:0]).value - min) * sx,oy), 
            CGPointMake(ox + (((TickMark *)[ticks lastObject]).value - min) * sx,oy), 
        };    
        CGContextStrokeLineSegments(cref, hl2, 2 );
    }

    for(int i = 0; i < subTicks.count; i++) {
        double v = [(NSNumber *)[subTicks objectAtIndex:i] doubleValue];
        float x = ox + (device.fStepHz/2 + v - min) * sx;
#if 1
        if (x < ox-OS)
            continue;
        if (x > ox + Sx+OS)
            continue;
#endif    
        int l = 1;
        CGPoint tick[] = { 
            CGPointMake(x,oy), 
            CGPointMake(x, oy-OS * l) 
        };    
        CGContextStrokeLineSegments(cref, tick, 2 );
    }

    for(int i = 0; i < ticks.count; i++) {
        TickMark * m = [ticks objectAtIndex:i];
        float v = m.value;        
        float x = ox + (device.fStepHz/2 + v - min) * sx;
#if 1
        if (x < ox-OS)
            continue;
        if (x > ox + Sx+OS)
            continue;
#endif    
        
        NSTextAlignment a = NSCenterTextAlignment;
        
        if (x <= ox)
            a = NSLeftTextAlignment;

        if (x >= ox + Sx)
            a = NSRightTextAlignment;
        
        int l = 2;
        CGPoint tick[] = { 
            CGPointMake(x,oy), 
            CGPointMake(x,oy-OS * l)
        };    
        CGContextStrokeLineSegments(cref, tick, 2 );
        
        NSSize s = [m.labelStr sizeWithAttributes:nil];
        
        float lx = x;
        float ly = oy - s.height - OS*2;

        switch (a) {
            case NSCenterTextAlignment:
                lx -= s.width/2.0;
                break;
            case NSLeftTextAlignment:
                // ly -= s.height;
                break;
            case NSRightTextAlignment:
                lx -= s.width;
                // ly -= s.height;
                break;
        }
        NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSFont fontWithName:@"Helvetica" size:10.0 * scaler], NSFontAttributeName,
                               [NSColor darkGrayColor], NSForegroundColorAttributeName, 
                               nil];
        
        [m.labelStr drawAtPoint:NSMakePoint(lx,ly) 
                 withAttributes:attr];
        
    }    
}

-(void)dealloc {
    [device release];
    [graphView release];
    [ticks release];
    
    [super dealloc];
}
@end
