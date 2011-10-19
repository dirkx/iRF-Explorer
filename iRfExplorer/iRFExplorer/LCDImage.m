//
//  LCDImage.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 11/10/2011.
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

#import "LCDImage.h"

@implementation LCDImage

/* The lcdByteArray is organized as 8 consecutive 
 * rows of 128 bytes each Organized top to bottom. Every bit within the byte represents 
 * a pixel ON(1) or OFF(0) being the MSB the upper pixel and the LSB the bottom pixel 
 * within the row.	
 */
+(id)imageWithLCD:(const char *)lcd
{
    NSInteger w = 128, h = 64;

    NSBitmapImageRep * imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                          pixelsWide:w
                                                                          pixelsHigh:h 
                                                                       bitsPerSample:1 
                                                                     samplesPerPixel:1 
                                                                            hasAlpha:NO 
                                                                            isPlanar:YES
                                                                      colorSpaceName:NSCalibratedWhiteColorSpace 
                                                                         bytesPerRow:0
                                                                        bitsPerPixel:0];
    
    unsigned char * bitmap = [imageRep bitmapData];
    NSInteger bytesPerRow = [imageRep bytesPerRow];
    
    for(int x = 0; x < w; x++) {
        for(int y = 0; y < h; y++) {
            int pix = lcd[ x + (y >> 3)*w] & 1<<(y & 7);
            if (pix == 0)
                bitmap[ x/8 + y * bytesPerRow ] |= (1 << (7-(x & 7)));
        }
    }
    NSSize imageSize = NSMakeSize(CGImageGetWidth([imageRep CGImage]), 
                                  CGImageGetHeight([imageRep CGImage]));
    
    NSImage * image = [[NSImage alloc] initWithSize:imageSize];
    
    [image addRepresentation:imageRep];    
    [imageRep release];
    
    return [image autorelease];
}

+(id)imageWithReticule
{   
    NSInteger w = 128, h = 64;
    NSBitmapImageRep * imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                          pixelsWide:w
                                                                          pixelsHigh:h 
                                                                       bitsPerSample:1 
                                                                     samplesPerPixel:1 
                                                                            hasAlpha:NO 
                                                                            isPlanar:NO
                                                                      colorSpaceName:NSCalibratedWhiteColorSpace
                                                                         bytesPerRow:0
                                                                        bitsPerPixel:0];

    unsigned char * bitmap = [imageRep bitmapData];
    NSInteger bytesPerRow = [imageRep bytesPerRow];
    
    for(int y = 0; y < h; y++) {
        for(int x = 0; x < w; x++) {
            if (((x+y)>>2) & 1) {
                bitmap[ x/8 + y * bytesPerRow ] |= (1 << (x & 7));
            };
        }
    }
    
    NSSize imageSize = NSMakeSize(CGImageGetWidth([imageRep CGImage]), 
                                  CGImageGetHeight([imageRep CGImage]));
    
    NSImage * image = [[NSImage alloc] initWithSize:imageSize];
    
    [image addRepresentation:imageRep];   
    [imageRep release];
    
    return [image autorelease];
}

@end
