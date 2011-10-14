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

@implementation dBmLegendView

-(RFExplorer *)device { 
    return device;
}

-(void)setDevice:(RFExplorer *)_device {
    [device release];
    device = [_device retain];
    
    [self setNeedsDisplay:TRUE];
}

-(void)drawRect:(NSRect)dirtyRect {    
    NSRect rect = self.bounds;
    
    const float kMargin = 4;
    const float OS = 16.0;
    const int kSteps = 5;
    
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    if (0) {
        CGContextSetRGBFillColor (cref, 1,1,1,1);
        CGContextFillRect (cref, rect);
    };
    
    // 30.0 is a magic delta - prolly the height of the scrollbar.
    // and 1.0 is the offset.
    float height = rect.size.height - 30.0;
    float sy = 0.90 * height;
    float oy = 0.05 * height + rect.origin.y - 1.0;
    float ox = rect.size.width + rect.origin.y - kMargin;
    
    CGContextSetLineWidth(cref, 1.0);
    CGContextSetRGBStrokeColor(cref, 0,0,0.4,1);

    CGPoint l[] = { 
        CGPointMake(ox,oy), 
        CGPointMake(ox,oy+sy) 
    };    
    CGContextStrokeLineSegments(cref, l, 2 );

    for(int i = 0; i <= kSteps; i++) {
        float y = oy + sy * i / kSteps;
        CGPoint l[] = { 
#if 1
            // for calibration/testing scale -- lets it touch the main graph.
            CGPointMake(ox+((i ==0 || i == kSteps) ? kMargin : 0.0),y), 
#else
            CGPointMake(ox,y),
#endif
            CGPointMake(ox-OS,y) 
        };    
        CGContextStrokeLineSegments(cref, l, 2 );
    };
    
    if (device.fAmplitudeBottom < 0.0) {
        NSString * topLabel = [NSString stringWithFormat:@"%03.1f\n dBm", device.fAmplitudeBottom];
        [topLabel drawAtPoint:NSMakePoint(kMargin,oy+2.0) 
               withAttributes:nil];
    };
    
    if (device.fAmplitudeTop < 0.0) {
        NSString * botLabel = [NSString stringWithFormat:@"%03.1f\n dBm", device.fAmplitudeTop];
        [botLabel drawAtPoint:NSMakePoint(kMargin,oy+sy-32.0) 
               withAttributes:nil];
    }
}
@end
