//
//  PreferenceController.m
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

#import "PreferenceController.h"
#import "NSStringExtensions.h"

@implementation PreferenceController
@synthesize slowSpeedButton, deviceSelectionButton;
@synthesize decayLabel, decaySlider;
@synthesize avgLabel, avgSlider;
@synthesize delegate;

-(void)readPreferences {
    NSString * deviceTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedDevice"];
    BOOL isSlow = [[[NSUserDefaults standardUserDefaults] valueForKey:@"slowSpeed"] boolValue];
    float decay = [[[NSUserDefaults standardUserDefaults] valueForKey:@"decayValue"] floatValue];
    float avg = [[[NSUserDefaults standardUserDefaults] valueForKey:@"avgValue"] floatValue];

    [delegate setSettingDeviceTitle:deviceTitle];    
    [delegate setSettingDeviceIsSlow:isSlow];
    [delegate setDecaySpeed:decay];
    [delegate setAvgSpeed:avg];
    
    [delegate changedPreferences];
}

- (void)awakeFromNib 
{    
    NSDictionary * ud = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    slowSpeedButton.state = [[ud valueForKey:@"slowSpeed"] boolValue] ? NSOnState : NSOffState;
    NSString * devStr = [ud valueForKey:@"selectedDevice"];

    // Swap placeholder by the actual pulldown.
    NSRect f = deviceSelectionButton.frame;
    [deviceSelectionButton removeFromSuperview];
    
    deviceSelectionButton = [[SerialDevicesPopUpButton alloc] initWithFrame:f];
    [self.window.contentView addSubview:deviceSelectionButton]; 
    deviceSelectionButton.target = self;
    deviceSelectionButton.action = @selector(selectedDevice:);
    
    NSArray * titles = [delegate.serialDeviceTracker.devices allKeys];
    [deviceSelectionButton setDevices:titles];

    if (devStr)
        [deviceSelectionButton selectItemWithTitle:devStr];

    // bit of a lie - really the slider value.
    if ([ud valueForKey:@"decayValue"] == nil)
        decaySlider.floatValue = 3;
    else
        decaySlider.floatValue = [[ud valueForKey:@"decayValue"] floatValue];
    
    [self decaySliderChange:decaySlider];

    if ([ud valueForKey:@"avgValue"] == nil)
        avgSlider.floatValue = 3;
    else
        avgSlider.floatValue = [[ud valueForKey:@"avgValue"] floatValue];
    
    [self avgSliderChange:avgSlider];

    [super windowDidLoad];
}

- (IBAction)toggleSpeed:(id)sender {
    BOOL isSlow = ((NSButton *)sender).state == NSOnState;
    BOOL old = [[[NSUserDefaults standardUserDefaults] valueForKey:@"slowSpeed"] boolValue];
    if (old != isSlow) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isSlow] forKey:@"slowSpeed"];
        [delegate setSettingDeviceIsSlow:isSlow];
        [delegate changedPreferences];
    };
}

-(IBAction)selectedDevice:(id)sender {
    NSString * deviceTitle = ((NSPopUpButton *)sender).titleOfSelectedItem;
//  may be better to always do this - as to make the behaviour on re-seating
//  a bit more logical.
//  NSString * old = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedDevice"];
//  if (![old isEqualToString:deviceTitle]) {
        [[NSUserDefaults standardUserDefaults] setValue:deviceTitle forKey:@"selectedDevice"];
        [delegate setSettingDeviceTitle:deviceTitle];
        [delegate changedPreferences];
//  }
}

-(IBAction)decaySliderChange:(NSSlider *)sender {
    float v = sender.floatValue;
    
    // bit of a lie - really the slider value.
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:v] forKey:@"decayValue"];

    v = 0.2 + 0.2 * v * v * v;
    if (v > 10) 
        v = floorf(v);
    else if (v > 3)
         v = 2.0 * floorf(v/2.0);
    
    [decayLabel setStringValue:[NSString stringFromSeconds:v]];

    [delegate setDecaySpeed:v];
}

-(IBAction)avgSliderChange:(NSSlider *)sender {
    float v = sender.floatValue;
    
    // bit of a lie - really the slider value.
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:v] forKey:@"avgValue"];
    
    v = 0.2 + 0.2 * v * v * v;
    if (v > 10) 
        v = floorf(v);
    else if (v > 3)
        v = 2.0 * floorf(v/2.0);
    
    [avgLabel setStringValue:[NSString stringFromSeconds:v]];
    
    [delegate setAvgSpeed:v];
}

- (void) dealloc {
    self.delegate = nil;
    self.deviceSelectionButton = nil;
    
    [super dealloc];
}
@end
