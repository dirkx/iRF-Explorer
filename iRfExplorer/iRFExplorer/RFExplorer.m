//
//  RFConfiguration.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 12/10/2011.
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

@implementation RFExplorer
@synthesize parser;

@synthesize fStartMhz, fStepMhz,
    fAmplitudeSpan, 
    fAmplitudeMin, fAmplitudeMax, fAmplitudeMinSpan, fAmplitudeFullRange,
    nFreqSpectrumSteps, 
    fEndMhz, fMinSpanMhz,
    expansionBoardActive,
    fMinFreqMhz, fMaxFreqMhz, fMaxSpanMhz, fFullRangeMhz,
    mainBoard, expansionBoard, firmware, commsSpeed;

-(id)init {
    NSLog(@"Should not be used.");
    assert(1 == 2);
    return self;
}

-(id)initWithPath:(NSString *)devPath  withSlowSetting:(BOOL)deviceIsSlow {

    self = [super init];
    if (!self)
        return nil;

    assert(parser == nil);
    
    if ([devPath  hasPrefix:@"demo"]) {
        parser = [DemoRFExplorerCmds alloc];
    } else {
        parser = [RFExporerCmds alloc];
    };

    parser = [parser initWithPath:devPath withSlowSpeed:deviceIsSlow];
    
    if (parser == nil)
        return nil;
    
    commsSpeed = deviceIsSlow ? SPEED_2k4 : SPEED_500k;
    
    parser.delegate = self;

    return self;
}

-(id)delegate { 
    return delegate;
}

-(void)setDelegate:(id <RFGUICallbacks>) _delegate {
    if (_delegate != delegate) {
        [_delegate release];
        delegate = [_delegate retain];
    }    
    // fire off quite to fill out above if possible - but wait 300 mS.
    //
    [parser performSelector:@selector(getConfigData) 
                 withObject:nil 
                 afterDelay:0.300];   
}

-(void)configWithBoard:(NSString *)_mainBoard
         withExpansion:(NSString *)_expansionBoard
          withFirmware:(NSString *)_firmware 
{
    mainBoard = [_mainBoard retain];
    expansionBoard = [_expansionBoard retain];
    firmware = [_firmware retain];
    
    [delegate newBoard:self];
}

-(void)newData:(NSArray *)arr {
    Spectrum * s = [[Spectrum alloc] initWithStartFreqMhz:fStartMhz 
                                        withStepFreqMhz:fStepMhz 
                                               withData:arr];
    [delegate newData:s];
    
    [s release];
}

-(void)newScreen:(NSImage *)img {
    [delegate newScreen:img];
}

-(void)configWithStartMhz:(float)_fStartMhz
              withStepMhz:(float)_fStepMhz
         withAmplitudeTop:(NSInteger)_fAmplitudeTop
      withAmplitudeBottom:(NSInteger)_fAmplitudeBottom
                withSteps:(NSUInteger)_nFreqSpectrumSteps
 withExpansionBoardActive:(BOOL)_bExpansionBoardActive
                  witMode:(RF_mode_t)_eMode
              withMinFreq:(float)_fMinFreqMhz
              withMaxFreq:(float)_fMaxFreqMhz
             withSpanFreq:(float)_fSpanFreqMhz
{
    fStartMhz = _fStartMhz;
    fStepMhz = _fStepMhz;
    
    fAmplitudeTop = _fAmplitudeTop ;
    fAmplitudeBottom = _fAmplitudeBottom;
    fAmplitudeSpan = _fAmplitudeTop - _fAmplitudeBottom;
    
    fAmplitudeMin = -120;  
    fAmplitudeMax = -1;
    fAmplitudeMinSpan = 10;
    fAmplitudeFullRange = fAmplitudeMax - fAmplitudeMin;
    
    nFreqSpectrumSteps = _nFreqSpectrumSteps;
    
    fMinFreqMhz = _fMinFreqMhz;
    fMaxFreqMhz = _fMaxFreqMhz;
    fMaxSpanMhz = _fSpanFreqMhz;
    fMinSpanMhz = _bExpansionBoardActive == EXPANSION_2G4 ? 2000.0f : 0.112f;
    fFullRangeMhz = _fMaxFreqMhz - _fMinFreqMhz;
    
    fSpanMhz = fStepMhz * nFreqSpectrumSteps;
    fEndMhz = fStartMhz + fSpanMhz;
    fCenterMhz = fStartMhz + fSpanMhz / 2;
    
    expansionBoardActive = _bExpansionBoardActive;
    [delegate newConfig:self];
}

