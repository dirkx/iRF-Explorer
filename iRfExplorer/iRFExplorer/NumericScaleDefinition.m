//
//  NumericScaleDefinition.m
//  iScope
//
///  Copyright 2011 WebWeaving. All rights reserved.
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


#import "NumericScaleDefinition.h"


@implementation NumericScaleDefinition

@synthesize min, max, diff, niceNbrScore, nbrOfTicks, includesZero, dataCoverage, subTickCount;

-(id) initWithMin:(double)_min
          withMax:(double)_max
	     withDiff:(double)_diff
 withNiceNbrScore:(double)_niceNbrScore
   withNbrOfTicks:(int)_nbrOfTicks
    withSubTickCount:(double)_subCount
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
    subTickCount = _subCount;
	return self;
}

 -(NSArray *)ticks {
     NSMutableArray * result = [NSMutableArray arrayWithCapacity:nbrOfTicks];
     double c = min;

     for(int i = 0; i < nbrOfTicks; i++) {
         [result addObject:[NSNumber numberWithDouble:c]];
         c+=diff;
     }

     return [NSArray arrayWithArray:result];
}

-(NSArray *)subTicks {
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:nbrOfTicks];
    double c = min;
    
    for(int i = 0; c < max; i++, c += diff/subTickCount) {
        if (i % subTickCount == 0)
            continue;
        
        [result addObject:[NSNumber numberWithDouble:c]];
    }
    
    return [NSArray arrayWithArray:result];
}

-(NSString*)description {
    if (min == max)
        return [NSString stringWithFormat:@"empty %@, %d#.", self.className, nbrOfTicks];
    
    return [NSString stringWithFormat:@"%@: <%f..%f> %d, cover %.1f", 
            self.className, min, max, nbrOfTicks, dataCoverage*100 ]; //], self.ticks];
}
@end
