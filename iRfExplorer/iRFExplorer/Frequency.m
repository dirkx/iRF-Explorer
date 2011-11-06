//
//  Frequency.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Frequency.h"
#import "SiPrefixes.h"

@implementation Frequency

-(id)initScalar:(double)aValue {
    return [super initScalar:aValue withUnit:@"Hz" withPrefixes:[SiPrefixes defs]];
}
@end
