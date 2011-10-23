//
//  SpectrogramView.m
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
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "NSStringExtensions.h"
#import "SpectrogramView.h"
#import "ColourMap.h"

@implementation SpectrogramView
@synthesize device, ages, floatAge, agesInSeconds, values, lastLineScrollDate;

#define _RSPACE (16)
#define _LSPACE (3*_RSPACE)
#define _TSPACE (16)
#define _BSPACE (3*_TSPACE)
#define _HSPACE (_RSPACE + _LSPACE)
#define _VSPACE (_BSPACE + _TSPACE)

-(void)awakeFromNib {
    nAges = 6;
    self.ages = [NSMutableArray arrayWithCapacity:nAges];
    floatHeight = 0;
#if 1
    // not all languages seem to have seconds in a way we can postfix
    // .<fraction> with ease. So we use something iso-ish rather than
    // something inspired on the locale.
    ndf = [[NSDateFormatter alloc] init];
    [ndf setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
#else
    ndf = [[NSDateFormatter alloc] init];
    [ndf setDateStyle:NSDateFormatterShortStyle];
    [ndf setTimeStyle:NSDateFormatterShortStyle];
#endif
}

-(void)setShowTimeStamp:(BOOL)_showTimeStamp {
    showTimeStamp = _showTimeStamp;
    [self setNeedsDisplay:YES];
}

-(BOOL) showTimeStamp { 
    return showTimeStamp; 
}

-(void)setSecondsPerLine:(double)_secondsPerLine {
    secondsPerLine = _secondsPerLine;
    [self setNeedsDisplay:YES];
}

-(double)secondsPerLine {
    return secondsPerLine;
}

-(void)addSpectrum:(Spectrum *)spectrum 
{
    NSInteger w0 = self.bounds.size.width -  _HSPACE;
    NSInteger h0 = self.bounds.size.height - _VSPACE;
    NSInteger w = [imageRep pixelsWide];
    NSInteger h = [imageRep pixelsHigh];
    
    // This '*/+2' is a work around for a weird issue in drawInRect; with exact matching
    // sizes the image occasionally shows black. Doing a small bit of scaling
    // seems to avoid this. No idea why !! XX fixme XXX. Issue easily reproduced
    // by making rect drawn equal to imageRep size and resizing window. 
    //
    w0 *= 2;
    
    if (imageRep == nil || w0 != w || h0 != h) {
        NSBitmapImageRep * old = imageRep;
        
        // The Alpha channel is a waste - but it lets us scale. See
        // http://developer.apple.com/library/mac/#qa/qa1037/_index.html
        //
        imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                           pixelsWide:w0
                                                           pixelsHigh:h0 
                                                        bitsPerSample:8 
                                                      samplesPerPixel:4  
                                                             hasAlpha:YES
                                                             isPlanar:NO
                                                       colorSpaceName:NSCalibratedRGBColorSpace
                                                          bytesPerRow:0
                                                         bitsPerPixel:0];
        [imageRep setOpaque:YES];

        if (old == nil) {
            unsigned char * bitmap = [imageRep bitmapData];
            NSInteger bytesPerRow = [imageRep bytesPerRow];
            lastLineScrollDate = nil;
            for(NSInteger y = 0; y < h0; y++) {
//               NSInteger src = y * bytesPerRow;
//               memset(&(bitmap[src]), 255, w0*4);
                
                for(NSInteger x = 0; x < w0; x++) {
                    NSInteger i = 4 * x + y * bytesPerRow;
                    
                    bitmap[i + 0] = 255;
                    bitmap[i + 1] = 255; 
                    bitmap[i + 2] = 255;
                    bitmap[i + 3] = 0;
                }
            };
        } else {
            [NSGraphicsContext saveGraphicsState];
            NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
            [NSGraphicsContext setCurrentContext:context];
            [old drawInRect:NSMakeRect( 0, 0, w0, h0)];
            [NSGraphicsContext restoreGraphicsState];
            [old release];
#if 0            
            // Fade the 'old stuff' a bit - as to make it clear that the
            // data there is not overly reliable.
            //
            NSInteger bytesPerRow = [imageRep bytesPerRow];
            unsigned char * bitmap = [imageRep bitmapData];
            for(NSInteger y = 0; y < h0; y++) {
                for(NSInteger x = 0; x < w0; x++) {
                    NSInteger i = 4 * x + y * bytesPerRow;
                    if (x + y & 1) {
                        bitmap[i+0] = 255;
                        bitmap[i+1] = 255;
                        bitmap[i+2] = 255;
                    };
                    bitmap[i+3] = 200;
                };
            };
#endif
        }
        h = h0;
        w = w0;
    };
    
    unsigned char * bitmap = [imageRep bitmapData];
    NSInteger bytesPerRow = [imageRep bytesPerRow];
        
    if (lastLineScrollDate == nil || -[lastLineScrollDate timeIntervalSinceNow] > secondsPerLine) 
    {
        self.lastLineScrollDate = [NSDate date];

        self.values = [NSMutableArray arrayWithCapacity:w0];
        for(NSUInteger i = 0; i < w0; i++)
            [values addObject:[AveragingNumber averagingNumber]];
        
        for(NSInteger y = 1, dst = 0; y < h; y++) {
            NSInteger src = y * bytesPerRow;
            memcpy(&(bitmap[dst]), &(bitmap[src]), bytesPerRow);
            dst = src;
        };
        
        if (floatHeight >= 1.0 * h / nAges || floatHeight == 0) {
            if (floatAge)
                [ages addObject:floatAge];
            if ([ages count] > nAges)
                [ages removeObjectAtIndex:0];
            
            self.agesInSeconds = [NSMutableArray arrayWithCapacity:[ages count]];
            for(NSDate * d in ages) {
                [agesInSeconds addObject:[NSNumber numberWithDouble:[d timeIntervalSinceNow]]];
            };
            self.floatAge = [NSDate date];
            floatHeight = 1;
        } else {
            floatHeight++;
        }
    }
    
    NSInteger y = h - 1;
    for(NSInteger x = 0; x < w; x++) 
    {        
        if (spectrum != nil) { 
            NSUInteger n = [spectrum count];
            double f = device.fMinFreqMhz  + x * device.fFullRangeMhz / w; // actual frequency of 'x'
            NSInteger fdx = 1.0 * n * (f - device.fStartMhz) / device.fSpanMhz; 

            if (fdx >= 0 && fdx < n) {
                unsigned char v = (130 - [[spectrum.dbValues objectAtIndex:fdx] floatValue]) * 2;
                unsigned char r, g, b;

                AveragingNumber * a = [values objectAtIndex:fdx];

                v = round([a add:v]);
                r = [ColourMap red:v];
                g = [ColourMap green:v];
                b = [ColourMap blue:v];
                
                NSInteger i = 4 * x + y * bytesPerRow;
                
                bitmap[i + 0] = r;
                bitmap[i + 1] = g; 
                bitmap[i + 2] = b;
                bitmap[i + 3] = 0;
            }
        };
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{    
   NSRect rect = self.bounds;
     
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    // Background
    if (TRUE) {
        CGContextSetRGBFillColor (cref, 1,1,1,1);
        CGContextFillRect (cref, rect);
    };
    if (!imageRep)
        return;
    
    rect.origin.x +=  _LSPACE;
    rect.origin.y += _BSPACE;

    rect.size.height -= _VSPACE+2;  
    rect.size.width -= _HSPACE;
    [imageRep drawInRect:rect];

    CGContextSetLineWidth(cref, 0.2);
    
    CGContextSetRGBStrokeColor(cref, 0,0,0,1);
    CGContextStrokeRect(cref,rect);
    

    if (TRUE) {
        CGContextSetLineWidth(cref, 1.0);
        CGContextSetRGBStrokeColor(cref, 0,0,0,1);
         double ox = rect.origin.x - 4;
        CGPoint v[] = { 
            CGPointMake(ox, rect.origin.y),
            CGPointMake(ox, rect.origin.y + rect.size.height)        
        };    
        CGContextStrokeLineSegments(cref, v, 2 );
        CGContextSetLineWidth(cref, 0.5);
        for(int i = 0; i <= nAges * 2; i++) {
            double y = rect.origin.y + rect.size.height*i/nAges/2;
            CGPoint t[] = { 
                CGPointMake(ox, y),
                CGPointMake(ox-4, y)            
            };    
            CGContextStrokeLineSegments(cref,t, 2 );
        }
        for(int i = 0; i <= nAges; i++) {
            NSString * label = @"";
            if (i == 0)
                label = @"now";
            else if (i <= [agesInSeconds count]) {
                double secs = [[agesInSeconds objectAtIndex:[agesInSeconds count]-i] doubleValue];
                label = [NSString stringFromAge:secs
                                     keepShort:YES];
            };  
            
            NSSize s = [label sizeWithAttributes:nil];
            
            double y = rect.origin.y + rect.size.height*i/nAges;
            
            [label drawAtPoint:CGPointMake(ox - 5 -s.width,y-s.height/2)  
                withAttributes:nil];
        }
        // Spectograms are hard to read at firt. So we
        // initially show the start time as we scroll 
        // up - and fade it out slowly once we get near 
        // the top.
        if ([agesInSeconds count] < nAges) {
            NSDate * ts = floatAge;
            if ([agesInSeconds count])
                ts = [ages objectAtIndex:0];
            double y = rect.origin.y + floatHeight + [agesInSeconds count] * 1.0 * rect.size.height / nAges;
            double d = (rect.origin.y + rect.size.height) - y;
            if (d > 10) {
                if (d > 100.f) d = 100.f;
                d = (100.f-d) / 100.f;
                NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSFont fontWithName:@"Helvetica" size:16.0], 
                                       NSFontAttributeName,
                                       [NSColor colorWithDeviceWhite:d 
                                                               alpha:0.5],
                                       NSForegroundColorAttributeName, 
                                       nil];
                
                NSString * label = [NSString stringWithFormat:@"Spectogram started at %@", ts];
                NSSize s = [label sizeWithAttributes:attr];
                [label drawAtPoint:CGPointMake(ox + (rect.size.width-s.width)/2,y+2)  
                    withAttributes:attr];
            }
        };
        if (showTimeStamp) {
            for(NSUInteger i = 0; i < [ages count]; i++) 
            {
                double y = rect.origin.y + floatHeight + i * 1.0 * rect.size.height / nAges;
                double d = (rect.origin.y + rect.size.height) - y;
                if (d > 10) {
                    if (d > 30.f) d = 30.f;
                    d = (30.f-d) / 30.f;
                    NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSFont fontWithName:@"Helvetica" size:12.0], 
                                           NSFontAttributeName,
                                           [NSColor colorWithDeviceWhite:d 
                                                                   alpha:0.5],
                                           NSForegroundColorAttributeName, 
                                           nil];
                    NSDate * ts;
                    if (i == 0)
                        ts = floatAge;
                    else
                        ts  = [ages objectAtIndex:[ages count] - i];
                    
                    double tt = [ts timeIntervalSinceReferenceDate];
                    NSUInteger decs = 100.0 * (tt - floor(tt));
                    
                    NSString * tstr = [ndf stringFromDate:ts];
                    NSString * label = [NSString stringWithFormat:@"%@.%02lu", tstr, decs];
                    
                    NSSize s = [label sizeWithAttributes:attr];
                    [label drawAtPoint:CGPointMake(ox + (rect.size.width-s.width)/2,
                                                   y-s.height/2)  
                        withAttributes:attr];
                    CGPoint t[] = { 
                        CGPointMake(ox + rect.size.width/2 - s.width/2 -  4, y),
                        CGPointMake(ox + rect.size.width/2 - s.width/2 - _LSPACE, y),
                        CGPointMake(ox + rect.size.width/2 + s.width/2 +  4, y),
                        CGPointMake(ox + rect.size.width/2 + s.width/2 + _LSPACE, y),
                    };    
                    CGContextSetLineWidth(cref, 1.3);
                    CGContextStrokeLineSegments(cref,t, 4 );
                }
            }
        }
    };
    if (TRUE) {
        float oy = rect.origin.y - 6;
        CGContextSetLineWidth(cref, 1);
        CGContextSetRGBStrokeColor(cref, 0,0,0,1);
        CGPoint h[] = { 
            CGPointMake(rect.origin.x, oy),
            CGPointMake(rect.origin.x + rect.size.width, oy),
            CGPointMake(rect.origin.x + rect.size.width * (device.fStartMhz - device.fMinFreqMhz) / device.fMaxSpanMhz,oy+4),
            CGPointMake(rect.origin.x + rect.size.width * (device.fEndMhz - device.fMinFreqMhz) / device.fMaxSpanMhz, oy+4),
        };    
        CGContextStrokeLineSegments(cref, h, 4 );

        const NSUInteger hTicks = 20;
        for(int i = 0; i <= hTicks; i++) {
            double x = rect.origin.x + rect.size.width*i/hTicks;
            CGPoint t[] = { 
                CGPointMake(x,oy),
                CGPointMake(x,oy-((i % 5) ? 2 : 4))
            };    
            CGContextStrokeLineSegments(cref,t, 2 );
            if (i % (hTicks/2))
                continue;
            NSString * label = [NSString stringFromMhz: 
                                device.fMinFreqMhz +  i * device.fFullRangeMhz / hTicks];
            NSSize s = [label sizeWithAttributes:nil];
            float x0 = x-s.width/2;
            float x1 = x0 + s.width;
            if (x0 < rect.origin.x)
                x = rect.origin.x + s.width/2;
            if (x1 > rect.origin.x + rect.size.width)
                x = rect.origin.x + rect.size.width - s.width/2;
            [label drawAtPoint:CGPointMake(x-s.width/2,oy-8-s.height) 
                withAttributes:nil];
        }
    };
}

-(void)dealloc {
    [ages release];
    [floatAge release];
    [imageRep release];
    [agesInSeconds release];
    [ndf release];
    [super dealloc];
}
@end
