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
