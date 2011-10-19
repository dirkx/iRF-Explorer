//
//  PreferenceController.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 05/10/2011.
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

@protocol SerialSettingsDelegate <NSObject>
@optional
-(void)setSettingDeviceTitle:(NSString*)title;
-(void)setSettingDeviceIsSlow:(BOOL)isSlow;
-(void)setDecaySpeed:(float)decaySpeedInSeconds;
-(void)setAvgSpeed:(float)avgSpeedInSeconds;
-(void)changedPreferences;
-(SerialDeviceTracker*)serialDeviceTracker;
@end

@interface PreferenceController : NSWindowController {
    id <SerialSettingsDelegate> delegate;
    IBOutlet SerialDevicesPopUpButton * deviceSelectionButton;
    IBOutlet NSButton * slowSpeedButton;
    IBOutlet NSTextField *decayLabel;
    IBOutlet NSSlider *decaySlider;
    IBOutlet NSTextField *avgLabel;
    IBOutlet NSSlider *avgSlider;
}

@property (assign) id <SerialSettingsDelegate> delegate;
@property (retain) IBOutlet SerialDevicesPopUpButton * deviceSelectionButton;

@property (retain) IBOutlet NSButton * slowSpeedButton;
@property (retain) IBOutlet NSTextField *decayLabel;
@property (retain) IBOutlet NSSlider *decaySlider;
@property (retain) IBOutlet NSTextField *avgLabel;
@property (retain) IBOutlet NSSlider *avgSlider;

// -(void)updateDeviceList:(NSDictionary *)devices;
-(void)readPreferences;
-(IBAction)decaySliderChange:(id)sender;
-(IBAction)avgSliderChange:(id)sender;
@end
