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

// main view - bottom bar.
//
@synthesize boardLabel, expansionLabel;
@synthesize firmwareLabel;
// @synthesize deviceLabel;
// @synthesize boardSwitch;

// tab 1 spectrum
//
@synthesize spectrumGraphView;
@synthesize spectrumView;
@synthesize spectrumStopPauseView;

// tab 2 live view
//
@synthesize liveButton, liveImageCell, pausedLabel, screenTabView;

// Tab 3
@synthesize spectrogramView;     
@synthesize spectrogramGraphView;
@synthesize spectrogramStopPauseView;

// tab 4 - config
@synthesize configTabView;

// preference Panel
//
@synthesize settingDeviceTitle, settingDeviceIsSlow, serialDeviceTracker;

// Drawers
@synthesize spectogramDrawerView,spectrumDrawerView;


#pragma mark Startup and application level sundry.

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString * demoTitle = @"Demo (using a microphone)";

    serialDeviceTracker = [[SerialDeviceTracker alloc] init];
    serialDeviceTracker.delegate = self;
    
    // Detect the ALT key pressed - and activate demo mode
    // if so.
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    BOOL demoMode = (modifiers & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate;
    
    if (demoMode) {
        [serialDeviceTracker.devices setValue:kDemoAudio 
                                       forKey:demoTitle];
        self.settingDeviceTitle = demoTitle;
    }
    
    // we do this after the demo device creation - so that it is picked up without ado.
    //
    preferenceController = [[PreferenceController alloc] initWithWindowNibName:@"Preferences"];
    preferenceController.delegate = self;

#if 0
    // force to load - as we need it for pref. housekeeping.
    NSWindow * w;
    w = preferenceController.window;
    w = self.window;
    w = nil;    
#endif
    
    playing = FALSE;
    [self configScreenUpdating:self];

    // This will also trigger a callback telling me about
    // my current settings.
    //
    [preferenceController readPreferences];
    
    [self newScreen:[LCDImage imageWithReticule]];

    // We always start with the drawer opened ? Or shall we keep state
    // in prefs ? Or nicer to open it when we have settings ?
#if 0
    [drawerView open:(self)];
#endif
    
    // ensure drawer has the right content on startup - from hereon it is maintained
    // (even if closed) by the tab change callback. We need the sensible default
    // as the callback minimizes the changes for non drawer applicable tabs.
    //
    self.drawerView.contentView = spectrumDrawerView;
    [self tabView:mainView didSelectTabViewItem:mainView.selectedTabViewItem];    

    spectrumView.index = TAB_SPECTRUM;
    configTabView.index = TAB_CONFIG;
    screenTabView.index = TAB_SCREEN;
    spectrogramView.index = TAB_SPECTROGRAM;
    spectrogramGraphView.index = TAB_NONE;
    
}

// Simple way to get a but 
- (IBAction)showCustomAboutPanel:(id)sender
{
    NSString *appVersion = [NSString stringWithFormat:@"%@ - Revision:%@", 
                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], 
                            @REVISION];
    
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:appVersion, @"ApplicationVersion", nil];
        
    [NSApp orderFrontStandardAboutPanelWithOptions:optionsDictionary];
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [rfExplorer close];    
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{	
    [rfExplorer close];    
	return NSTerminateNow ;
}
    
+ (void)setupDefaults
{
    NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
    // NSDictionary *initialValuesDict;
    userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"defaults"
                                                           ofType:@"plist"];
    
    userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];

    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];    
    // [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValuesDict];
}

+(void)initialize {
    [iRFExplorerAppDelegate setupDefaults];
};

