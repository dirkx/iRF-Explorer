//
//  RFExporerCmds.h
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
#include <termios.h>

typedef enum {
    EXPANSION_433M = 0,
    EXPANSION_868M,
    EXPANSION_915M,
    EXPANSION_WSUB1G,
    EXPANSION_2G4,
    EXPANSION_DEMO=254,
    EXPANSION_NONE=255  // only valid for the expansion card - always a main board.
} RF_model_t;

typedef enum {
    MODE_SPECTRUM_ANALYZER = 0,
    MODE_RF_GENERATOR = 1,
    MODE_WIFI_ANALYZER = 2,
    MODE_UNKNOWN = 255
} RF_mode_t;

typedef enum {
    SPEED_1k2 = 1,
    SPEED_2k4,
    SPEED_4k8,
    SPEED_9k6,
    SPEED_19k2,
    SPEED_38k4,
    SPEED_57k6,
    SPEED_115k,
    SPEED_500k = 0  // rather odd number - no proper B#### in serial.h
} RF_speed_t;

@protocol RFCallbacks <NSObject>;

@optional
-(void)configWithBoard:(RF_model_t)mainBoard
         withExpansion:(RF_model_t)expansionBoard
          withFirmware:(NSString *)firmware;
-(void)newData:(NSArray *)arr;     
-(void)newScreen:(NSImage *)img;
-(void)configWithStartHz:(double)fStartHz
              withStepHz:(double)fStepHz
         withAmplitudeTop:(NSInteger)fAmplitudeTop
      withAmplitudeBottom:(NSInteger)fAmplitudeBottom
                withSteps:(NSUInteger)nFreqSpectrumSteps
 withExpansionBoardActive:(BOOL)bExpansionBoardActive
                  witMode:(RF_mode_t)eMode
              withMinFreq:(double)fMinFreqHz
              withMaxFreq:(double)fMaxFreqHz
             withSpanFreq:(double)fSpanFreqHz;
-(void)alertUser:(NSString *)userMsg;
@end

@interface RFExporerCmds : NSObject // NSThtread 
{
    id <RFCallbacks> delegate;
    NSString * path;
    BOOL isSlow;
    int fd;
    NSUInteger unkPktTypeCount;

    NSTimer * timeoutTimer;
    NSUInteger timeoutMask;
    
    BOOL debugRH;
    BOOL logRH;
    BOOL cmdRH;
}

@property (assign) id <RFCallbacks> delegate;

- (id)initWithPath:(NSString *)path withSlowSpeed:(BOOL)isSlow;

-(void) sendCurrentConfigWithStartFreq:(double)fStartHz
                           withEndFreq:(double)fEndHz
                            withAmpTop:(double)fAmplitudeTop
                         withAmpBottom:(double)fAmplitudeBottom;
-(BOOL)sendCmd:(NSString *)cmd;
-(void)getConfigData;
-(void)pauseScreen;
-(void)playScreen;
-(void)pauseSpectrum;
-(void)playSpectrum;
-(void)shutdown;

-(void)close;

// really private - but we expose it so that our Demo RF Explorer can use it.
//
-(void)submit:(const char *)buff withLength:(ssize_t)len;
@end
