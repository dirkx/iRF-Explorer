//
//  iRFExplorerAppDelegate.h
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

#import "PreferenceController.h"
#import "SerialDeviceTracker.h"
#import "RFExporerCmds.h"
#import "SpectrumGraphView.h"
#import "FrequencyLegendView.h"
#import "dBmLegendView.h"
#import "RFExplorer.h"
#import "SpectrumBackgroundView.h"
#import "SpectrogramView.h"

typedef enum {
    SCAN_SLOW, SCAN_FAST, SCAN_LINGER
} scan_strategy_t;

@interface iRFExplorerAppDelegate : NSObject <NSApplicationDelegate, 
                                       NSTabViewDelegate,
                                       SerialSettingsDelegate, 
                                       SerialDeviceTrackerDelegate,
                                       RFGUICallbacks> 
{
    PreferenceController *preferenceController;
    RFExplorer * rfExplorer;

    SerialDeviceTracker *serialDeviceTracker;

    NSString *settingDeviceTitle;
    BOOL settingDeviceIsSlow;
    
    IBOutlet NSTabView *mainView;
    IBOutlet NSDrawer *drawerView;
    IBOutlet NSWindow *window;

    // tab 1 -- main graph display
    IBOutlet NSScrollView *spectrumScollView;
    IBOutlet SpectrumGraphView *spectrumView;
    IBOutlet FrequencyLegendView *frequencyLegendView;
    IBOutlet dBmLegendView * dbmLegendView;
    IBOutlet SpectrumBackgroundView * spectrumBackgroundView;
    
    // tab 2 -- plays live screen captures
    IBOutlet NSImageView *liveImageCell;
    IBOutlet NSButton *liveButton;
    IBOutlet NSTextField *pausedLabel;
    BOOL playing;
    
    // Just the spectrogram
    IBOutlet SpectrogramView * spectrogramView;
    BOOL scanDir;
    NSTimer * scanTimer;
    scan_strategy_t scanStrategy;
    double lingerTimeInSeconds, linesPerSecond;
    
    // tab 4 -- lots of info
    IBOutlet NSTextField *infoBandCenterFreq;
    IBOutlet NSTextField *infoBandMinFreq;
    IBOutlet NSTextField *infoBandMaxFreq;
    IBOutlet NSTextField *infoBandSpanFreq;
    IBOutlet NSTextField *infoBoardTitle;
    IBOutlet NSTextField *infoBoardMinFreq;
    IBOutlet NSTextField *infoBoardMaxFreq;
    IBOutlet NSTextField *infoAttenTop;
    IBOutlet NSTextField *infoAttenBott;
    IBOutlet NSTextField *infoDevFirmware;
    IBOutlet NSTextField *infoDevMain;
    IBOutlet NSTextField *infoDevExpansion;
    IBOutlet NSTextField *infoDevBaudrate;
    
    // bottom bar - just some status info
    IBOutlet NSTextField *firmwareLabel;
    IBOutlet NSTextField *boardLabel;
    IBOutlet NSTextField *expansionLabel;
    IBOutlet NSTextField *deviceLabel;

    // Possible content for the drawer
    IBOutlet NSView * spectogramDrawerView;    
    IBOutlet NSView * spectrumDrawerView;

    // Drawer for the Spectrum
    IBOutlet NSTextField * centerFreqTextField;
    IBOutlet NSSlider * centerFreqSlider;
    IBOutlet NSTextField * freqSpanTextField;
    IBOutlet NSSlider * freqSpanSlider;
    IBOutlet NSTextField * dbmTopTextField;
    IBOutlet NSSlider * dbmTopSlider;
    IBOutlet NSTextField * dbmBotTextField;
    IBOutlet NSSlider * dbmBotSlider;
    IBOutlet NSButton * showMaxButton;
    IBOutlet NSButton * showAvgxButton;
    IBOutlet NSButton * decayButton;
    

    // Drawer spectogram
    IBOutlet NSTextField * scanSpeedTextField;
    IBOutlet NSSlider * scanSpeedSlider;
    IBOutlet NSButton * showTimestampButton;
    IBOutlet NSButton * scanRangeButton;

}

