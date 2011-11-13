//
//  SpectrogramView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 05/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpectrogramView.h"
#import "NSViewExtensions.h"

@implementation SpectrogramView
@synthesize timeLegendView, frequencyLegendView, timeStampLegendView, spectrogramGraphView, graphView;

-(RFExplorer *)device { 
    return device; 
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [NSColor whiteColor];
}

-(void)setDevice:(RFExplorer *)_device {
    [super setDevice:_device];
    
    self.frequencyLegendView.device = _device;
    self.timeLegendView.device = _device;
    self.timeStampLegendView.device = _device;
    self.spectrogramGraphView.device = _device;
    
    [self setNeedsDisplay:YES];
}

-(void)newBoard:(id)sender {
   [spectrogramGraphView newBoard:sender];
    [super newBoard:sender];
}

-(void)newConfig:(id)sender {
    [super newConfig:sender];
}

-(void)setNeedsDisplay:(BOOL)flag {
    frequencyLegendView.fullRange = YES;

    [frequencyLegendView setNeedsDisplay:flag];
    [timeStampLegendView setNeedsDisplay:flag];
    [timeLegendView setNeedsDisplay:flag];
    
    [spectrogramGraphView setNeedsDisplay:flag];
    
    [super setNeedsDisplay:flag];
}



@end
