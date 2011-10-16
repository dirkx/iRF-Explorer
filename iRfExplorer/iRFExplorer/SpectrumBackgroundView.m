//
//  SpectrumBackgroundView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 16-10-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpectrumBackgroundView.h"

@implementation SpectrumBackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect rect = self.bounds;

    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef cref = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    CGContextSetRGBFillColor (cref, 1,1,1,1);
    CGContextFillRect (cref, rect);
}
@end
