//
//  iRFExplorerAppDelegate.m
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

#import "iRFExplorerAppDelegate.h"
#import "LCDImage.h"
#import "RFExplorer.h"
#import "NSStringExtensions.h"
#import "Spectrum.h"

@implementation iRFExplorerAppDelegate

// window and general backgroud threads.
//
@synthesize window, mainView, drawerView;
@synthesize serialDeviceTracker;

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

// Drawer
//
@synthesize centerFreqSlider, centerFreqTextField;
@synthesize freqSpanSlider, freqSpanTextField;
@synthesize dbmTopTextField, dbmTopSlider;
@synthesize dbmBotTextField, dbmBotSlider;

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
    dbmLegendView.graphView = spectrumView;
    frequencyLegendView.graphView = spectrumView;
    
    // We always start with the drawer opened ? Or shall we keep state
    // in prefs ? Or nicer to open it when we have settings ?
    // [drawerView open:(self)];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{	
	return NSTerminateNow ;
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
    // close any old stuff
    [rfExplorer release];
    
    NSString * devPath = [serialDeviceTracker.devices objectForKey:settingDeviceTitle ];
    rfExplorer = [[RFExplorer alloc] initWithPath:devPath
                                  withSlowSetting:settingDeviceIsSlow];
    rfExplorer.delegate = self;
    spectrumView.device = rfExplorer;
    dbmLegendView.device = rfExplorer;
    frequencyLegendView.device = rfExplorer;
    
    deviceLabel.stringValue = rfExplorer ? settingDeviceTitle : @"<unset>";

    firmwareLabel.stringValue = rfExplorer ? @"Contacting..." : @"Comms failed";
        
    [self setAllControls:FALSE];
    
    [dbmLegendView setNeedsDisplay:TRUE];
    [frequencyLegendView setNeedsDisplay:TRUE];
    [self configScreenUpdating:self];
}

#pragma mark Callbacks form the Side config drawer

-(IBAction)showButtonChange:(NSButton *)sender  {
    
    if (sender == showMaxButton) {
        [spectrumView setAndResetShowMax:(sender.state == NSOnState)];
    } else
    if (sender == showAvgxButton) {
        [spectrumView setAndResetShowAvg:(sender.state == NSOnState)];
    } else
    if (sender == decayButton) {
        [spectrumView setAndResetDecay:(sender.state == NSOnState)];
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

#pragma mark Live image tab - updating of screen captures.

// Callback from the tab - we are switching between them tabs - and
// want to make sure we do not expensively update the screen view
// and (specifically) waste USB/serial bandwidth.
//
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([tabView indexOfTabViewItem:tabViewItem] == 0) {
        [rfExplorer pauseScreen];
    } else {
        if (playing)
            [rfExplorer playScreen];
    };
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
    [super dealloc];
}

@end
