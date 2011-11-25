//
//  TimePeriodPrefixes.m
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

#import "TimePeriodPrefixes.h"
#import "ScalerDefinition.h"

@implementation TimePeriodPrefixes 
+(NSArray *)defs {
    return [NSArray arrayWithObjects:
            [[[ScalerDefinition alloc] initWithPrefix:@"µs"   withMultiplier: 1e-6    withAliases:[NSArray arrayWithObjects:@"micro", @"microseconds", @"microsec", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"ms"   withMultiplier: 1e-3    withAliases:[NSArray arrayWithObjects:@"milli", @"milliseconds", @"millisec", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"sec"  withMultiplier: 1       withAliases:[NSArray arrayWithObjects:@"secs",  @"second",       @"seconds", @"s", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"min"  withMultiplier: 60      withAliases:[NSArray arrayWithObjects:@"m",     @"minutes",      nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"hour" withMultiplier: 3600    withAliases:[NSArray arrayWithObjects:@"h",     @"hours",        @"hrs", nil]] autorelease],
            [[[ScalerDefinition alloc] initWithPrefix:@"day"  withMultiplier: 3600*24 withAliases:[NSArray arrayWithObjects:@"d",     @"days", nil]] autorelease],
            nil];
}
@end