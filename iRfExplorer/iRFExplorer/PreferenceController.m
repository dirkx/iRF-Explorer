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
#import "iRFExplorerAppDelegate.h"
#import "NSStringExtensions.h"

@implementation PreferenceController
@synthesize slowSpeedButton, deviceSelectionButton;
@synthesize decayLabel, decaySlider;
@synthesize avgLabel, avgSlider;
@synthesize scanStrategyRadioButtons, lingerTimeTextField;
@synthesize delegate;

-(void)readPreferences {
    NSString * deviceTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedDevice"];
    BOOL isSlow = [[[NSUserDefaults standardUserDefaults] valueForKey:@"slowSpeed"] boolValue];
    float decay = [[[NSUserDefaults standardUserDefaults] valueForKey:@"decayValue"] floatValue];
    float avg = [[[NSUserDefaults standardUserDefaults] valueForKey:@"avgValue"] floatValue];
    scan_strategy_t e = [[[NSUserDefaults standardUserDefaults] valueForKey:@"scanStrategy"] intValue];
    double lingerTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@"lingerTime"] doubleValue];
                         ;
    [delegate setSettingDeviceTitle:deviceTitle];    
    [delegate setSettingDeviceIsSlow:isSlow];
    [delegate setDecaySpeed:decay];
    [delegate setAvgSpeed:avg];
    [delegate setScanStrategy:e withLinger:lingerTime];
    
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

    scan_strategy_t e = [[[NSUserDefaults standardUserDefaults] valueForKey:@"scanStrategy"] intValue];
    switch(e) {
        case SCAN_SLOW: [scanStrategyRadioButtons selectCellAtRow:0 column:0];
            break;
        case SCAN_FAST: [scanStrategyRadioButtons selectCellAtRow:1 column:0];
            break;
        case SCAN_LINGER: [scanStrategyRadioButtons selectCellAtRow:2 column:0];
            break;
    }
    
    double lingerTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@"lingerTime"] doubleValue];
    [lingerTimeTextField setStringValue:[NSString stringFromSeconds:lingerTime 
                                                          keepShort:YES]];

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

-(IBAction)scanStrategyChange:(id)sender {
    [self lingerTimeChange:self];
}

-(IBAction)lingerTimeChange:(id)sender {
    double v = lingerTimeTextField.doubleValue;
    
    if ([lingerTimeTextField.stringValue hasSuffix:@"m"])
        v *= 60.0;

    if ([lingerTimeTextField.stringValue hasSuffix:@"h"])
        v *= 60 * 60.0;

    // shorten to mins or seconds as needed.
    //
    [lingerTimeTextField setStringValue:[NSString stringFromSeconds:v keepShort:YES]];

    scan_strategy_t s;
    switch (scanStrategyRadioButtons.selectedRow) {
        case 0: s = SCAN_FAST;
            break;
        case 1: s = SCAN_SLOW;
            break;
        case 2: s = SCAN_LINGER;
            break;
        default:
            assert(1 == 2);
            break;
    }

    [delegate setScanStrategy:s withLinger:v];
}

- (void) dealloc {
    self.delegate = nil;
    self.deviceSelectionButton = nil;
    
    [super dealloc];
}
@end
