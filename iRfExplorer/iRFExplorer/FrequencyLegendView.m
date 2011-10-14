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

@implementation FrequencyLegendView

@synthesize graphView, device;

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;
    
//  const float kMargin = 8;
    const float OS = 8.0;
    const int kSteps = 10;
    
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    if (0) {
        CGContextSetRGBFillColor (cref, 1,1,1,1);
        CGContextFillRect (cref, rect);
    };
    
    float Sx = 0.90 * rect.size.width;
//  float sx = Sx/device.fFullRangeMhz;
    
    float ox = 0.05 * rect.size.width + rect.origin.x;
    float oy = 0.95 * rect.size.height+ rect.origin.y;

    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);
    
    CGPoint hl[] = { CGPointMake(ox-OS,oy), CGPointMake(ox+Sx+OS, oy) };    
    CGContextStrokeLineSegments(cref, hl, 2 );
    
    for(int i = 0; i <= kSteps; i++) {
        float x = ox + i * Sx / (kSteps);
        CGPoint tick[] = { CGPointMake(x,oy), CGPointMake(x, oy-OS * ((i % 5) ? 1 : 2)) };    
        CGContextStrokeLineSegments(cref, tick, 2 );
    }
    
    NSString * from = [NSString stringWithFormat:@"%03.1f Mhz", 100+device.fStartMhz];
    NSString * midd = [NSString stringWithFormat:@"%03.1f Mhz", 150+device.fStartMhz + device.fSpanMhz/2 ];
    NSString * till = [NSString stringWithFormat:@"%03.1f Mhz", 200+device.fStartMhz + device.fSpanMhz ];
    
    [from drawAtPoint:NSMakePoint(ox - 8.0,           
                                  oy-32.0) withAttributes:nil];
    [midd drawAtPoint:NSMakePoint(ox+Sx/2 - 24.0,        
                                  oy-32.0) withAttributes:nil];
    [till drawAtPoint:NSMakePoint(ox+Sx-42.0,
                                  oy-32.0) withAttributes:nil];

}

@end
