//
//  SiPrefixes.m
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

#import "SiPrefixes.h"
#import "ScalerDefinition.h"

@implementation SiPrefixes
+(NSArray *)defs {
    return [NSArray arrayWithObjects:
            [[[ScalerDefinition alloc] initWithPrefix:@"p" withMultiplier:1e-12 withAliases:[NSArray arrayWithObjects:@"pico", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"n" withMultiplier: 1e-9 withAliases:[NSArray arrayWithObjects:@"nano", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"µ" withMultiplier: 1e-6 withAliases:[NSArray arrayWithObjects:@"micro", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"m" withMultiplier: 1e-3 withAliases:[NSArray arrayWithObjects:@"milli", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@""  withMultiplier: 1    withAliases:[NSArray arrayWithObjects:nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"K" withMultiplier: 1e3  withAliases:[NSArray arrayWithObjects:@"kilo", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"M" withMultiplier: 1e6  withAliases:[NSArray arrayWithObjects:@"mega", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"G" withMultiplier: 1e9  withAliases:[NSArray arrayWithObjects:@"giga", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"T" withMultiplier:1e12  withAliases:[NSArray arrayWithObjects:@"terra", nil]] autorelease],
            nil];
}
@end