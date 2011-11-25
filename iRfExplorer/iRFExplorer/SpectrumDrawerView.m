//
//  SpectrumDrawerView.m
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

#import "SpectrumDrawerView.h"

@implementation SpectrumDrawerView

@synthesize spectrumGraphView;

@synthesize centerFrequencyField, freqSpanField, dbmTopField, dbmBotField;
@synthesize showMaxButton, showAvgxButton, decayButton;

-(void)awakeFromNib {
    if (device) {
        [self newBoard:self];
        [self newConfig:self];
    };
    freqSpanField.noFeedbackNeeded = TRUE;
    freqSpanField.logSlider = TRUE;
    [self showButtonChange:nil];
}

-(void)setAllControls:(BOOL)onOff {
    [super setAllControls:onOff];
    
    freqSpanField.enabled = onOff;
    centerFrequencyField.enabled = onOff;
    dbmBotField.enabled = onOff;
    dbmTopField.enabled = onOff;
    [showAvgxButton setEnabled:onOff];
    [showMaxButton setEnabled:onOff];
    [decayButton setEnabled:onOff];    
}

-(void)newConfig:(id)sender {
    [super newConfig:sender];

    if (device == nil) 
        return;
    
    centerFrequencyField.minValue = device.fMinFreqHz + device.fSpanHz/2;
    centerFrequencyField.maxValue = device.fMaxFreqHz - device.fSpanHz/2;
    centerFrequencyField.scalarValue = device.fCenterHz;
    
    freqSpanField.minValue = device.fMinSpanHz;
    freqSpanField.maxValue = device.fMaxSpanHz;
    freqSpanField.scalarValue = device.fSpanHz;
    
    dbmBotField.minValue = device.fAmplitudeMin;
    dbmBotField.maxValue = device.fAmplitudeMax - device.fAmplitudeMinSpan;
    dbmBotField.scalarValue = device.fAmplitudeBottom;
    
    dbmTopField.minValue = device.fAmplitudeMin + device.fAmplitudeMinSpan;
    dbmTopField.maxValue = device.fAmplitudeMax;
    dbmTopField.scalarValue = device.fAmplitudeTop;
}

// Change - e.g due to auto scan.
-(void)setCenterFrequency:(double)newVal {
    // try to show
    centerFrequencyField.scalarValue = newVal;
    [self setCenterFreqValue:self];
}

-(void)newBoard:(id)sender {
}

-(IBAction)showButtonChange:(NSButton *)sender  {
    if (sender == showMaxButton || sender == nil) {
        [spectrumGraphView setAndResetShowMax:(showMaxButton.state == NSOnState)];
    };
    if (sender == showAvgxButton || sender == nil) {
        [spectrumGraphView setAndResetShowAvg:(showAvgxButton.state == NSOnState)];
    };
    if (sender == decayButton || sender == nil) {
        [spectrumGraphView setAndResetDecay:(decayButton.state == NSOnState)];
    };
}

-(IBAction)setCenterFreqValue:(id)sender {
    double span = freqSpanField.scalarValue;
    double center = centerFrequencyField.scalarValue;

    if (center + span/2 > device.fMaxFreqHz) 
        span = (device.fMaxFreqHz - center) * 2;

    if (center - span/2 < device.fMinFreqHz)
        span = (center - device.fMinFreqHz) * 2;
    
    if (span < device.fMinSpanHz) 
        span = device.fMinFreqHz;
            
    if (span > device.fMaxSpanHz)
        span = device.fMaxSpanHz;
    
    if (center + span / 2.f > device.fMaxFreqHz)
        center = device.fMaxFreqHz - span /2.f;
    
    if (center - span /2.f < device.fMinFreqHz)
        center = device.fMinFreqHz + span/2.f;

    if (freqSpanField.scalarValue != span) 
        freqSpanField.scalarValue = span;
    
    if (centerFrequencyField.scalarValue != center)
        centerFrequencyField.scalarValue = center;
    
    // always - or postpone to mouse up/leave/etc ?
    //
    [device setFreqRangeFrom:center-span/2.f to:center+span/2.f];
}

-(IBAction)setFreqSpanValue:(id)sender {
    double span = freqSpanField.scalarValue;
    double center = centerFrequencyField.scalarValue;
    
    double min = center - span/2.f;
    if (min < device.fMinFreqHz) {
        center = device.fMinFreqHz + span / 2.f;
        centerFrequencyField.scalarValue = center;
    }
    
    double max = center + span/2.f;
    if (max > device.fMaxFreqHz) {
        center = device.fMaxFreqHz - span / 2.f;
        centerFrequencyField.scalarValue = center;
    }

    // always - or postpone to mouse up/leave/etc ?
    //
    [device setFreqRangeFrom:center-span/2.f to:center+span/2.f];
}

-(IBAction)setDbmBotValue:(id)sender {
    double v = dbmBotField.scalarValue;
    double w = dbmTopField.scalarValue;
    if (v > w - device.fAmplitudeMinSpan) {
        w = v + device.fAmplitudeMinSpan;
        if (w > device.fAmplitudeMax) {
            w = device.fAmplitudeMax;
            v = w - device.fAmplitudeMinSpan;
            dbmBotField.scalarValue = v;
        };
        dbmTopField.scalarValue = w;
    }
    
    // always - or postpone to mouse up/leave/etc ?
    //
    [device setAmpRangeFrom:v to:w];
}

-(IBAction)setDbmTopValue:(id)sender {
    double v = dbmTopField.scalarValue;
    double w = dbmBotField.scalarValue;

    if (v < w + device.fAmplitudeMinSpan) {
        w = v - device.fAmplitudeMinSpan;
        if (w < device.fAmplitudeMin) {
            w = device.fAmplitudeMin;
            v = w + device.fAmplitudeMinSpan;
            dbmTopField.scalarValue = v;
        }
        dbmBotField.scalarValue = w;
    };

    // always - or postpone to mouse up/leave/etc ?
    [device setAmpRangeFrom:w to:v];
}
@end
