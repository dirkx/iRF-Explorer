//
//  NumericScaleDefinition.h
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
