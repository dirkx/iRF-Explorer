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
#import "svnrevision.h"
#import "PreferenceController.h"
#import "SerialDeviceTracker.h"
#import "RFExporerCmds.h"
#import "SpectrumGraphView.h"
#import "FrequencyLegendView.h"
#import "dBmLegendView.h"
#import "RFExplorer.h"
#import "SpectrumView.h"
#import "SpectrogramView.h"
#import "ConfigView.h"
#import "FrequencyTextFieldSliderView.h"
#import "TimePeriodTextFieldSliderView.h"
#import "SignalTextFieldSliderView.h"
#import "SpectrumDrawerView.h"
#import "SpectrogramDrawerView.h"
#import "SpectrogramGraphView.h"
#import "StopPauseView.h"


@interface iRFExplorerAppDelegate : NSObject <NSApplicationDelegate, 
                                       // NSWindowDelegate,
                                       NSTabViewDelegate,
                                       SerialSettingsDelegate, 
                                       SerialDeviceTrackerDelegate,
                                       RFGUICallbacks> 
{
    PreferenceController *preferenceController;
    SerialDeviceTracker *serialDeviceTracker;
    RFExplorer * rfExplorer;

    NSString *settingDeviceTitle;
    BOOL settingDeviceIsSlow;
    
    IBOutlet NSTabView *mainView;
    IBOutlet NSDrawer *drawerView;
    IBOutlet NSWindow *window;
    

    // tab 1 -- main graph display
    IBOutlet SpectrumView * spectrumView;
    IBOutlet NSScrollView *spectrumScollView;
    IBOutlet SpectrumGraphView *spectrumGraphView;
    IBOutlet StopPauseView *spectrumStopPauseView;
    
    // tab 2 -- plays live screen captures
    IBOutlet SomeTabView *screenTabView;
    IBOutlet NSImageView *liveImageCell;
    IBOutlet NSButton *liveButton;
    IBOutlet NSTextField *pausedLabel;
    BOOL playing;
    
    // Just the spectrogram
    IBOutlet SpectrogramView * spectrogramView;
    IBOutlet SpectrogramGraphView * spectrogramGraphView;
    IBOutlet StopPauseView *spectrogramStopPauseView;
    
    // tab 4 -- lots of info
    IBOutlet ConfigView *configTabView;
    
    // bottom bar - just some status info
    IBOutlet NSTextField *firmwareLabel;
    IBOutlet NSTextField *boardLabel;
    IBOutlet NSTextField *expansionLabel;
    // IBOutlet NSTextField *deviceLabel;
    // IBOutlet NSMatrix *boardSwitch;
    
    // Possible content for the drawer
    IBOutlet SpectrogramDrawerView * spectogramDrawerView;    
    IBOutlet SpectrumDrawerView * spectrumDrawerView;
}

@property (assign) IBOutlet NSTabView *mainView;
@property (assign) IBOutlet NSWindow *window;

// Drawers
@property (assign) IBOutlet NSDrawer *drawerView;
@property (assign) IBOutlet SpectrogramDrawerView * spectogramDrawerView;    
@property (assign) IBOutlet SpectrumDrawerView * spectrumDrawerView;

// Bottom bar
@property (assign) IBOutlet NSTextField *firmwareLabel;
@property (assign) IBOutlet NSTextField *boardLabel;
@property (assign) IBOutlet NSTextField *expansionLabel;

// Tab 1
@property (assign) IBOutlet SpectrumView * spectrumView;
@property (assign) IBOutlet NSView *spectrumGraphView;
@property (assign) IBOutlet StopPauseView *spectrumStopPauseView;

// Tab 2
@property (assign) IBOutlet SomeTabView *screenTabView;
@property (assign) IBOutlet NSImageView *liveImageCell;
@property (assign) IBOutlet NSButton *liveButton;
@property (assign) IBOutlet NSTextField *pausedLabel;


// tab 3 - spectrogram
@property (assign) IBOutlet SpectrogramView * spectrogramView;
@property (assign) IBOutlet SpectrogramGraphView * spectrogramGraphView;
@property (assign) IBOutlet StopPauseView *spectrogramStopPauseView;

// tab 4 - info
@property (assign) IBOutlet ConfigView *configTabView;

// Other sundry.
@property (retain) NSString *settingDeviceTitle;
@property (assign) BOOL settingDeviceIsSlow;
@property (retain) SerialDeviceTracker *serialDeviceTracker;

// About window - as we show our SVN revision string
-(IBAction)showCustomAboutPanel:(id)sender;

// Info Tab
-(IBAction)showPreferences:(id)sender; 
-(IBAction)toggleLiveScreenUpdate:(id)sender;
-(IBAction)configScreenUpdating:(id)sender;

// Callbacks - switch bottom main window
-(IBAction)changeBoard:(id)sender;

// Callbacks -- SerialDeviceTracker
-(void)changeInDevices:(BOOL)deviceAdded 
             withTitle:(NSString*)title 
              withPath:(NSString*)path;

-(IBAction)togglePausePlay:(id)sender;

-(IBAction)newDocument:(id)sender;

// Callback -- Preference Panel
-(void) changedPreferences;
@end
