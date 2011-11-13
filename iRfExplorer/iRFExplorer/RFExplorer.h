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

NSString const *kDemoPrefix;
NSString const *kDemoAudio;

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
    NSString *path;
    
    // General data and state
    NSString * mainBoard, *expansionBoard, *firmware;

    // viewport ranges - Horizontal and vertial
    double fStartHz, fStepHz;
    double fAmplitudeTop, fAmplitudeBottom, fAmplitudeSpan;

    // Number of bands
    unsigned long nFreqSpectrumSteps;
    
    // derived viewport info
    double fSpanHz, fEndHz, fCenterHz;
    
    BOOL expansionBoardActive;
    RF_model_t mainBoardModel;
    RF_model_t expansionModel;
    RF_model_t activeBoardModel;

    RF_speed_t commsSpeed;
    
    NSDate* connectedTime, *configTime, *spectrumTime;
    
    // hardware range
    double fMinFreqHz, fMaxFreqHz, fMaxSpanHz, fMinSpanHz, fFullRangeHz;
    double fAmplitudeMin, fAmplitudeMax, fAmplitudeMinSpan, fAmplitudeFullRange;    
}

@property (assign) id <RFGUICallbacks> delegate;
@property (retain) RFExporerCmds * parser;

@property (assign) double fCenterHz, fSpanHz;
@property (assign) double fAmplitudeTop, fAmplitudeBottom;

@property (assign, readonly) double fAmplitudeSpan;
@property (assign, readonly) double fStartHz, fStepHz;
@property (assign, readonly) unsigned long nFreqSpectrumSteps;
@property (assign, readonly) double fMinFreqHz, fMaxFreqHz, fMaxSpanHz, fFullRangeHz;
@property (assign, readonly) double fEndHz, fMinSpanHz;
@property (assign, readonly) NSString * mainBoard, *expansionBoard, *firmware, *path;
@property (assign, readonly) double fAmplitudeMin, fAmplitudeMax, fAmplitudeMinSpan, fAmplitudeFullRange;
@property (assign) BOOL expansionBoardActive;
@property (assign, readonly) RF_speed_t commsSpeed;
@property (retain, readonly) NSString * commsSpeedAsString;
@property (retain, readonly) NSString * activeBoard;
@property (assign, readonly) RF_model_t activeModel;
@property (assign, readonly) BOOL hasExpansionBoard;
@property (assign, readonly) BOOL hasC2M;
@property (assign, readonly) BOOL hasC2F;

@property (retain) NSDate * connectedTime, *configTime, *spectrumTime;

-(id)initWithPath:(NSString *)devPath withSlowSetting:(BOOL)deviceIsSlow withDelegate:(id <RFGUICallbacks>)aDelegate;
-(void)close;

-(void)setAmpRangeFrom:(double)bottom to:(double)top;
-(void)setFreqRangeFrom:(double)lowest to:(double)highest;

-(void)getConfigData;
-(void)pauseScreen;
-(void)playScreen;
-(void)pauseSpectrum;
-(void)playSpectrum;
-(void)shutdown;
@end
