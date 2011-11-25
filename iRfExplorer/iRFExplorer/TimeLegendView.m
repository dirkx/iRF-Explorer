//
//  NSView.m
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

#import "TimeLegendView.h"
#import "NSStringExtensions.h"
#import "SpectrogramView.h"

@implementation TimeLegendView

- (void)drawRect:(NSRect)dirtyRect
{    
    SpectrogramGraphView * sg = (SpectrogramGraphView *)graphView;
    if (sg.nAges == 0)
        return;
    
    if (device == nil)
        return;
        
    NSRect rect  = graphView.bounds;
    rect.origin.x += self.graphView.frame.origin.x - self.frame.origin.x;
    rect.origin.y += self.graphView.frame.origin.y - self.frame.origin.y;
    
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    

    const int OS = 4;               // tick sizer
    double ox = rect.origin.x - 4; // Offset from main graph.
    
    CGPoint v[] = { 
        CGPointMake(ox, rect.origin.y),
        CGPointMake(ox, rect.origin.y + rect.size.height)        
    };
    
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);
    CGContextSetLineWidth(cref, 1.0);
    CGContextStrokeLineSegments(cref, v, 2 );

    CGContextSetLineWidth(cref, 0.5);
    for(int i = 0; i <= sg.nAges * 2; i++) {
        double y = rect.origin.y + rect.size.height*i/sg.nAges/2;
        CGPoint t[] = { 
            CGPointMake(ox, y),
            CGPointMake(ox-OS, y)            
        };    
        CGContextStrokeLineSegments(cref,t, 2 );
    }
    
    for(int i = 0; i <= sg.nAges; i++) {
        NSString * label = @"";
        if (i == 0)
            label = @"now";
        else if (i <= [sg.agesInSeconds count]) {
            double secs = [[sg.agesInSeconds objectAtIndex:[sg.agesInSeconds count]-i] doubleValue];
            label = [NSString stringFromAge:secs
                                  keepShort:YES];
        };  
        
        NSSize s = [label sizeWithAttributes:nil];
        
        // Align center for the middle ticks; and top/bottom for
        // the extemes. The small tweaks are to get the baseline
        // about right.
        double y = rect.origin.y + rect.size.height*i/sg.nAges;
        if (i == sg.nAges)
            y -= s.height - 2.0;
        else if (i)
            y -= s.height/2 + 0.5;
        else
            y -= 2.5;
        
        [label drawAtPoint:NSMakePoint(ox - OS - 1 -s.width,y /* moving baseline of font */)         
            withAttributes:nil];
    }
}

-(void)dealloc {
    [super dealloc];
}
@end
