//
//  NumericScaleDefinition.m
//  iScope
//
//  Created by Dirk-Willem van Gulik on 02/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import "NumericScaleDefinition.h"


@implementation NumericScaleDefinition

@synthesize min, max, diff, niceNbrScore, nbrOfTicks, includesZero, dataCoverage;

-(id) initWithMin:(double)_min
          withMax:(double)_max
	     withDiff:(double)_diff
 withNiceNbrScore:(double)_niceNbrScore
   withNbrOfTicks:(int)_nbrOfTicks
	 includesZero:(BOOL)_includesZero
 withDataCoverage:(double)_dataCoverage
{
	min = _min;
	max = _max;
	diff = _diff;
	niceNbrScore = _niceNbrScore;
	nbrOfTicks = _nbrOfTicks;
	includesZero = _includesZero;
	dataCoverage = _dataCoverage;
	return self;
}

 -(NSArray *)ticks {
	NSMutableArray * result = [[NSMutableArray alloc] init];
	double c = min;
	for(int i = 0; i < nbrOfTicks; i++) {
		[result addObject:[NSNumber numberWithDouble:c]];
		c+=diff;
	}
	return result;
}

-(NSString*)description {
    if (min == max)
        return [NSString stringWithFormat:@"empty %@, %d#.", self.className, nbrOfTicks];
    
    return [NSString stringWithFormat:@"%@: <%f..%f> %d# - %@", 
            self.className, min, max, nbrOfTicks, self.ticks];
}
@end
