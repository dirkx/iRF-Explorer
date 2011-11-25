//
//  SpectrumView.m
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
