//
//  NumericScaleDefinition.h
//  iScope
//
//  Created by Dirk-Willem van Gulik on 02/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NumericScaleDefinition : NSObject {
	double min, max, diff, niceNbrScore;
	int nbrOfTicks;
	BOOL includesZero;
	double dataCoverage;
}

@property (assign) double min;
@property (assign) double max;
@property (assign) double diff;
@property (assign) double niceNbrScore;
@property (assign) int nbrOfTicks;
@property (assign) BOOL includesZero;
@property (assign) double dataCoverage;

-(id) initWithMin:(double)_min
          withMax:(double)_max
	     withDiff:(double)_diff
 withNiceNbrScore:(double)_niceNbrScore
   withNbrOfTicks:(int)_nbrOfTicks
	 includesZero:(BOOL)_includesZero
 withDataCoverage:(double)_dataCoverage;

-(NSArray *)ticks;

@end
