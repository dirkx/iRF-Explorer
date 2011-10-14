//
//  PreferenceController.m
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

#import "PreferenceController.h"

@implementation PreferenceController
@synthesize slowSpeedButton, deviceSelectionButton;
@synthesize delegate;

-(void)readPreferences {
    NSString * deviceTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedDevice"];
    BOOL isSlow = [[[NSUserDefaults standardUserDefaults] valueForKey:@"slowSpeed"] boolValue];

    [delegate setSettingDeviceTitle:deviceTitle];    
    [delegate setSettingDeviceIsSlow:isSlow];
    
    [delegate changedPreferences];
}

- (void)windowDidLoad
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
    NSString * old = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedDevice"];
    if (![old isEqualToString:deviceTitle]) {

        [[NSUserDefaults standardUserDefaults] setValue:deviceTitle forKey:@"selectedDevice"];
        [delegate setSettingDeviceTitle:deviceTitle];
        [delegate changedPreferences];
    }
}

- (void) dealloc {
}
@end
