//
//  LegendView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 05/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LegendView.h"

@implementation LegendView
@synthesize graphView;

-(RFExplorer *)device { 
    return device; 
}

-(void)setDevice:(RFExplorer *)_device {
    if (device != _device) {
        [device release];
        device = [_device retain];
    };
    
    [self setNeedsDisplay:YES];
}

@end
