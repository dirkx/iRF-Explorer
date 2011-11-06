//
//  Signal.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Signal.h"
#import "NoPrefixes.h"

@implementation Signal

-(id)initScalar:(double)aValue {
    return [super initScalar:aValue withUnit:@"dBm" withPrefixes:[NoPrefixes defs]];
}
@end