#pragma mark (Re)opening of main window.
// Mainly some trickery to avoid a real close; as to save us having to reload the NIB.
//
-(void)newDocument:(id)sender {
    [self.window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
	if( !flag )
		[self.window makeKeyAndOrderFront:nil];
	
	return YES;
}

- (BOOL)windowShouldClose:(id)sender
{
    if (sender == self.window) {
        [self.window orderOut:self];
        return NO;        
    }
    
    return YES;
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
    
    if (rfExplorer == nil && [title isEqualToString:@"SLAB_USBtoUART"]) {
        [preferenceController.deviceSelectionButton selectItemWithTitle:title];
        self.settingDeviceTitle = title;
        // give the device the time to power up - as otherwise we get cruft...
        [self performSelector:@selector(changedPreferences) withObject:nil afterDelay:2.0];
    }
}

-(void)setDecaySpeed:(float)decaySpeedInSeconds {
    spectrumGraphView.decayInSeconds = decaySpeedInSeconds;
}

-(void)setAvgSpeed:(float)avgSpeedInSeconds {
    spectrumGraphView.averagingTimeWindowInSeconds = avgSpeedInSeconds;
}

-(void)setScanStrategy:(NSUInteger)strategy withLinger:(double)lingerTimeInSeconds {
    // butt ugly. fixme.
    [spectogramDrawerView setLingerTimeInSeconds:lingerTimeInSeconds];
    [spectogramDrawerView setScanStrategy:(scan_strategy_t)strategy];

    [spectogramDrawerView updateTimers];
}

-(void)setAllControls:(BOOL)onOff {
    
    // second tab.
    liveButton.enabled = onOff;

    // 4th tab
    [configTabView setAllControls:onOff];
    
    // always do this - or only once during startup ?
    //
    if (onOff)
        [drawerView open:(self)];

    if(onOff)
        return;

    // Do we 'empty' the 4 slider fields ?
    
    boardLabel.stringValue = @"<none found>";    
    expansionLabel.stringValue = @"";

    [spectogramDrawerView setAllControls:onOff];
    [spectrumDrawerView setAllControls:onOff];    
}

// callback from the preference panel - either on initial init
// or as the user changes things.
//
-(void)changedPreferences {
    spectrogramView.device = nil;
    configTabView.device = nil;
    spectrumDrawerView.device = nil;
    spectogramDrawerView.device = nil;
    spectrumView.device = nil;
    
    [rfExplorer shutdown];
    [rfExplorer close];    
    [rfExplorer release];    
    rfExplorer = nil;
    
    NSString * devPath = [serialDeviceTracker.devices objectForKey:settingDeviceTitle ];
    if (devPath) {
        rfExplorer = [[RFExplorer alloc] initWithPath:devPath
                                      withSlowSetting:settingDeviceIsSlow
                                         withDelegate:self];
        if (!rfExplorer) {
            [NSAlert alertWithMessageText:@"Failed to connect to RF-Explorer"
                            defaultButton:nil 
                          alternateButton:nil 
                              otherButton:nil 
                informativeTextWithFormat:@"Did not manage to make a connection to the RF-Explorer device "
             "via the %@ serial port (%@): %s",
             settingDeviceTitle, devPath, strerror(errno)
             ];
        };
        // Hmm - we should go to messages :) and change the pattern.
        spectrogramView.device = rfExplorer;
        configTabView.device = rfExplorer;                
        spectrumDrawerView.device = rfExplorer;
        spectogramDrawerView.device = rfExplorer;
        spectrumView.device = rfExplorer;
    }
    
    // deviceLabel.stringValue = rfExplorer ? settingDeviceTitle : @"<unset>";

    firmwareLabel.stringValue = rfExplorer ? @"Contacting..." : 
        (devPath ? @"Comms failed" : @"");
        
    [self setAllControls:FALSE];
    [self configScreenUpdating:self];
}

-(IBAction)changeBoard:(id)sender {
#if 0 
    if (!rfExplorer.hasExpansionBoard)
        return;
    // not yet possible
    //    [rfExplorer setExpansionBoardActive:[boardSwitch selectedColumn] != 0];
#endif
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
    if ([tabView indexOfTabViewItem:tabViewItem] == TAB_SCREEN) {
        if (playing)
            [rfExplorer playScreen];
    } else {
        if (playing)
            [rfExplorer pauseScreen];
    };
    
    // Ensure drawer shows the right thing - acknowledging that
    // not all Tabs have their own drawer; so in those cases we
    // leave whatever was there.
    //    
    if ([tabView indexOfTabViewItem:tabViewItem] == TAB_SPECTRUM) 
        self.drawerView.contentView = spectrumDrawerView;

    if ([tabView indexOfTabViewItem:tabViewItem] == TAB_SPECTROGRAM) 
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

#pragma mark pause or play 

-(IBAction)togglePausePlay:(id)sender {
    switch ([mainView indexOfTabViewItem:mainView.selectedTabViewItem]) {
        case TAB_SPECTRUM:
            [spectrumStopPauseView toggle:self];
            break;
        case TAB_SCREEN:
            [self toggleLiveScreenUpdate:self];
            break;
        case TAB_SPECTROGRAM:
            [spectrogramStopPauseView toggle:self];
            break;
        default:
            // Indicate to the user that nothing has happened.
            NSBeep();
    };
}

#pragma mark cut/copy/paste pasteboard/pastebin handling

-(void)copy:(id)sender {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray array] owner:self];

    NSImage * img;
    SomeTabView * tabView = (SomeTabView *)mainView.selectedTabViewItem.view;
    
    switch ([mainView indexOfTabViewItem:mainView.selectedTabViewItem]) {
        case TAB_SCREEN:
            img = liveImageCell.image;

            if ([[[NSUserDefaults standardUserDefaults] valueForKey:kPreferencePngOverPdf] boolValue]) {
                NSBitmapImageRep * rep = [[img representations] objectAtIndex:0];
                [pasteBoard setData:[rep representationUsingType:NSPNGFileType 
                                                      properties:nil] 
                            forType:NSPasteboardTypePNG];
            } else {
                [pasteBoard addTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] 
                               owner:nil];
                [pasteBoard setData:[img TIFFRepresentation] forType:NSTIFFPboardType];
            }
            break;

        case TAB_SPECTRUM: 
        case TAB_SPECTROGRAM: 
        case TAB_CONFIG:
            [tabView addToPasteboard:pasteBoard];
            break;
        default: // and everything else.
            NSBeep();
            break;
    }
}

