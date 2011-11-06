//
//  RFConfiguration.m
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

#import "RFExplorer.h"
#import "DemoRFExplorerCmds.h"

#import "Spectrum.h"
NSString const *kDemoPrefix = @"demo";
NSString const *kDemoAudio = @"demo1";

@implementation RFExplorer
@synthesize parser;

@synthesize path,
    fStartHz, fStepHz,
    fAmplitudeSpan, 
    fAmplitudeMin, fAmplitudeMax, fAmplitudeMinSpan, fAmplitudeFullRange,
    nFreqSpectrumSteps, 
    fEndHz, fMinSpanHz,
    fMinFreqHz, fMaxFreqHz, fMaxSpanHz, fFullRangeHz,
    mainBoard, expansionBoard, firmware, commsSpeed,
    connectedTime, configTime, spectrumTime;

-(id)init {
    NSLog(@"Should not be used.");
    assert(1 == 2);
    return self;
}

-(id)initWithPath:(NSString *)devPath withSlowSetting:(BOOL)deviceIsSlow withDelegate:(id <RFGUICallbacks>)myDelegate {

    self = [super init];
    if (!self)
        return nil;

    path = [devPath retain];
    
    if ([devPath  hasPrefix:(NSString *)kDemoPrefix]) {
        parser = [[DemoRFExplorerCmds alloc] initWithPath:devPath withSlowSpeed:deviceIsSlow];
    } else {
        parser = [[RFExporerCmds alloc] initWithPath:devPath withSlowSpeed:deviceIsSlow];
    };

    self.delegate = myDelegate;    
    
    if (parser == nil) {
        self.delegate = nil;
        return nil;
    };
    
    commsSpeed = deviceIsSlow ? SPEED_2k4 : SPEED_500k;
    
    parser.delegate = self;

    self.connectedTime = [NSDate date];
    return self;
}

-(void)shutdown {
    [parser shutdown];
}

-(void)close {
    [parser close];
}

-(id)delegate { 
    return delegate;
}

-(void)getConfigData {
    [parser getConfigData];
}

-(BOOL) hasC2M {
    return mainBoard != nil;
}

-(BOOL) hasC2F {
    return nFreqSpectrumSteps > 0;
}

-(void)setDelegate:(id <RFGUICallbacks>) _delegate {
    if (_delegate != delegate) {
        [_delegate release];
        delegate = [_delegate retain];
    }    
    // fire off quite to fill out above if possible - but wait 300 mS.
    //
    [self performSelector:@selector(getConfigData) 
                 withObject:nil 
                 afterDelay:0.300];   
}


-(NSString *)numToBoard:(RF_model_t)board {
    switch (board) {
        case EXPANSION_433M: 
            return @"443M"; 
            break;
        case EXPANSION_868M: 
            return @"868M"; 
            break;
        case EXPANSION_915M: 
            return @"915M"; 
            break;
        case EXPANSION_WSUB1G: 
            return @"WSUB1GM"; 
            break;
        case EXPANSION_2G4: 
            return @"2.4GM"; 
            break;
        case EXPANSION_DEMO:
            return @"Emulator";
            break;
        case 255: 
            return nil; 
            break;
    }
    return @"Unkown";
}

-(void)configWithBoard:(RF_model_t)_mainBoard
         withExpansion:(RF_model_t)_expansionBoard
          withFirmware:(NSString *)_firmware 
{
    mainBoardModel = _mainBoard;
    expansionModel = _expansionBoard;
    
    mainBoard = [[self numToBoard:mainBoardModel] retain];
    expansionBoard =[[self numToBoard:expansionModel] retain];
                     
    firmware = [_firmware retain];

    [delegate newBoard:self];
}

-(void)newData:(NSArray *)arr {
    Spectrum * s = [[Spectrum alloc] initWithStartFreqHz:fStartHz 
                                        withStepFreqHz:fStepHz 
                                               withData:arr];
    [delegate newData:s];
    self.spectrumTime = [NSDate date];
    
    [s release];
}

-(void)newScreen:(NSImage *)img {
    [delegate newScreen:img];
}

