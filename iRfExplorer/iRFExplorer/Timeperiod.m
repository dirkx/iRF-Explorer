//
//  Timeperiod.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Timeperiod.h"
#import "TimePeriodPrefixes.h"

@implementation Timeperiod

-(id)initScalar:(double)aValue {
    return [super initScalar:aValue withUnit:@"" withPrefixes:[TimePeriodPrefixes defs]];
}

@end
