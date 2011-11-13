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
#import <SystemConfiguration/SystemConfiguration.h>

// Note that some of those are tied to mappings in the NIB.
//
NSString * const kPreferencePngOverPdf = @"pngOverPdf";
NSString * const kPreferenceLatexOverTsv = @"latexOverTsv";
NSString * const kPreferenceNoImages = @"noImages";
NSString * const kPreferenceLimsIncludeSettings = @"limsIncludeSettings";
NSString * const kPreferenceLimsIncludeHostInfo = @"limsIncludeHostInfo";
NSString * const kPreferenceLimsIncludeTimeStamps = @"limsIncludeTimeStamps";
NSString * const kPreferenceLimsIncludeDeviceInfo = @"limsIncludeDeviceInfo";
NSString * const kPreferenceLimsIncludeComment = @"limsIncludeComment";
NSString * const kPreferenceLimsCommentString = @"limsCommentString";
NSString * const kPreferenceLineSpeed = @"lineSpeed";
NSString * const kPreferenceScanRange = @"scanRange";
NSString * const kPreferenceSlowSpeed = @"slowSpeed";
NSString * const kPreferenceDecayValue = @"decayValue";
NSString * const kPreferenceAvgValue = @"avgValue";
NSString * const kPreferenceScanStrategy = @"scanStrategy";
NSString * const kPreferenceLingerTime = @"lingerTime";
NSString * const kPreferenceSelectedDevice = @"selectedDevice";
NSString * const kPreferenceShowAverage = @"showAverage";
NSString * const kPreferenceShowMax = @"showMax";
NSString * const kPreferenceShowTimestamps = @"showTimestamps";
NSString * const kPreferenceTimeStamp = @"timeStamp";
NSString * const kPreferenceShowDecay = @"showDecay";
NSString * const kPreferenceScanFullrange = @"scanFullrange";

// Not exposed through UI settings.
//
NSString * const kCmdLog = @"cmdLog";
NSString * const kCommsLog = @"commsLog";
NSString * const kCommsDebug = @"commsDebug";

@implementation PreferenceController
@synthesize slowSpeedButton, deviceSelectionButton;
@synthesize decayLabel, decaySlider;
@synthesize avgLabel, avgSlider;
@synthesize scanStrategyRadioButtons, lingerTimeTextField;
@synthesize delegate;

-(double)sliderToValue:(double) v {
    v = 0.2 + 0.2 * v * v * v;
    if (v > 10) 
        v = floorf(v);
    else if (v > 3)
        v = 2.0 * floorf(v/2.0);
    return v;
}

-(void)readPreferences {
    // NSString * deviceTitle = [[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceSelectedDevice];
    BOOL isSlow = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceSlowSpeed] boolValue];
    float decay = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceDecayValue] floatValue];
    float avg = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceAvgValue] floatValue]; 
    scan_strategy_t e = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceScanStrategy] intValue];
    double lingerTime = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceLingerTime] doubleValue];
    
    decay = [self sliderToValue:decay];
    avg = [self sliderToValue:avg];

    // [delegate setSettingDeviceTitle:deviceTitle];    
    [delegate setSettingDeviceIsSlow:isSlow];
    [delegate setDecaySpeed:decay];
    [delegate setAvgSpeed:avg];
    [delegate setScanStrategy:e withLinger:lingerTime];

    [delegate changedPreferences];
}

- (void)awakeFromNib 
{    
    [super awakeFromNib];
    NSDictionary * ud = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSString * devStr = [ud valueForKey:kPreferenceSelectedDevice];

    if (![ud valueForKey:kPreferenceLimsCommentString]) {
        CFStringRef name;
        NSString *computerName;
        name=SCDynamicStoreCopyComputerName(NULL,NULL);
        computerName=[NSString stringWithString:(NSString *)name];
        
        NSString * fmt = NSLocalizedString(@"Measured by %@ on %@",
                                           @"Default LIMS string, arguments are full user name and computername");
        NSUserDefaultsController * udc = [NSUserDefaultsController sharedUserDefaultsController];
        [udc.values setValue:[NSString stringWithFormat:fmt, NSFullUserName(), computerName] 
               forKey:kPreferenceLimsCommentString];
        
        CFRelease(name);
        // all other defaults are off/none.
    }
    
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

    // Ensure textual representaion is in sync too.
    
    [self decaySliderChange:decaySlider];
    [self avgSliderChange:avgSlider];
}

- (IBAction)toggleSpeed:(id)sender {
    [delegate setSettingDeviceIsSlow:slowSpeedButton.state == NSOnState];
    [delegate changedPreferences];
}

-(IBAction)selectedDevice:(id)sender {
    NSString * deviceTitle = ((NSPopUpButton *)sender).titleOfSelectedItem;
    [delegate setSettingDeviceTitle:deviceTitle];
    [delegate changedPreferences];
}

-(IBAction)decaySliderChange:(NSSlider *)sender {
    float v = sender.floatValue;
    
    // bit of a lie - really the slider value.
    // [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:v] forKey:@"decayValue"];

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
    // [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:v] forKey:@"avgValue"];
    
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
    NSString * _h = NSLocalizedString(@"h",@"short hour unit");
//    NSString * _hour = NSLocalizedString(@" hour",@"medium hour unit  - prefix with space where needed");
    NSString * _m = NSLocalizedString(@"m",@"short minute unit");
//    NSString * _min = NSLocalizedString(@" min",@"medium minute unit  - prefix with space where needed");
//    NSString * _s = NSLocalizedString(@"s",@"short second unit");
//    NSString * _sec = NSLocalizedString(@" sec",@"medium second unit - prefix with space where needed");
    
    if ([lingerTimeTextField.stringValue hasSuffix:_m])
        v *= 60.0;

    if ([lingerTimeTextField.stringValue hasSuffix:_h])
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
