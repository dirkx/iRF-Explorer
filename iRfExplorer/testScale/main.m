//
//  main.m
//  testScale
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

#import <Foundation/Foundation.h>

#import "NumericScaleDefinition.h"
#import "StringScaleDefinition.h"
#import "TickScaler.h"

int main (int argc, const char * argv[])
{
    float max =   -8;
    float min = -18;

    // CFRelease(nil);
    // CFRelease(NULL);

    if (argc != 1 && argc != 3) {
        fprintf(stderr,"Syntax: %s [min max]\n", argv[0]);
        return -1;
    };
    
    if (argc == 3) {
        min = atof(argv[1]);
        max = atof(argv[2]);
    };
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NumericScaleDefinition * ns = [TickScaler calculateIdealScaleFromMin:min 
                                                                 withMax:max
                                   ];
	
    StringScaleDefinition * scale = [[StringScaleDefinition alloc] initWithNumericScaleDefinition:ns 
                                                              withDataMin:min
                                                              withDataMax:max
                                                                 withUnit:@"dBm"];

    NSLog(@"Got %@", scale.ticks);
    
    [scale release];
    
    [pool drain];
    return 0;
}