-(void)configWithStartHz:(double)_fStartHz
              withStepHz:(double)_fStepHz
         withAmplitudeTop:(NSInteger)_fAmplitudeTop
      withAmplitudeBottom:(NSInteger)_fAmplitudeBottom
                withSteps:(NSUInteger)_nFreqSpectrumSteps
 withExpansionBoardActive:(BOOL)_bExpansionBoardActive
                  witMode:(RF_mode_t)_eMode
              withMinFreq:(double)_fMinFreqHz
              withMaxFreq:(double)_fMaxFreqHz
             withSpanFreq:(double)_fSpanFreqHz
{
    fStartHz = _fStartHz;
    fStepHz = _fStepHz;
    
    fAmplitudeTop = _fAmplitudeTop ;
    fAmplitudeBottom = _fAmplitudeBottom;
    fAmplitudeSpan = _fAmplitudeTop - _fAmplitudeBottom;
    
    fAmplitudeMin = -120;  
    fAmplitudeMax = -1;
    fAmplitudeMinSpan = 10;
    fAmplitudeFullRange = fAmplitudeMax - fAmplitudeMin;
    
    nFreqSpectrumSteps = _nFreqSpectrumSteps;
    
    fMinFreqHz = _fMinFreqHz;
    fMaxFreqHz = _fMaxFreqHz;
    fMaxSpanHz = _fSpanFreqHz;
    switch ([self activeModel]) {
        case EXPANSION_2G4:    
            fMinSpanHz = 2e6f;
            break;
        case EXPANSION_DEMO:
            fMinSpanHz = 250.0;
            break;
        default:
           fMinSpanHz = 1.12e5f; // 2MHz, 112kHz - see spec link above.
            break;
    }
    fFullRangeHz = _fMaxFreqHz - _fMinFreqHz;
    
    fSpanHz = fStepHz * nFreqSpectrumSteps;
    fEndHz = fStartHz + fSpanHz;
    fCenterHz = fStartHz + fSpanHz / 2;
    
    expansionBoardActive = _bExpansionBoardActive;

    self.configTime = [NSDate date];

    [delegate newConfig:self];
}

-(void)setExpansionBoardActive:(BOOL)newState {
//    [parser sendBoardConfig:newState];
}

-(BOOL)expansionBoardActive {
    return expansionBoardActive;
}

-(RF_model_t) activeModel {
    if (!self.hasC2M || !self.hasC2F)
        return 255;
    
    return expansionBoardActive ? expansionModel : mainBoardModel;
}

-(NSString *) activeBoard {
    if (!self.hasC2M || !self.hasC2F)
        return @"unknown";
    
    return expansionBoardActive ? expansionBoard : mainBoard;
}

-(BOOL) hasExpansionBoard {
    return expansionBoard != nil;
}

#pragma mark Control functions

// we do not update CenterHz et.al. right away - but wait for
// above command to take hold and sent us back the actual
// settings the device has taken - and use those. In fact
// none of those updates anything. So we always return the
// actual config.

-(void)setAmpRangeFrom:(double)bottom to:(double)top {
    if (top > fAmplitudeMax)
        top = fAmplitudeMax;
    if (bottom < fAmplitudeMin)
        bottom = fAmplitudeMin;
    
    [parser sendCurrentConfigWithStartFreq:fStartHz
                               withEndFreq:fEndHz
                                withAmpTop:top
                             withAmpBottom:bottom];    
}

-(void)setFreqRangeFrom:(double)bottom to:(double)top {
    if (bottom < fMinFreqHz)
        bottom = fMinFreqHz;
    if (top > fMaxFreqHz)
        top = fMaxFreqHz;
    [parser sendCurrentConfigWithStartFreq:bottom
                               withEndFreq:top
                                withAmpTop:fAmplitudeTop
                             withAmpBottom:fAmplitudeBottom];

}

