//
//  iRFExplorerAppDelegate.m
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

#import "iRFExplorerAppDelegate.h"
#import "LCDImage.h"
#import "RFExplorer.h"
#import "NSStringExtensions.h"
#import "Spectrum.h"

@implementation iRFExplorerAppDelegate

// window and general backgroud threads.
//
@synthesize window, mainView, drawerView;
@synthesize serialDeviceTracker,spectrogramView;    

// main view - bottom bar.
//
@synthesize firmwareLabel, boardLabel, expansionLabel, deviceLabel;

// tab 1 spectrum
//
@synthesize spectrumView, spectrumScollView, frequencyLegendView;
@synthesize dbmLegendView, spectrumBackgroundView;

// tab 2 live view
//
@synthesize liveButton, liveImageCell, pausedLabel;

// preference Panel
//
@synthesize settingDeviceTitle, settingDeviceIsSlow;

// Tab -3 info
//
@synthesize infoBandCenterFreq, infoBandMinFreq, infoBandMaxFreq, infoBandSpanFreq, infoBoardTitle, infoBoardMinFreq, infoBoardMaxFreq, infoAttenTop, infoAttenBott, infoDevFirmware, infoDevMain, infoDevExpansion, infoDevBaudrate;
@synthesize showMaxButton, showAvgxButton, decayButton;
@synthesize scanTimer;

// Drawers
@synthesize spectogramDrawerView,spectrumDrawerView;

// Drawer Spectrum
@synthesize centerFreqSlider, centerFreqTextField;
@synthesize freqSpanSlider, freqSpanTextField;
@synthesize dbmTopTextField, dbmTopSlider;
@synthesize dbmBotTextField, dbmBotSlider;

// Drawer Spectrogram
@synthesize scanSpeedTextField, scanSpeedSlider, showTimestampButton, scanRangeButton;

#pragma mark Startup and application level sundry.

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    preferenceController = [[PreferenceController alloc] initWithWindowNibName:@"Preferences"];
    preferenceController.delegate = self;
    
    serialDeviceTracker = [[SerialDeviceTracker alloc] init];
    serialDeviceTracker.delegate = self;
        
    playing = FALSE;
    [self configScreenUpdating:self];
    
    // This will also trigger a callback telling me about
    // my current settings.
    [preferenceController readPreferences];
       
    [self newScreen:[LCDImage imageWithReticule]];
    
    [[spectrumScollView contentView] setPostsBoundsChangedNotifications: YES];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter] ;
    [center addObserver: self
               selector: @selector(spectrumScrolledNotification:)
                   name: NSViewBoundsDidChangeNotification
                 object: [spectrumScollView contentView]];
 
    // the legends need to know about the graph - so they can make the same
    // scaling calculations.
    //
    dbmLegendView.graphView = spectrumView;
    frequencyLegendView.graphView = spectrumView;
    
    // We always start with the drawer opened ? Or shall we keep state
    // in prefs ? Or nicer to open it when we have settings ?
#if 0
    [drawerView open:(self)];
#endif
    
    // ensure drawer has the right content on startup - from hereon it is maintained
    // (even if closed) by the tab change callback. We need the sensible default
    // as the callback minimizes the changes for non drawer applicable tabs.
    self.drawerView.contentView = spectrumDrawerView;
    [self tabView:mainView didSelectTabViewItem:mainView.selectedTabViewItem];

    [self lineSpeedChanged:nil];
    [self timeStampOnOff:nil];
    [self scanRangeOnOff:nil];
    