-(void)setFCenterMhz:(float)_fCenterMhz {
    float fDesiredStart = _fCenterMhz - fSpanMhz / 2;
    float fDesiredEnd =  _fCenterMhz + fSpanMhz / 2;
    
    if (fDesiredEnd > fMaxFreqMhz - fSpanMhz / 2) {
        fDesiredEnd = fMaxFreqMhz - fSpanMhz / 2;
        fDesiredStart = fDesiredEnd - fSpanMhz;
    };
    if (fDesiredStart < fMinFreqMhz + fSpanMhz / 2) {
        fDesiredStart = fMinFreqMhz + fSpanMhz / 2;
        fDesiredEnd = fDesiredStart + fSpanMhz;
    };
    
    [parser sendCurrentConfigWithStartFreq:fDesiredStart
                               withEndFreq:fDesiredEnd
                                withAmpTop:fAmplitudeTop
                             withAmpBottom:fAmplitudeBottom];
    
    // we do not update CenterMhz right away - but wait for
    // above command to take hold and sent us back the actual
    // settings the device has taken - and use those.
}

-(float)fCenterMhz { 
    return fCenterMhz; 
}

-(void)setFSpanMhz:(float)_fDesiredSpanMhz {
    
    if (fStartMhz + _fDesiredSpanMhz > fMaxFreqMhz) {
        fStartMhz = fMaxFreqMhz - _fDesiredSpanMhz;
    }
    if (fStartMhz < fMinFreqMhz) {
        fStartMhz = fMinFreqMhz;
    }
    [parser sendCurrentConfigWithStartFreq:fStartMhz
                               withEndFreq:fStartMhz + _fDesiredSpanMhz
                                withAmpTop:fAmplitudeTop
                             withAmpBottom:fAmplitudeBottom];    
}

-(float)fSpanMhz {
    return fSpanMhz;
}

-(void)setFAmplitudeBottom:(float)bot {
    float top = fAmplitudeMax;
    
    if (bot > top)
        top = bot + fAmplitudeSpan;
    
    if (top > fAmplitudeMax)
        top = fAmplitudeMax;
    
    if (bot + fAmplitudeMinSpan > top)
        bot = top -fAmplitudeMinSpan;
    
    [parser sendCurrentConfigWithStartFreq:fStartMhz
                               withEndFreq:fStartMhz + fSpanMhz 
                                withAmpTop:top
                             withAmpBottom:bot];       
}

-(float)fAmplitudeBottom {
    return fAmplitudeBottom;
}

-(void)setFAmplitudeTop:(float)top {
    float bot = fAmplitudeBottom;
    
    if (top < bot) 
        bot = top - fAmplitudeSpan;
    
    if (bot < fAmplitudeMin)
        bot = fAmplitudeMin;
    
    if (top < bot + fAmplitudeMinSpan)
        top = bot + fAmplitudeMinSpan;
    
    [parser sendCurrentConfigWithStartFreq:fStartMhz
                               withEndFreq:fStartMhz + fSpanMhz 
                                withAmpTop:top
                             withAmpBottom:bot];       
}

-(float)fAmplitudeTop {
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
    NSLog(@"%@ dealloc",self.className);

    [parser halt];
    
    // Something over releases/has already released the parser. XXX Bug !
    // see note in dealloc of RFExporerCmds. Not understanding this.
    //
    // [parser release];
    
    [mainBoard release];
    [expansionBoard release];
    [firmware release];
    
    [super dealloc];
}
@end
