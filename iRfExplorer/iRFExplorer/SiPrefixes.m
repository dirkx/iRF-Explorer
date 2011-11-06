//
//  SiPrefixes.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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