#if 1
    // Detect the ALT key pressed - and activate demo mode
    // if so.
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    
    if ((modifiers & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate)
    {
        NSLog(@"Demo mode activated");
        [serialDeviceTracker.devices setValue:@"demo1"
                                       forKey:@"Demo generator"];
        [serialDeviceTracker.devices setValue:@"demo2"
                                       forKey:@"Crashy Demo generator"];
        
        self.settingDeviceTitle = @"Demo generator";
        [self changedPreferences];
    }
#endif
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{	
	return NSTerminateNow ;
}

-(void)updateTimers {

    if (scanTimer) {
        [scanTimer invalidate];
        self.scanTimer = nil;
    };

    if (scanRangeButton.state != NSOnState) { 
        return;
    }

    double dt;
    switch(scanStrategy) {
        case SCAN_SLOW:
            // Assuming a 1/2 step size in this mode.
            //
            dt = linesPerSecond / 2 / (rfExplorer.fMaxSpanMhz / rfExplorer.fSpanMhz);
            break;

        case SCAN_LINGER:
            dt = lingerTimeInSeconds;
            break;
            
        case SCAN_FAST:
            dt = 0.1;   // need to check datasheet - or is this really 3-4 values (or 
            // just timerless - when one comes in). When we get called we
            // already have the unit reporting back the new value. So we
            // can prolly be quite agressive.
            break;
    };
    
    self.scanTimer = [NSTimer timerWithTimeInterval:dt
                                             target:self 
                                           selector:@selector(scan:)
                                           userInfo:nil 
                                            repeats:NO ];
    
    [[NSRunLoop currentRunLoop] addTimer:scanTimer
                                 forMode:NSDefaultRunLoopMode];
}

-(void)scan:(NSTimer *)timer {
    self.scanTimer = nil;
    
    if (scanRangeButton.state == NSOffState)
        return;

    double c, step = 1.0;
    if (scanStrategy == SCAN_SLOW) 
        step = 2.0;

    if (scanDir) 
        c = rfExplorer.fCenterMhz + rfExplorer.fSpanMhz / step;
    else
        c = rfExplorer.fCenterMhz - rfExplorer.fSpanMhz / step;
    
    if (c + rfExplorer.fSpanMhz/2 >= rfExplorer.fMaxFreqMhz) {
        scanDir = FALSE;
    };
    
    if (c - rfExplorer.fSpanMhz/2 <= rfExplorer.fMinFreqMhz) {
        scanDir = TRUE;
    };
    
    [centerFreqTextField setDoubleValue:c];

    [self setCenterFreqValue:centerFreqTextField];
}

#pragma mark Prefernces and serial port loss/changes.

-(IBAction)showPreferences:(id)sender{    
    [preferenceController showWindow:self];
}

// Callbacks - SerialDeviceTracker
//
-(void)changeInDevices:(BOOL)deviceAdded 
             withTitle:(NSString*)title 
              withPath:(NSString*)path 
{
    [preferenceController.deviceSelectionButton changeInDevices:deviceAdded 
                                                      withTitle:title 
                                                       withPath:path];
}

-(void)setDecaySpeed:(float)decaySpeedInSeconds {
    spectrumView.decayInSeconds = decaySpeedInSeconds;
}

-(void)setAvgSpeed:(float)avgSpeedInSeconds {
    spectrumView.averagingTimeWindowInSeconds = avgSpeedInSeconds;
}

-(void)setScanStrategy:(NSUInteger)_strategy withLinger:(double)_lingerTimeinSeconds {
    scanStrategy = (scan_strategy_t) _strategy;
    lingerTimeInSeconds = _lingerTimeinSeconds;
    
    [self updateTimers];
}

-(void)setAllControls:(BOOL)onOff {
    freqSpanSlider.enabled = onOff;
    freqSpanTextField.enabled = onOff;
    centerFreqSlider.enabled = onOff;
    centerFreqTextField.enabled = onOff;
    dbmBotSlider.enabled = onOff;
    dbmBotTextField.enabled = onOff;
    dbmTopSlider.enabled = onOff;
    dbmTopTextField.enabled = onOff;
    liveButton.enabled = onOff;
    showAvgxButton.enabled = onOff;
    showMaxButton.enabled = onOff;
    decayButton.enabled = onOff;
    
    // always do this - or only once during startup ?
    //
    if (onOff)
        [drawerView open:(self)];

    if(onOff)
        return;
    
    freqSpanTextField.stringValue = 
    centerFreqTextField.stringValue = 
    dbmBotTextField.stringValue = 
    dbmTopTextField.stringValue = @"";
    
    boardLabel.stringValue = @"";    
    expansionLabel.stringValue = @"";
    
    infoBandCenterFreq.stringValue = @"";
    infoBandMinFreq.stringValue = @"";
    infoBandMaxFreq.stringValue = @"";
    infoBandSpanFreq.stringValue = @"";
    infoBoardTitle.stringValue = @"";
    infoBoardMinFreq.stringValue = @"";
    infoBoardMaxFreq.stringValue = @"";
    infoAttenTop.stringValue = @"";
    infoAttenBott.stringValue = @"";
    infoDevFirmware.stringValue = @"";
    infoDevMain.stringValue = @"";
    infoDevExpansion.stringValue = @"";
    infoDevBaudrate.stringValue = @"";

    showAvgxButton.state = NSOffState;
    showMaxButton.state = NSOffState;
    decayButton.state = NSOffState;
}

// callback from the preference panel - either on initial init
// or as the user changes things.
//
-(void)changedPreferences {
    NSLog(@"Preference change");
    
    spectrumView.device = nil;
    dbmLegendView.device = nil;
    frequencyLegendView.device = nil;

    [rfExplorer release];
    rfExplorer = nil;
    
    NSString * devPath = [serialDeviceTracker.devices objectForKey:settingDeviceTitle ];
    
    if (devPath) {
        rfExplorer = [[RFExplorer alloc] initWithPath:devPath
                                      withSlowSetting:settingDeviceIsSlow];
        
        rfExplorer.delegate = self;
        
        spectrumView.device = rfExplorer;
        dbmLegendView.device = rfExplorer;
        frequencyLegendView.device = rfExplorer;        
        spectrogramView.device = rfExplorer;
    };    
    
    deviceLabel.stringValue = rfExplorer ? settingDeviceTitle : @"<unset>";

    firmwareLabel.stringValue = rfExplorer ? @"Contacting..." : 
        (devPath ? @"Comms failed" : @"");
        
    [self setAllControls:FALSE];
    
    [self showButtonChange:nil];
    
    [dbmLegendView setNeedsDisplay:TRUE];
    [frequencyLegendView setNeedsDisplay:TRUE];
    
    [self configScreenUpdating:self];
}

#pragma mark Callbacks form the Side config drawer

-(IBAction)showButtonChange:(NSButton *)sender  {
    
    if (sender == showMaxButton || sender == nil) {
        [spectrumView setAndResetShowMax:(showMaxButton.state == NSOnState)];
    };
    if (sender == showAvgxButton || sender == nil) {
        [spectrumView setAndResetShowAvg:(showAvgxButton.state == NSOnState)];
    };
    if (sender == decayButton || sender == nil) {
        [spectrumView setAndResetDecay:(decayButton.state == NSOnState)];
    };
}

-(IBAction)setCenterFreqValue:(id)sender {
    float v = [sender floatValue];
    
    float r = rfExplorer.fMaxFreqMhz - rfExplorer.fMinFreqMhz;
    r -= rfExplorer.fSpanMhz;
    
    if (sender == centerFreqSlider) {
        v = centerFreqSlider.floatValue;
        v = rfExplorer.fMinFreqMhz + v * r + rfExplorer.fSpanMhz/2;
    };
    
    float min = rfExplorer.fMinFreqMhz + rfExplorer.fSpanMhz/2;
    float max = rfExplorer.fMaxFreqMhz - rfExplorer.fSpanMhz/2;

    if (v < min)
            v = min;
    
    if (v > max)
            v = max;
          
    centerFreqTextField.stringValue = [NSString stringWithFormat:@"%.2f", v];
    
    centerFreqSlider.floatValue = (v - rfExplorer.fMinFreqMhz - rfExplorer.fSpanMhz/2) / r;

    if (sender == centerFreqSlider || sender == centerFreqTextField)
        rfExplorer.fCenterMhz = v;    
}

-(IBAction)setFreqSpanValue:(id)sender {
    double v = [sender floatValue];
    double r = rfExplorer.fMaxSpanMhz - rfExplorer.fMinSpanMhz;
    
    if (sender == freqSpanSlider) {
        v = rfExplorer.fMinSpanMhz + v * r;
    };
    
    if (v < rfExplorer.fMinSpanMhz)
        v = rfExplorer.fMinSpanMhz;
    
    if (v > rfExplorer.fMaxSpanMhz)
        v = rfExplorer.fMaxSpanMhz;

    freqSpanTextField.stringValue = [NSString stringWithFormat:@"%.2f", v];

    freqSpanSlider.floatValue = (v -  rfExplorer.fMinSpanMhz) / r;
    
    if (sender == freqSpanSlider || sender == freqSpanTextField)
        rfExplorer.fSpanMhz = v;
    
}

-(IBAction)setDbmBotValue:(id)sender {
    float v = [sender floatValue];
    if (sender == dbmBotSlider) {
        v = rfExplorer.fAmplitudeMin + v * (rfExplorer.fAmplitudeFullRange - rfExplorer.fAmplitudeMinSpan);
    };
    
    if (v > rfExplorer.fAmplitudeMax - rfExplorer.fAmplitudeMinSpan)
        v = rfExplorer.fAmplitudeMax - rfExplorer.fAmplitudeMinSpan;
    
    if (v < rfExplorer.fAmplitudeMin)
        v = rfExplorer.fAmplitudeMin;
    
    dbmBotTextField.stringValue = [NSString stringWithFormat:@"%d", (int)(v)];
    dbmBotSlider.floatValue = (v - rfExplorer.fAmplitudeMin) / rfExplorer.fAmplitudeFullRange;
    
    if (sender == dbmBotSlider || sender == dbmBotTextField)
        rfExplorer.fAmplitudeBottom = v;
}

-(IBAction)setDbmTopValue:(id)sender {
    float v = [sender floatValue];
    if (sender == dbmTopSlider) {
        v = rfExplorer.fAmplitudeMin + rfExplorer.fAmplitudeMinSpan + 
            v * (rfExplorer.fAmplitudeFullRange - rfExplorer.fAmplitudeMinSpan);
    };
    
    if (v > rfExplorer.fAmplitudeMax)
        v = rfExplorer.fAmplitudeMax;
    
    if (v < rfExplorer.fAmplitudeMin + rfExplorer.fAmplitudeMinSpan)
        v = rfExplorer.fAmplitudeMin + rfExplorer.fAmplitudeMinSpan;
    
    dbmTopTextField.stringValue = [NSString stringWithFormat:@"%d", (int)(v)];
    dbmTopSlider.floatValue = (v - rfExplorer.fAmplitudeMin) / rfExplorer.fAmplitudeFullRange;
    
    if (sender == dbmTopSlider || sender == dbmTopTextField)
        rfExplorer.fAmplitudeTop = v;
}

-(IBAction)lineSpeedChanged:(id)sender {
    double v;
    if (sender == nil) {
        v = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"lineSpeed"] doubleValue];
    }
    else if (sender == scanSpeedSlider) {
        v = scanSpeedSlider.doubleValue;
        v = v*v*v / 1000;
    } else {
        v = scanSpeedTextField.doubleValue;
        if ([scanSpeedTextField.stringValue hasSuffix:@"m"])
            v *= 60;
        if ([scanSpeedTextField.stringValue hasSuffix:@"h"])
            v *= 60*60;
    }
    double minSpeed = settingDeviceIsSlow ? 1.0 : 0.1;

    // We cannot go any faster - and prolly should move this into
    // RFExplorer device and ask it what it can handle.
    //
    if (v < minSpeed) 
        v = minSpeed;

    [scanSpeedSlider setDoubleValue:pow(v * 1000, 1/3.0)];
    [scanSpeedTextField setStringValue:[NSString stringFromSeconds:v keepShort:YES]];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:v] 
                                             forKey:@"lineSpeed"];
    
    linesPerSecond = v;
    [spectrogramView setSecondsPerLine:v];
}

