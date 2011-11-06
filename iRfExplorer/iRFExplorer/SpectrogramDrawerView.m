//
//  SpectrogramDrawerView.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpectrogramDrawerView.h"
#import "PreferenceConstants.h"

@implementation SpectrogramDrawerView
@synthesize scanSpeedField, showTimestampButton, scanRangeButton;
@synthesize spectrogramView;

@synthesize scanStrategy, lingerTimeInSeconds, linesPerSecond;

@synthesize scanTimer;

-(void)awakeFromNib {
    [super awakeFromNib];    
    linesPerSecond = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceLineSpeed] doubleValue];
    [self lineSpeedChanged:nil];
    scanSpeedField.logSlider = YES;
}

-(void)setAllControls:(BOOL)onOff {
    [super setAllControls:onOff];
    
    scanSpeedField.enabled = onOff;
    scanRangeButton.enabled = onOff;
    showTimestampButton.enabled = onOff;

    if (onOff)
        return;
    
    scanRangeButton.state = NSOffState;
    showTimestampButton.state = NSOffState;
}

-(void)newBoard:(id)sender {
    [super newBoard:sender];
    scanSpeedField.minValue = (device.commsSpeed < SPEED_4k8 && device.commsSpeed >0 ) ? 1.0 : 0.1;
    scanSpeedField.maxValue = 3600;
    scanSpeedField.scalarValue = linesPerSecond;
    [self updateTimers];
}

-(void)newConfig:(id)sender {
    [super newConfig:sender];
    [self updateTimers];
}

#pragma mark Callbacks form the Side config drawer

-(IBAction)lineSpeedChanged:(id)sender {
    if (sender != nil) {
        linesPerSecond = scanSpeedField.scalarValue;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:linesPerSecond] 
                                                 forKey:kPreferenceLineSpeed];
    };
    [spectrogramView.spectrogramGraphView setSecondsPerLine:linesPerSecond];

    // reset any times.
    [scanTimer invalidate];
    self.scanTimer = nil;

    [self scan:nil];
}

-(IBAction)timeStampOnOff:(id)sender {
    BOOL v = (showTimestampButton.state == NSOnState);
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:v] 
                                             forKey:kPreferenceTimeStamp];
    
    [spectrogramView.timeStampLegendView setShowTimeStamp:v];
}

-(IBAction)scanRangeOnOff:(id)sender {
    // update the timers.
    [self scan:nil];
}
-(BOOL)isScanning {
    return scanRangeButton.state == NSOnState;
}

-(void)updateTimers {
    if (device == nil)
        return;
    
    if (scanTimer) {
        [scanTimer invalidate];
    };
    self.scanTimer = nil;    
    
    if (![self isScanning])
        return;
    
    double dt = 0;
    switch(scanStrategy) {
        case SCAN_SLOW:
            // Assuming a 1/2 step size in this mode.
            //
            dt = linesPerSecond / 2 / (device.fMaxSpanHz / device.fSpanHz);
            break;
            
        case SCAN_LINGER:
            dt = lingerTimeInSeconds;
            break;
            
        case SCAN_FAST:
            dt = 0.1;   
            // need to check datasheet - or is this really 3-4 values (or 
            // just timerless - when one comes in). When we get called we
            // already have the unit reporting back the new value. So we
            // can prolly be quite agressive.
            break;
    };
    
    if (dt) {
        self.scanTimer = [NSTimer timerWithTimeInterval:dt
                                                 target:self 
                                               selector:@selector(scan:)
                                               userInfo:nil 
                                                repeats:NO ];
        
        [[NSRunLoop currentRunLoop] addTimer:scanTimer
                                     forMode:NSDefaultRunLoopMode];
    };
    
}


-(void)scan:(NSTimer *)timer {
    self.scanTimer = nil;
    
    if (![self isScanning])
        return;
    
    double c, step = 1.0;
    if (scanStrategy == SCAN_SLOW) 
        step = 2.0;
    
    if (scanDir) 
        c = device.fCenterHz + device.fSpanHz / step;
    else
        c = device.fCenterHz - device.fSpanHz / step;
    
    if (c + device.fSpanHz/2 >= device.fMaxFreqHz) {
        scanDir = FALSE;
    };
    
    if (c - device.fSpanHz/2 <= device.fMinFreqHz) {
        scanDir = TRUE;
    };
    
    device.fCenterHz = c;
    
    // leave the resetting of the timer to a time
    // at which we actaully got some data back
    // from the device...
}

-(void)dealloc {
    [scanTimer invalidate];
    self.scanTimer = nil;
    [super dealloc];
}
@end
