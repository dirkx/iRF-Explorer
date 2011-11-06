//
//  SpectrogramDrawerView.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