-(IBAction)timeStampOnOff:(id)sender {
    BOOL v = (showTimestampButton.state == NSOnState);
    
    if (sender == nil) {
        v = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"timeStamp"] boolValue];
        [showTimestampButton setState:(v ? NSOnState : NSOffState)]; 
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:v] 
                                             forKey:@"timeStamp"];
       
    [spectrogramView setShowTimeStamp:v];
}

-(IBAction)scanRangeOnOff:(id)sender {
    BOOL v = (scanRangeButton.state == NSOnState);
    if (sender == nil) {
        v = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"scanRange"] boolValue];
        [scanRangeButton setState:(v ? NSOnState : NSOffState)]; 
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:v] 
                                             forKey:@"scanRange"];

    [self scan:nil];
}

#pragma mark Live image tab - updating of screen captures.

// Callback from the tab - we are switching between them tabs - and
// want to make sure we do not expensively update the screen view
// and (specifically) waste USB/serial bandwidth.
//
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    // Pause/restart live display following.
    //
    if ([tabView indexOfTabViewItem:tabViewItem] == 2) {
        if (playing)
            [rfExplorer playScreen];
    } else {
        [rfExplorer pauseScreen];
    };
    
    // Ensure drawer shows the right thing - acknowledging that
    // not all Tabs have their own drawer; so in those cases we
    // leave whatever was there.
    //    
    if ([tabView indexOfTabViewItem:tabViewItem] == 0) 
        self.drawerView.contentView = spectrumDrawerView;
    if ([tabView indexOfTabViewItem:tabViewItem] == 2) 
        self.drawerView.contentView = spectogramDrawerView;
}

