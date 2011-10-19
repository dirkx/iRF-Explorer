//
//  SpectrogramView.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 18/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "SpectrogramView.h"
#import "ColourMap.h"

@implementation SpectrogramView
@synthesize device;

#define HSPACE 16
#define VSPACE 16

-(void)addSpectrum:(Spectrum *)spectrum 
{
    NSInteger w0 = self.bounds.size.width -  3 * HSPACE;
    NSInteger h0 = self.bounds.size.height - 2 * VSPACE;
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

        if (old == nil) {
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
            double f = device.fMinFreqMhz  + x * device.fMaxSpanMhz / w; // actual frequency of 'x'
            NSInteger fdx = n * (f - device.fStartMhz) / device.fSpanMhz; 

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
    
    rect.origin.x +=  2*HSPACE;
    rect.origin.y += 2*VSPACE;
    
    rect.size.width -= 3*HSPACE;
    rect.size.height -= 3*VSPACE;
    
    [imageRep drawInRect:rect];
    CGContextSetLineWidth(cref, 0.2);
    
    CGContextSetRGBStrokeColor(cref, 0.4,0,0,1);
    CGContextStrokeRect(cref,rect);
    

    if (TRUE) {
        CGContextSetLineWidth(cref, 1.0);
        CGContextSetRGBStrokeColor(cref, 0.4,0,0,1);
        CGPoint v[] = { 
            CGPointMake(rect.origin.x - 8, rect.origin.y),
            CGPointMake(rect.origin.x - 8, rect.origin.y + rect.size.height)
        };    
        CGContextStrokeLineSegments(cref, v, 2 );
        CGContextSetLineWidth(cref, 0.5);
        for(int i = 0; i <= 10; i++) {
            double y = rect.origin.y + rect.size.height*i/10.0;
            CGPoint t[] = { 
                CGPointMake(rect.origin.x - 8, y),
                CGPointMake(rect.origin.x -12, y)
            };    
            CGContextStrokeLineSegments(cref,t, 2 );
        }
    };
    if (TRUE) {
        CGContextSetLineWidth(cref, 1.0);
        CGContextSetRGBStrokeColor(cref, 0,0,0,1);
        CGPoint h[] = { 
            CGPointMake(rect.origin.x, rect.origin.y - 4),
            CGPointMake(rect.origin.x + rect.size.width, rect.origin.y - 4)
        };    
        CGContextStrokeLineSegments(cref, h, 2 );
        CGContextSetLineWidth(cref, 0.5);
        for(int i = 0; i <= 20; i++) {
            double x = rect.origin.x + rect.size.width*i/20.0;
            CGPoint t[] = { 
                CGPointMake(x,rect.origin.y-4),
                CGPointMake(x,rect.origin.y-((i % 5) ? 6 : 10))
            };    
            CGContextStrokeLineSegments(cref,t, 2 );
            if (i % 10)
                continue;
            NSString * label = [NSString stringWithFormat:@"%.1f Mhz", device.fMinFreqMhz +  i * device.fMaxSpanMhz / 10];
            NSSize s = [label sizeWithAttributes:nil];
            float x0 = x-s.width/2;
            float x1 = x0 + s.width;
            if (x0 < rect.origin.x)
                x = rect.origin.x + s.width/2;
            if (x1 > rect.origin.x + rect.size.width)
                x = rect.origin.x + rect.size.width - s.width/2;
            [label drawAtPoint:CGPointMake(x-s.width/2,rect.origin.y-12-s.height) withAttributes:nil];
        }
    };
}

-(void)dealloc {
    [imageRep release];
    [super dealloc];
}
@end