@property (retain) IBOutlet NSImageView *liveImageCell;
@property (retain) IBOutlet NSButton *liveButton;
@property (retain) IBOutlet NSTextField *pausedLabel;

@property (retain) IBOutlet NSScrollView *spectrumScollView;
@property (retain) IBOutlet NSView *spectrumView;
@property (retain) IBOutlet FrequencyLegendView * frequencyLegendView;
@property (retain) IBOutlet dBmLegendView * dbmLegendView;
@property (retain) IBOutlet SpectrumBackgroundView * spectrumBackgroundView;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSDrawer *drawerView;

@property (assign) IBOutlet NSTabView *mainView;

@property (retain) IBOutlet NSTextField *firmwareLabel;
@property (retain) IBOutlet NSTextField *boardLabel;
@property (retain) IBOutlet NSTextField *expansionLabel;
@property (retain) IBOutlet NSTextField *deviceLabel;

@property (retain) NSString *settingDeviceTitle;
@property (assign) BOOL settingDeviceIsSlow;

@property (retain) SerialDeviceTracker *serialDeviceTracker;

// tab 3 - spectrogram
@property (retain) IBOutlet SpectrogramView * spectrogramView;
@property (retain) NSTimer * scanTimer;

// tab 4 -- info stuff
@property (retain) IBOutlet NSTextField *infoBandCenterFreq, *infoBandMinFreq, *infoBandMaxFreq, *infoBandSpanFreq, *infoBoardTitle, *infoBoardMinFreq, *infoBoardMaxFreq, *infoAttenTop,*infoAttenBott,*infoDevFirmware, *infoDevMain, *infoDevExpansion, *infoDevBaudrate;

@property (retain) IBOutlet NSView * spectogramDrawerView;    
@property (retain) IBOutlet NSView * spectrumDrawerView;

// Drawer for spectrum
@property (retain) IBOutlet NSTextField * centerFreqTextField;
@property (retain) IBOutlet NSSlider * centerFreqSlider;    
@property (retain) IBOutlet NSTextField * freqSpanTextField;
@property (retain) IBOutlet NSSlider * freqSpanSlider;
@property (retain) IBOutlet NSTextField * dbmTopTextField;
@property (retain) IBOutlet NSSlider * dbmTopSlider;
@property (retain) IBOutlet NSTextField * dbmBotTextField;
@property (retain) IBOutlet NSSlider * dbmBotSlider;
@property (retain) IBOutlet NSButton * showMaxButton;
@property (retain) IBOutlet NSButton * showAvgxButton;
@property (retain) IBOutlet NSButton * decayButton;

// Drawer for spectogram
@property (retain) IBOutlet NSTextField * scanSpeedTextField;
@property (retain) IBOutlet NSSlider * scanSpeedSlider;
@property (retain) IBOutlet NSButton * showTimestampButton;
@property (retain) IBOutlet NSButton * scanRangeButton;

// Info Tab

-(IBAction)showPreferences:(id)sender; 
-(IBAction)toggleLiveScreenUpdate:(id)sender;
-(IBAction)configScreenUpdating:(id)sender;

// Callbacks -- Drawer spectrum
-(IBAction)setCenterFreqValue:(id)sender;
-(IBAction)setFreqSpanValue:(id)sender;
-(IBAction)setDbmBotValue:(id)sender;
-(IBAction)setDbmTopValue:(id)sender;
-(IBAction)showButtonChange:(id)sender;
// Callbacks -- Drawer spectogram
-(IBAction)lineSpeedChanged:(id)sender;
-(IBAction)timeStampOnOff:(id)sender;
-(IBAction)scanRangeOnOff:(id)sender;

// Callbacks -- SerialDeviceTracker
-(void)changeInDevices:(BOOL)deviceAdded 
             withTitle:(NSString*)title 
              withPath:(NSString*)path;

// Callback -- Preference Panel
-(void) changedPreferences;
-(void)updateTimers;
-(void)scan:(NSTimer *)timer;
@end