-(IBAction)print:(id)sender {
    NSLog(@"Yup - first responder responds");
    
    SomeTabView * tabView = (SomeTabView *)mainView.selectedTabViewItem.view;
    switch ([mainView indexOfTabViewItem:mainView.selectedTabViewItem]) {
        case TAB_SCREEN: 
            [liveImageCell print:sender];
            break;            
        case TAB_SPECTRUM:
        case TAB_SPECTROGRAM:
        case TAB_CONFIG:
            [tabView print:sender];
            break;
        default: // and everything else.
            break;
    }
}

#pragma mark Updating form the RF Explorer

-(void)newScreen:(NSImage *)img {
    
    // Scale up the image - as to look somewhat pleasing. But
    // keep the aspect ratio a wee bit sane.
    //
    double ratio = img.size.width / img.size.height;
    NSSize s = liveImageCell.bounds.size;
    
    if (s.width / s.height < ratio)
        s.width = ratio * s.height;
    else
        s.height = s.width / ratio;
            
    [img setSize:s];
    liveImageCell.image = img;
}

-(void)newData:(Spectrum *)_spectrum {
    if (![spectrumStopPauseView isPaused]) 
        spectrumGraphView.spectrum = _spectrum;
    
    if (![spectrogramStopPauseView isPaused]) 
        [spectrogramGraphView addSpectrum:_spectrum];
}

-(void)newBoard:(id)sender {
    assert(sender == rfExplorer);
    
    firmwareLabel.stringValue = rfExplorer.firmware;
    
    boardLabel.stringValue = rfExplorer.mainBoard;    

    if (rfExplorer.expansionBoard == nil) {
        expansionLabel.stringValue = @"not present";
        [expansionLabel setTextColor:[NSColor grayColor]];
    } else {
        expansionLabel.stringValue = rfExplorer.expansionBoard;
        [expansionLabel setTextColor:[NSColor blackColor]];
    };
    
    [spectrumDrawerView newBoard:self];
    [spectogramDrawerView newBoard:self];
    
    for(NSTabViewItem * t in mainView.tabViewItems) 
        [(SomeTabView *)t.view newBoard:self];
}

-(void)newConfig:(id)sender {
    assert(sender == rfExplorer);
    
    // If the device was in menu mode instead of measure mode 
    // then it may never yield us our board data C2-M - while
    // giving us the secondary config (C2-F). So in that case
    // we'll ask it again.
    //
    if (rfExplorer.mainBoard == nil) {
        [rfExplorer getConfigData];
    }

    [spectrumDrawerView newConfig:self];
    [spectogramDrawerView newConfig:self];

    for(NSTabViewItem * t in mainView.tabViewItems) 
        [(SomeTabView *)t.view newConfig:self];
    
    [self setAllControls:TRUE];
        
#if 0
    // firmware does not let us switc yet.
    //
    [[boardSwitch cellAtRow:0 column:0] setEnabled:NO];

    [[boardSwitch cellAtRow:0 column:0] setTitle:rfExplorer.mainBoard ? rfExplorer.mainBoard : @"<unknown>"];
    if (rfExplorer.hasExpansionBoard) {
        [[boardSwitch cellAtRow:0 column:1] setTitle:rfExplorer.expansionBoard ? rfExplorer.expansionBoard : @"<unknown>"];
        [[boardSwitch cellAtRow:0 column:1] setEnabled:NO];
    } else {
        // hiding it..
        [[boardSwitch cellAtRow:0 column:1] setTitle:@"<not present>"];        
        [[boardSwitch cellAtRow:0 column:1] setEnabled:NO];
    }
    [boardSwitch selectCellAtRow:0 column:rfExplorer.expansionBoardActive ? 1 : 0];
#endif
        
    [expansionLabel setBackgroundColor:rfExplorer.expansionBoardActive ? [NSColor selectedControlColor] : [NSColor lightGrayColor]];
    [boardLabel     setBackgroundColor:!rfExplorer.expansionBoardActive ? [NSColor selectedControlColor] : [NSColor lightGrayColor]];
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
    [configTabView release];

    [super dealloc];
}

@end
