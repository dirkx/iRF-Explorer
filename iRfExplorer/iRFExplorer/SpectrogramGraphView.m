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
#import "NSViewExtensions.h"

#import "SpectrogramGraphView.h"
#import "SpectrogramView.h"
#import "ColourMap.h"

@implementation SpectrogramGraphView
@synthesize ages, floatAge, agesInSeconds, values, lastLineScrollDate, imageView;
@synthesize nAges, floatHeight;

-(void)awakeFromNib {
    nAges = 6;
    self.ages = [NSMutableArray arrayWithCapacity:nAges];
    floatHeight = 0;
}

-(void)newConfig:(id)sender {
    [super newConfig:sender];
}

-(void)newBoard:(id)sender {
    [super newBoard:sender];

    return;
    
    // leave - somethign odd ith the image cahcing -- it comes abnck somenopw
    [imageRep release];
    imageRep = nil;
    imageView.image = nil;
    
    self.lastLineScrollDate = nil;
    self.values = nil; 
    self.floatAge = nil; 
    self.agesInSeconds = nil; 
    self.ages = nil;
    self.floatAge = nil;
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
    NSInteger w0 = self.bounds.size.width;
    NSInteger h0 = self.bounds.size.height;
    NSInteger w = [imageRep pixelsWide];
    NSInteger h = [imageRep pixelsHigh];
    int br, bg, bb; br = bg = bb = 255; //-210;

    // This '*/+2' is a work around for a weird issue in drawInRect; with exact matching
    // sizes the image occasionally shows black. Doing a small bit of scaling
    // seems to avoid this. No idea why !! XX fixme XXX. Issue easily reproduced
    // by making rect drawn equal to imageRep size and resizing window. Despite
    // below attempts with stuff like NSImageCacheNever.
    // w0 *= 2;
    
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
                                                       colorSpaceName:NSDeviceRGBColorSpace
                                                          bytesPerRow:0
                                                         bitsPerPixel:0];
        [imageRep setOpaque:NO];

#if 0
        imageView.image = [[[NSImage alloc] initWithSize:NSMakeSize(w,h)] autorelease];
        [imageView.image addRepresentation:imageRep];    
        [imageView.image setBackgroundColor:[NSColor clearColor]];
        [imageView.image setCacheMode:NSImageCacheAlways];
#endif
        if (old == nil) {
            unsigned char * bitmap = [imageRep bitmapData];
            NSInteger bytesPerRow = [imageRep bytesPerRow];
            lastLineScrollDate = nil;
            for(NSInteger y = 0; y < h0; y++) {
                for(NSInteger x = 0; x < w0; x++) {
                    NSInteger i = 4 * x + y * bytesPerRow;
                    
                    bitmap[i + 0] = br;
                    bitmap[i + 1] = bg; 
                    bitmap[i + 2] = bb;
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
        
        // memset(&bitmap, 255, bytesPerRow);
        for(NSInteger x = 0; x < w; x++) {                
            NSInteger i = 4 * x + (h-1) * bytesPerRow;
            bitmap[i + 0] = br;
            bitmap[i + 1] = bg; 
            bitmap[i + 2] = bb;
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

            [((SpectrogramView*)(self.superview)).timeLegendView setNeedsDisplay:YES];
            [((SpectrogramView*)(self.superview)).timeStampLegendView setNeedsDisplay:YES];
        } else {
            floatHeight++;
        }
    }
    
    NSInteger y = h - 1;
    for(NSInteger x = 0; x < w; x++) 
    {        
        if (spectrum != nil) { 
            NSUInteger n = [spectrum count];
            double f = device.fMinFreqHz  + x * device.fFullRangeHz / w; // actual frequency of 'x'
            NSInteger fdx = 1.0 * n * (f - device.fStartHz) / device.fSpanHz; 

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
                bitmap[i + 3] = 255;
            }
        };
    }
    
#if 0   
    imageView.image = nil;
    imageView.image = [[[NSImage alloc] initWithSize:NSMakeSize(w,h)] autorelease];
    [imageView.image addRepresentation:imageRep];    
    // [imageView.image setBackgroundColor:[NSColor clearColor]];
#endif
#if 0
    imageView.image = [[NSImage alloc] initWithData:[imageRep TIFFRepresentation]];
    [imageView.image setCacheMode:NSImageCacheNever];
#endif
    
#if 1
    imageView.image = [[[NSImage alloc] initWithSize:NSMakeSize(w,h)] autorelease];
    [imageView.image lockFocus];
    [[NSColor clearColor] set]; 
    [imageRep drawInRect:imageView.bounds];
    [imageView.image unlockFocus];            
#endif
    
    [imageView setNeedsDisplay:YES];
}

-(void)dealloc {
    [ages release];
    [floatAge release];
    [imageRep release];
    [agesInSeconds release];
    [values release];
    
    [super dealloc];
}

#if 0
-(void)drawRect:(NSRect)dirtyRect {
    // NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    // CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    NSRect rect = self.bounds;
    
    if (device == nil)
        return;
    
    [imageRep drawInRect:rect 
                fromRect:NSZeroRect 
               operation:NSCompositeSourceOver // NSCompositeSourceAtop
                fraction:1.0
          respectFlipped:NO 
                   hints:nil];
    
}
#endif
@end
