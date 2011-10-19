//
//  Spectrum.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 14/10/2011.
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

#import "Spectrum.h"

@implementation Spectrum
@synthesize startFreqMhz, endFreqMhz, stepFreqMhz;
@synthesize dbValues, frequenciesMhz;
@synthesize minDbm,maxDbm;

- (id)initWithStartFreqMhz:(float)_startFreqMhz
         withStepFreqMhz:(float)_stepFreqMhz
                withData:(NSArray *)vals
{
    self = [super init];
    if (!self) 
        return nil;

    startFreqMhz = _startFreqMhz;
    stepFreqMhz = _stepFreqMhz;
    endFreqMhz = startFreqMhz + stepFreqMhz * [vals count];
    
    dbValues = [[NSArray arrayWithArray:vals] retain];
    
    NSMutableArray * f = [NSMutableArray arrayWithCapacity:[vals count]];
    
    minDbm = maxDbm = [[vals objectAtIndex:0] floatValue];
    for(int i = 0; i < [vals count]; i++) {
        float v = [[vals objectAtIndex:i] floatValue];
        if (v < minDbm)
            minDbm = v;
        if (v > maxDbm)
            maxDbm = v;        
        [f addObject:[NSNumber numberWithFloat:startFreqMhz + i * stepFreqMhz]];
    };
    
    frequenciesMhz = [[NSArray arrayWithArray:f] retain];
    
    return self;
}

-(NSUInteger) count {
    return [dbValues count];
}

-(void)dealloc {
    [frequenciesMhz release];
    [dbValues release];
    [super dealloc];
}
@end
