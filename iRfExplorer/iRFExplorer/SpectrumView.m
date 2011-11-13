//
//  SpectrumView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 03/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpectrumView.h"
#import "NSViewExtensions.h"
#import "PreferenceConstants.h"
#import "NSStringExtensions.h"
#import "LIMS.h"

@implementation SpectrumView
@synthesize frequencyLegendView, dbmLegendView,spectrumGraphView;

-(void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [NSColor whiteColor];
}

-(void)setDevice:(RFExplorer *)_device {
    [super setDevice:_device];

    self.frequencyLegendView.device = _device;
    self.dbmLegendView.device = _device;
    self.spectrumGraphView.device = _device;
    
    [self setNeedsDisplay:YES];
}

-(void)setNeedsDisplay:(BOOL)flag {
    [frequencyLegendView setNeedsDisplay:flag];
    [dbmLegendView setNeedsDisplay:flag];    
    [spectrumGraphView setNeedsDisplay:flag];
    
    [super setNeedsDisplay:flag];
}

-(void)newConfig:(id)sender {
    [super newConfig:sender];
    [frequencyLegendView setWifi:(device.nFreqSpectrumSteps == 13)];
    [spectrumGraphView newConfig:sender];
}     

-(void)newBoard:(id)sender {
    [super newBoard:sender];
    [spectrumGraphView newBoard:sender];
}     

-(void)addToPasteboard:(NSPasteboard*)pasteBoard 
{
    [super addToPasteboard:pasteBoard];
    [spectrumGraphView.spectrum addToPasteboard:pasteBoard];
}
@end
