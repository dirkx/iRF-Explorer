//
//  NoPrefixes.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoPrefixes.h"
#import "ScalerDefinition.h"

@implementation NoPrefixes
+(NSArray *)defs {
    return [NSArray arrayWithObjects:
            [[[ScalerDefinition alloc] initWithPrefix:@"" withMultiplier:1 withAliases:[NSArray arrayWithObjects:@"#", nil]] autorelease],
            nil];
}
@end

