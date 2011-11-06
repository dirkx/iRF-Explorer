//
//  SpectrumDrawerView.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
