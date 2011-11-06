//
//  Spectrum.m
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

#import "Spectrum.h"

@implementation Spectrum
@synthesize startFreqHz, endFreqHz, stepFreqHz;
@synthesize dbValues, frequenciesHz;
@synthesize minDbm,maxDbm;

- (id)initWithStartFreqHz:(float)_startFreqHz
         withStepFreqHz:(float)_stepFreqHz
                withData:(NSArray *)vals
{
    self = [super init];
    if (!self) 
        return nil;

    startFreqHz = _startFreqHz;
    stepFreqHz = _stepFreqHz;
    endFreqHz = startFreqHz + stepFreqHz * [vals count];
    
    dbValues = [[NSArray arrayWithArray:vals] retain];
    
    NSMutableArray * f = [NSMutableArray arrayWithCapacity:[vals count]];
    
    minDbm = maxDbm = [[vals objectAtIndex:0] floatValue];
    for(int i = 0; i < [vals count]; i++) {
        float v = [[vals objectAtIndex:i] floatValue];
        if (v < minDbm)
            minDbm = v;
        if (v > maxDbm)
            maxDbm = v;        

        [f addObject:[NSNumber numberWithFloat:startFreqHz + i * stepFreqHz]];
    };
    
    frequenciesHz = [[NSArray arrayWithArray:f] retain];
    
    return self;
}

-(NSUInteger) count {
    return [dbValues count];
}

-(void)addToPasteboard:(NSPasteboard *)pasteBoard {
    [pasteBoard addTypes:[NSArray arrayWithObjects:NSPasteboardTypeTabularText,nil] 
                   owner:self];
    
    [pasteBoard writeObjects:[NSArray arrayWithObjects:[self tsvDescription], nil]];   
}

-(NSString *)tsvDescription {
    NSMutableString * tsv = [NSMutableString string];
    [tsv appendFormat:@"Frequency(mHZ)\tSignal (dBm)\n"];
    
    for(NSUInteger i = 0; i < [self count]; i++) {
        [tsv appendFormat:@"%f\t%f\n", 
         [((NSNumber *)[frequenciesHz objectAtIndex:i]) doubleValue],
         [((NSNumber *)[dbValues objectAtIndex:i]) doubleValue]];
    }

    // Should we include a footer or header with some of the
    // most salient details (date of capture, device, main settings ?) 
    return tsv;
}

-(void)dealloc {
    [frequenciesHz release];
    [dbValues release];
    [super dealloc];
}
@end
