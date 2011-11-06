//
//  Spectrum.h
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
#include <Foundation/Foundation.h>

@interface Spectrum : NSObject {
    NSArray *dbValues;
    NSArray *frequenciesHz;

    float startFreqHz;
    float endFreqHz;
    float stepFreqHz;
    
    float minDbm;
    float maxDbm;
}

@property (retain, readonly) NSArray *dbValues, *frequenciesHz;

@property (assign, readonly) float startFreqHz, endFreqHz, stepFreqHz;
@property (assign, readonly) float minDbm, maxDbm;
@property (assign, readonly) NSUInteger count;

- (id)initWithStartFreqHz:(float)_startFreqHz
         withStepFreqHz:(float)_stepFreqHz
                withData:(NSArray *)vals;

-(NSString *)tsvDescription;
-(void)addToPasteboard:(NSPasteboard *)pasteBoard;
@end
