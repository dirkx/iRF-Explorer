//
//  TimeSlotLegendView.m
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
#import "TimeStampLegendView.h"
#import "SpectrogramView.h"

@implementation TimeStampLegendView

-(void)setShowTimeStamp:(BOOL)_showTimeStamp {
    showTimeStamp = _showTimeStamp;
    [self setNeedsDisplay:YES];
}

-(BOOL) showTimeStamp { 
    return showTimeStamp; 
}

-(void)awakeFromNib {
    // not all languages seem to have seconds in a way we can postfix
    // .<fraction> with ease. So we use something iso-ish rather than
    // something inspired on the locale.
    ndf = [[NSDateFormatter alloc] init];
    [ndf setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    self.shadow = [[[NSShadow alloc] init] autorelease];
    [self.shadow setShadowColor:[NSColor whiteColor]];
    [self.shadow setShadowBlurRadius:2];
    [self.shadow setShadowOffset:NSMakeSize(1,-1)];
}

- (void)drawRect:(NSRect)dirtyRect
{    
    SpectrogramGraphView * sg = (SpectrogramGraphView *)graphView;
    if (sg.nAges == 0)
        return;    
    
    if (device == nil)
        return;
    
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    [self.shadow set];

    NSRect rect  = graphView.bounds;
    rect.origin.x += self.graphView.frame.origin.x - self.frame.origin.x;
    rect.origin.y += self.graphView.frame.origin.y - self.frame.origin.y;
    
#if 0
    // debug axis alignments
    CGContextStrokeRect(cref,rect);
    NSLog(@"YY %f/%f/%f", rect.size.height, self.bounds.size.height, graphView.frame.size.height);
#endif
    
    if (sg.floatHeight == 0)
        return;
    
    // Spectograms are hard to read at firt. So we
    // initially show the start time as we scroll 
    // up - and fade it out slowly once we get near 
    // the top.
    //
    if ([sg.agesInSeconds count] < sg.nAges) {
        double ox = rect.origin.x - 4; // Offset from main graph.
        NSDate * ts = sg.floatAge;
        if ([sg.agesInSeconds count])
            ts = [sg.ages objectAtIndex:0];
        double y = rect.origin.y + [sg.agesInSeconds count] * rect.size.height / sg.nAges;
        y += sg.floatHeight;
        double d = (rect.origin.y + rect.size.height) - y;
        if (d > 10) {
            if (d > 100.f) d = 100.f;
            d = (100.f-d) / 100.f;
            NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSFont fontWithName:kMainFont size:kMainMediumFontSize /* was 16.0 */], 
                                   NSFontAttributeName,
                                   [NSColor colorWithDeviceWhite:d 
                                                           alpha:0.5],
                                   NSForegroundColorAttributeName, 
                                   nil];
            
            NSString * msg = NSLocalizedString(@"Spectogram started at %@", 
                                               @"Timestamp string at top spectogram - followed by time");
            NSString * label = [NSString stringWithFormat:msg, ts];
            NSSize s = [label sizeWithAttributes:attr];
            [label drawAtPoint:NSMakePoint(ox + (rect.size.width-s.width)/2,y+2)  
                withAttributes:attr];
        }
    };

    if (!showTimeStamp)
        return;
    
    double ox = rect.origin.x;    
    for(NSUInteger i = 0; i < [sg.ages count]; i++) 
    {
        double y = rect.origin.y + sg.floatHeight + 
        i * 1.0 * rect.size.height / sg.nAges;
        double d = (rect.origin.y + rect.size.height) - y;
        if (d > 10) {
            if (d > 30.f) d = 30.f;
            d = (30.f-d) / 30.f;
            NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSFont fontWithName:kMainFont size:kMainSmallFontSize], 
                                   NSFontAttributeName,
                                   [NSColor colorWithDeviceWhite:d 
                                                           alpha:0.5],
                                   NSForegroundColorAttributeName, 
                                   nil];
            NSDate * ts;
            if (i == 0)
                ts = sg.floatAge;
            else
                ts  = [sg.ages objectAtIndex:[sg.ages count] - i];
            
            double tt = [ts timeIntervalSinceReferenceDate];
            NSUInteger decs = 100.0 * (tt - floor(tt));
            
            NSString * tstr = [ndf stringFromDate:ts];
            NSString * label = [NSString stringWithFormat:@"%@.%02lu", tstr, decs];
            
            NSSize s = [label sizeWithAttributes:attr];
            [label drawAtPoint:NSMakePoint(ox + (rect.size.width-s.width)/2,
                                           y-s.height/2)  
                withAttributes:attr];
            const int dashLen = 16;
            CGPoint t[] = { 
                CGPointMake(ox + rect.size.width/2 - s.width/2 -  4, y),
                CGPointMake(ox + rect.size.width/2 - s.width/2 - dashLen, y),
                CGPointMake(ox + rect.size.width/2 + s.width/2 +  4, y),
                CGPointMake(ox + rect.size.width/2 + s.width/2 + dashLen, y),
            };    
            
            CGContextSetRGBStrokeColor(cref, 0,0,0,1);
            CGContextSetLineWidth(cref, 1.3);
            CGContextStrokeLineSegments(cref,t, 4 );
        }
    }
}

-(void)dealloc {
    [ndf release];
    [super dealloc];
}
@end
