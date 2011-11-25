//
//  SpectrumDrawerView.h
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

#import <Cocoa/Cocoa.h>

#import "RFExplorer.h"
#import "SpectrumGraphView.h"
#import "SomeDrawerView.h"

#import "FrequencyTextFieldSliderView.h"
#import "SignalTextFieldSliderView.h"

@interface SpectrumDrawerView : SomeDrawerView {
    IBOutlet FrequencyTextFieldSliderView * centerFrequencyField;
    IBOutlet FrequencyTextFieldSliderView * freqSpanField;
    IBOutlet SignalTextFieldSliderView * dbmTopField;
    IBOutlet SignalTextFieldSliderView * dbmBotField;
    
    IBOutlet NSButton * showMaxButton;
    IBOutlet NSButton * showAvgxButton;
    IBOutlet NSButton * decayButton;

    IBOutlet SpectrumGraphView *spectrumGraphView;
}

@property (retain) IBOutlet SignalTextFieldSliderView * dbmTopField;
@property (retain) IBOutlet SignalTextFieldSliderView * dbmBotField;
@property (retain) IBOutlet FrequencyTextFieldSliderView * centerFrequencyField;
@property (retain) IBOutlet FrequencyTextFieldSliderView * freqSpanField;

@property (retain) IBOutlet NSButton * showMaxButton;
@property (retain) IBOutlet NSButton * showAvgxButton;
@property (retain) IBOutlet NSButton * decayButton;

@property (retain) IBOutlet SpectrumGraphView *spectrumGraphView;

// For remote control
-(void)setCenterFrequency:(double)newVal;

// Callbacks from UI
//
-(IBAction)setCenterFreqValue:(id)sender;
-(IBAction)setFreqSpanValue:(id)sender;
-(IBAction)setDbmBotValue:(id)sender;
-(IBAction)setDbmTopValue:(id)sender;
-(IBAction)showButtonChange:(id)sender;
@end
