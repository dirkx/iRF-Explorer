//
//  PreferenceController.h
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

#include <IOKit/serial/IOSerialKeys.h>
#import <Cocoa/Cocoa.h>

#import "SerialDevicesPopUpButton.h"
#import "PreferenceConstants.h"


@protocol SerialSettingsDelegate <NSObject>
@optional
-(SerialDeviceTracker*)serialDeviceTracker;
-(void)changedPreferences;
-(void)setSettingDeviceTitle:(NSString*)title;
-(void)setSettingDeviceIsSlow:(BOOL)isSlow;
-(void)setDecaySpeed:(float)decaySpeedInSeconds;
-(void)setAvgSpeed:(float)avgSpeedInSeconds;
-(void)setScanStrategy:(NSUInteger)e withLinger:(double)lingerTimeinSeconds;
@end

@interface PreferenceController : NSWindowController {
    id <SerialSettingsDelegate> delegate;
    IBOutlet SerialDevicesPopUpButton * deviceSelectionButton;
    IBOutlet NSButton * slowSpeedButton;
    IBOutlet NSTextField *decayLabel;
    IBOutlet NSSlider *decaySlider;
    IBOutlet NSTextField *avgLabel;
    IBOutlet NSSlider *avgSlider;
    IBOutlet NSMatrix *scanStrategyRadioButtons;
    IBOutlet NSTextField *lingerTimeTextField;
}

@property (assign) id <SerialSettingsDelegate> delegate;
@property (retain) IBOutlet SerialDevicesPopUpButton * deviceSelectionButton;

@property (retain) IBOutlet NSButton * slowSpeedButton;
@property (retain) IBOutlet NSTextField *decayLabel;
@property (retain) IBOutlet NSSlider *decaySlider;
@property (retain) IBOutlet NSTextField *avgLabel;
@property (retain) IBOutlet NSSlider *avgSlider;
@property (retain) IBOutlet NSMatrix *scanStrategyRadioButtons;
@property (retain) IBOutlet NSTextField *lingerTimeTextField;

// -(void)updateDeviceList:(NSDictionary *)devices;
-(void)readPreferences;
-(IBAction)decaySliderChange:(id)sender;
-(IBAction)avgSliderChange:(id)sender;
-(IBAction)scanStrategyChange:(id)sender;
-(IBAction)lingerTimeChange:(id)sender;
@end