-(IBAction)configScreenUpdating:(id)sender {
    if (playing) {
        [rfExplorer playScreen];        
        liveButton.title = @"pause display";
        [pausedLabel setHidden:TRUE];
        liveImageCell.alphaValue = 1.0;
    } else {
        [rfExplorer pauseScreen];
        liveButton.title = @"start live display";
        [pausedLabel setHidden:FALSE];
        liveImageCell.alphaValue = 0.3;
    };
}


-(IBAction)toggleLiveScreenUpdate:(id)sender {
    playing = !playing;
    [self configScreenUpdating:sender];
}

- (void) spectrumScrolledNotification: (NSNotification *) notification
{
    // make sure frequency legend follows the main display.
    [frequencyLegendView setNeedsDisplay:YES];
}

#pragma mark Updating form the RF Explorer

-(void)newScreen:(NSImage *)img {
    // Scale up the image - as to look somewhat pleasing.
    //
    [img setSize:liveImageCell.bounds.size];
    
    liveImageCell.image = img;
}

-(void)newData:(Spectrum *)_spectrum {
    spectrumView.spectrum = _spectrum;
    [spectrogramView addSpectrum:_spectrum];
}

-(void)newBoard:(RFExplorer *)explorer {
    firmwareLabel.stringValue = explorer.firmware;
    infoDevFirmware.stringValue = explorer.firmware;

    boardLabel.stringValue = explorer.mainBoard;    
    infoDevMain.stringValue = explorer.mainBoard;

    infoDevBaudrate.stringValue = explorer.commsSpeedAsString;
    
    infoDevExpansion.stringValue =explorer.expansionBoard ? explorer.expansionBoard : @"none";
    expansionLabel.stringValue = explorer.expansionBoard ? explorer.expansionBoard : @"";
}