-(void)setFCenterHz:(double)_fCenterHz {
    double fDesiredStart = _fCenterHz - fSpanHz / 2;
    double fDesiredEnd =  _fCenterHz + fSpanHz / 2;
    
    if (fDesiredEnd > fMaxFreqHz) {
        fDesiredEnd = fMaxFreqHz;
        fDesiredStart = fDesiredEnd - fSpanHz;
    };
    
    if (fDesiredStart < fMinFreqHz) {
        fDesiredStart = fMinFreqHz;
        fDesiredEnd = fDesiredStart + fSpanHz;
    };
    
    [parser sendCurrentConfigWithStartFreq:fDesiredStart
                               withEndFreq:fDesiredEnd
                                withAmpTop:fAmplitudeTop
                             withAmpBottom:fAmplitudeBottom];
    
}

-(double)fCenterHz { 
    return fCenterHz; 
}

-(void)setFSpanHz:(double)_fDesiredSpanHz {
    
    if (fStartHz + _fDesiredSpanHz > fMaxFreqHz) {
        fStartHz = fMaxFreqHz - _fDesiredSpanHz;
    }
    if (fStartHz < fMinFreqHz) {
        fStartHz = fMinFreqHz;
    }
    [parser sendCurrentConfigWithStartFreq:fStartHz
                               withEndFreq:fStartHz + _fDesiredSpanHz
                                withAmpTop:fAmplitudeTop
                             withAmpBottom:fAmplitudeBottom];    
}

-(double)fSpanHz {
    return fSpanHz;
}

-(void)setFAmplitudeBottom:(double)bot {
    double top = fAmplitudeMax;
    
    if (bot > top)
        top = bot + fAmplitudeSpan;
    
    if (top > fAmplitudeMax)
        top = fAmplitudeMax;
    
    if (bot + fAmplitudeMinSpan > top)
        bot = top -fAmplitudeMinSpan;
    
    [parser sendCurrentConfigWithStartFreq:fStartHz
                               withEndFreq:fStartHz + fSpanHz 
                                withAmpTop:top
                             withAmpBottom:bot];       
}

-(double)fAmplitudeBottom {
    return fAmplitudeBottom;
}

-(void)setFAmplitudeTop:(double)top {
    double bot = fAmplitudeBottom;
    
    if (top < bot) 
        bot = top - fAmplitudeSpan;
    
    if (bot < fAmplitudeMin)
        bot = fAmplitudeMin;
    
    if (top < bot + fAmplitudeMinSpan)
        top = bot + fAmplitudeMinSpan;
    
    [parser sendCurrentConfigWithStartFreq:fStartHz
                               withEndFreq:fStartHz + fSpanHz 
                                withAmpTop:top
                             withAmpBottom:bot];       
}

-(double)fAmplitudeTop {
    return fAmplitudeTop;
}

-(void)pauseScreen {
    [parser pauseScreen];
}

-(void)playScreen {
    [parser playScreen];
}

-(void)pauseSpectrum {
    [parser pauseSpectrum];
}
-(void)playSpectrum {
    [parser playSpectrum];
}

-(void)alertUser:(NSString *)userMsg {
    [delegate alertUser:userMsg];
}

-(NSString *)commsSpeedAsString {
    switch (commsSpeed) {
        case SPEED_1k2:
            return @"1200 bps";
            break;
        case SPEED_2k4:
            return @"2400 bps";
            break;
        case SPEED_4k8:
            return @"4800 bps";
            break;
        case SPEED_9k6:
            return @"9600 bps";
            break;
        case SPEED_19k2:
            return @"19.2 kbps";
            break;
        case SPEED_38k4:
            return @"38.4 kbps";
            break;
        case SPEED_57k6:
            return @"56.6 kbps";
            break;
        case SPEED_115k:
            return @"115 kbps";
            break;
        case SPEED_500k:
            return @"500 kbps";
            break;
        default:
            return @"<unknown>";
    };    
}

-(void)dealloc {
    [parser close];
    
    // Leak - but if we fix it - we crash...
    [parser release];
    
    [mainBoard release];
    [expansionBoard release];
    [firmware release];
    [path release];

    self.connectedTime = nil;
    self.configTime = nil;
    self.spectrumTime = nil;

    [super dealloc];
}
@end
