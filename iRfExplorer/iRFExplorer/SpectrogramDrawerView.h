//
//  SpectrogramDrawerView.h
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

#import "SomeDrawerView.h"

#import "TimePeriodTextFieldSliderView.h"
#import "SpectrogramGraphView.h"
#import "SpectrogramView.h"

typedef enum {
    SCAN_SLOW, SCAN_FAST, SCAN_LINGER
} scan_strategy_t;

@interface SpectrogramDrawerView : SomeDrawerView {    // Drawer spectogram
    IBOutlet TimePeriodTextFieldSliderView * scanSpeedField;
    IBOutlet NSButton * showTimestampButton;
    IBOutlet NSButton * scanRangeButton;

    IBOutlet SpectrogramView * spectrogramView;
    
    BOOL scanDir;
    NSTimer * scanTimer;
    scan_strategy_t scanStrategy;
    double lingerTimeInSeconds, linesPerSecond;
}

@property (retain) IBOutlet SpectrogramView * spectrogramView;

@property (retain) IBOutlet TimePeriodTextFieldSliderView * scanSpeedField;
@property (retain) IBOutlet NSButton * showTimestampButton;
@property (retain) IBOutlet NSButton * scanRangeButton;

@property (retain) NSTimer * scanTimer;

@property (assign) scan_strategy_t scanStrategy;
@property (assign) double lingerTimeInSeconds, linesPerSecond;

-(IBAction)lineSpeedChanged:(id)sender;
-(IBAction)timeStampOnOff:(id)sender;
-(IBAction)scanRangeOnOff:(id)sender;

-(BOOL)isScanning;

-(void)updateTimers;
-(void)scan:(NSTimer *)timer;
@end
