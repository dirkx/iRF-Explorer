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

#import "SpectrogramView.h"
#import "ColourMap.h"
#import "NSStringExtensions.h"


@implementation SpectrogramView
@synthesize device, ages, floatAge, agesInSeconds;

#define _RSPACE (16)
#define _LSPACE (3*_RSPACE)
#define _TSPACE (16)
#define _BSPACE (3*_TSPACE)
#define _HSPACE (_RSPACE + _LSPACE)
#define _VSPACE (_BSPACE + _TSPACE)
                 
-(void)addSpectrum:(Spectrum *)spectrum 
{
    NSInteger w0 = self.bounds.size.width -  _HSPACE;
    NSInteger h0 = self.bounds.size.height - _VSPACE;
    NSInteger w = [imageRep pixelsWide];
    NSInteger h = [imageRep pixelsHigh];
    
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
            // todo - move to a censible init place.
            nAges = 6;
            self.ages = [NSMutableArray arrayWithCapacity:nAges];
            floatHeight = 0;
            
            unsigned char * bitmap = [imageRep bitmapData];
            NSInteger bytesPerRow = [imageRep bytesPerRow];
            
            for(NSInteger y = 0; y < h0; y++) {
                NSInteger src = y * bytesPerRow;
                memset(&(bitmap[src]), 255, w0*4);
            };        
        } else {
            [NSGraphicsContext saveGraphicsState];
            NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
            [NSGraphicsContext setCurrentContext:context];
            [old drawInRect:NSMakeRect( 0, 0, w0, h0)];
            [NSGraphicsContext restoreGraphicsState];
            [old release];
        }
        h = h0;
        w = w0;
    };
    
    unsigned char * bitmap = [imageRep bitmapData];
    NSInteger bytesPerRow = [imageRep bytesPerRow];
    
    for(NSInteger y = 1, dst = 0; y < h; y++) {
        NSInteger src = y * bytesPerRow;
        memcpy(&(bitmap[dst]), &(bitmap[src]), bytesPerRow);
        dst = src;
    };
 
    NSInteger y = h - 1;
    for(NSInteger x = 0; x < w; x++) 
    {
        unsigned char r, g, b;
        r = g = b = 220;
        
        if (spectrum != nil) { 
            NSUInteger n = [spectrum count];
            double f = device.fMinFreqMhz  + x * device.fFullRangeMhz / w; // actual frequency of 'x'
            NSInteger fdx = 1.0 * n * (f - device.fStartMhz) / device.fSpanMhz; 

            if (fdx >= 0 && fdx < n) {
                unsigned char v = (130 - [[spectrum.dbValues objectAtIndex:fdx] floatValue]) * 2;
                r = [ColourMap red:v];
                g = [ColourMap green:v];
                b = [ColourMap blue:v];
            } else {
                r = g = b = 255;
            }
        };
        NSInteger i = 4 * x + y * bytesPerRow;

        bitmap[i + 0] = r;
        bitmap[i + 1] = g; 
        bitmap[i + 2] = b;
        bitmap[i + 3] = 0;
    }
     
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

    // +2 is a work around for a weird issue in drawInRect; with exact matching
    // sizes the image occasionally shows black. Doing a small bit of scaling
    // seems to avoid this. No idea why !! XX fixme XXX
    //
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
                double a = [[agesInSeconds objectAtIndex:[agesInSeconds count]-i] doubleValue];
                label = [NSString stringWithFormat:@"%.1f", a];
            };  
            
            NSSize s = [label sizeWithAttributes:nil];
            
            double y = rect.origin.y + rect.size.height*i/nAges;
            
            [label drawAtPoint:CGPointMake(ox - 5 -s.width,y-s.height/2)  
                withAttributes:nil];
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
            NSString * label = [NSString stringWithFormat:@"%.1f Mhz", 
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
    [super dealloc];
}
@end
