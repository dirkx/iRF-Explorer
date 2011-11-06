//
//  TimePeriodPrefixes.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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