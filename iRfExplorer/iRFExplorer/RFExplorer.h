//
//  RFConfiguration.h
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

#import <Foundation/Foundation.h>
#import "RFExporerCmds.h"
#import "Spectrum.h"

@protocol RFGUICallbacks <NSObject>;
-(void)newData:(Spectrum *)spectrum;     
-(void)newScreen:(NSImage *)img;
-(void)newBoard:(id)explorer;
-(void)newConfig:(id)exporer;
-(void)alertUser:(NSString *)userMsg;
@end

@interface RFExplorer: NSObject <RFCallbacks> {
    RFExporerCmds * parser;
    id <RFGUICallbacks> delegate;

    // General data and state
    NSString * mainBoard, *expansionBoard, *firmware;

    // viewport range
    float fStartMhz, fStepMhz;

    float fAmplitudeTop, fAmplitudeBottom, fAmplitudeSpan;
    
    unsigned long nFreqSpectrumSteps;
    // derived viewport info
    float fSpanMhz, fEndMhz, fCenterMhz;
    
    BOOL expansionBoardActive;
    RF_speed_t commsSpeed;
    
    // hardware range
    float fMinFreqMhz, fMaxFreqMhz, fMaxSpanMhz, fMinSpanMhz, fFullRangeMhz;
    float fAmplitudeMin, fAmplitudeMax, fAmplitudeMinSpan, fAmplitudeFullRange;
}

@property (assign) id <RFGUICallbacks> delegate;
@property (retain) RFExporerCmds * parser;

@property (assign) float fCenterMhz, fSpanMhz;
@property (assign) float fAmplitudeTop, fAmplitudeBottom;

@property (assign, readonly) float fAmplitudeSpan;
@property (assign, readonly) float fStartMhz, fStepMhz;
@property (assign, readonly) unsigned long nFreqSpectrumSteps;
@property (assign, readonly) float fMinFreqMhz, fMaxFreqMhz, fMaxSpanMhz, fFullRangeMhz;
@property (assign, readonly) float fEndMhz, fMinSpanMhz;
@property (assign, readonly) NSString * mainBoard, *expansionBoard, *firmware;
@property (assign, readonly) float fAmplitudeMin, fAmplitudeMax, fAmplitudeMinSpan, fAmplitudeFullRange;
@property (assign, readonly) BOOL expansionBoardActive;
@property (assign, readonly) RF_speed_t commsSpeed;
@property (assign, readonly) NSString * commsSpeedAsString;

-(id)initWithPath:(NSString *)devPath  withSlowSetting:(BOOL)deviceIsSlow;

-(void)pauseScreen;
-(void)playScreen;
-(void)pauseSpectrum;
-(void)playSpectrum;
@end