-(void)newConfig:(RFExplorer *)explorer {
    [self setCenterFreqValue:[NSNumber numberWithFloat:explorer.fCenterMhz]];
    [self setFreqSpanValue:[NSNumber numberWithFloat:explorer.fSpanMhz]];
    [self setDbmBotValue:[NSNumber numberWithFloat:explorer.fAmplitudeBottom]];
    [self setDbmTopValue:[NSNumber numberWithFloat:explorer.fAmplitudeTop]];
    
    infoBandMinFreq.stringValue = [NSString stringFromMhz:explorer.fStartMhz];
    infoBandMaxFreq.stringValue = [NSString stringFromMhz:explorer.fEndMhz];
    infoBandCenterFreq.stringValue = [NSString stringFromMhz:explorer.fCenterMhz];
    infoBandSpanFreq.stringValue = [NSString stringFromMhz:explorer.fSpanMhz];

    infoAttenTop.stringValue = [NSString stringWithFormat:@"%.1f dBm", explorer.fAmplitudeTop];
    infoAttenBott.stringValue = [NSString stringWithFormat:@"%.1f dBm", explorer.fAmplitudeBottom];
    
    infoBoardMinFreq.stringValue = [NSString stringFromMhz:explorer.fMinFreqMhz];
    infoBoardMaxFreq.stringValue = [NSString stringFromMhz:explorer.fMaxFreqMhz];
    
    infoBoardTitle.stringValue = explorer.expansionBoardActive ? explorer.expansionBoard : explorer.mainBoard;

    // [spectrumView scrollRectToVisible:[spectrumView rectFoStartFreqMhz:explorer.fStartMhz]];

    [self setAllControls:TRUE];
    [spectrumView resetCalculations];
    
    [dbmLegendView setNeedsDisplay:TRUE];
    [spectrumView setNeedsDisplay:TRUE];
    [frequencyLegendView setNeedsDisplay:TRUE];
    
    [self updateTimers];
}

-(void)alertUser:(NSString *)userMsg {
   [NSAlert alertWithMessageText:userMsg 
                   defaultButton:@"OK" 
                 alternateButton:nil 
                     otherButton:nil 
       informativeTextWithFormat:@"RF Explorer failure: %@. " \
                "Check that you see the normal graph display " \
                "updating or try unplugging and reinserting " \
                "the device.", userMsg
    ];
}

#pragma mark Cleanup sundry

- (void)dealloc {
    [preferenceController release];
    [serialDeviceTracker release];
    [settingDeviceTitle release];
    [rfExplorer release];
    [scanTimer release];
    
    [super dealloc];
}

@end
