//
//  TickScaler.m
//  iScope
//
// Algorithm from 'The Grammar of Graphics', L Wilkinsons, Chapter 6.
// based on the flash/flex code example in BirdEye.org; which is/was
// under http://www.opensource.org/licenses/mit-license.php.
//
//  Copyright 2010 webweaving.org. All rights reserved.
//  License: http://www.opensource.org/licenses/mit-license.php

#import "TickScaler.h"


@implementation TickScaler

int idealNbrOfTicks, minNbrOfTicks, maxNbrOfTicks;
NSArray * baseNiceNumber, *niceNbrs;

#define MAXMAX (100)

/**
 * Based on a minimum and a maximum and if the scale needs to include zero</br>
 * this returns the best scale possible.</br>
 */
+(NumericScaleDefinition *) calculateIdealScaleFromMin:(double)min
											   withMax:(double)max
										   includeZero:(BOOL)hasZero
{	
	/**
	 * The number of ticks on scale that is ideal.</br>
	 * This is used in the scoring algorithm. </br>
	 */
	idealNbrOfTicks = 4;
	
	/**
	 * The set of nice number that is used for dividing scales.</br>
	 * <b>Important:</b> the order of these numbers is used for scoring! </br>
	 * For instance the first number gets the maximum score, the last gets the minimum score.
	 */
	baseNiceNumber = [[[NSArray alloc] initWithObjects:
					  [NSNumber numberWithFloat:1.0],
					  [NSNumber numberWithFloat:5.0],
					  [NSNumber numberWithFloat:2.0],
					  [NSNumber numberWithFloat:2.5],
					  [NSNumber numberWithFloat:3.0],
					  nil] autorelease];
	
	niceNbrs = [self createBaseNiceNumbersWith:baseNiceNumber];
	
	/**
	 * The minimum number of ticks on a scale.</br>
	 * <b>Important:</b> This is an <i>indication</i> for the scoring algorithm.</br>
	 * Scales with less than these number of ticks get a drastic lower score, but</br>
	 * it is entirely possible that they still get selected.</br>
	 * For instance if the data coverage is superb.</br>
	 */
	minNbrOfTicks = 3;
	
	/**
	 * The maximum number of ticks on a scale.</br>
	 * <b>Important:</b> This is an <i>indication</i> for the scoring algorithm.</br>
	 * Scales with less than these number of ticks get a drastic lower score, but</br>
	 * it is entirely possible that they still get selected.</br>
	 * For instance if the data coverage is superb.</br>
	 */
	maxNbrOfTicks = 6;

	double exp = [self calculateClosestMatchingExponentWithMin:min
													   withMax:max 
												   includeZero:hasZero 
										   withIdealNbrOfTicks:idealNbrOfTicks];				  

	NSArray * scaleIntervals = [self createRangeOfCandidateScaleIntervalsWithDataMin:min
																		  withDataMax:max
																		 withExponent:exp
																		 withNiceNbrs:niceNbrs
																		  includeZero:hasZero];
	
	return [self getBestScaleIntervalWithScaleIntervalArray:scaleIntervals];
}

+(NumericScaleDefinition *) calculateIdealScaleFromMin:(double)min
											   withMax:(double)max {
    return [self calculateIdealScaleFromMin:min
                                    withMax:max
                                includeZero:(min <= 0 && max >= 0)
            ];
}

/**
 * Create an array of all the given numbers, sorted in ascending order.</br>
 * An extra property indicating the score of the nice numbers is added.</br>
 * @return an array of BaseNiceNumber
 */
+(NSArray *) createBaseNiceNumbersWith:(NSArray *)baseNiceNumbers
{
    NSUInteger n = [baseNiceNumbers count];
	NSMutableArray * toReturn = [NSMutableArray arrayWithCapacity:n];

	for (int i = 0;i< n;i++)
	{
		BasicNiceNumber *t = [[BasicNiceNumber alloc] initWithBase:[[baseNiceNumbers objectAtIndex:i] doubleValue] 
														  withScore:i+1];
		[toReturn addObject:t];
        [t release];
	}
	
	NSSortDescriptor * baseDescriptor;
	baseDescriptor = [[NSSortDescriptor alloc] initWithKey:@"base"
												 ascending:YES];	

	NSArray * out = [toReturn sortedArrayUsingDescriptors:[NSArray arrayWithObject:baseDescriptor]];

    [baseDescriptor release];
    
    return out;
}

/**
 * Calculates the exponent (10^x) of the given range divided by the</br>
 * ideal number of ticks.
 */ 
+(double) calculateClosestMatchingExponentWithMin:(double)min 
                                           withMax:(double)max 
                                           includeZero:(BOOL)hasZero
							   withIdealNbrOfTicks:(int)_idealNbrOfTicks
{
	double dataRange = [self createDataRangeWithMin:min 
											withMax:max 
											includeZero:hasZero];
	
	double exactRange = dataRange / _idealNbrOfTicks;
	
	return floor(log(exactRange)/M_LN10);
}

/**
 * Returns the range based on the min and max and if zero should be included.</br>
 */
+(double) createDataRangeWithMin:(double)min 
						 withMax:(double)max 
						 includeZero:(BOOL)hasZero
{
	double dataRange = fabs(min - max);
	
	if (hasZero && min > 0 && max > 0)
	{
		dataRange = max;
	}
	
	if (hasZero && min < 0 && max < 0)
	{
		dataRange = fabs(min);
	}
	
	return dataRange;
}


/**
 * Returns a range of possible scale definitions.
 */
+(NSArray *) createRangeOfCandidateScaleIntervalsWithDataMin:(double)dataMin
												 withDataMax:(double)dataMax
												withExponent:(int)exponent
												withNiceNbrs:(NSArray *)_niceNbrs
												 includeZero:(BOOL)hasZero
{
	NSUInteger n = [_niceNbrs count];
	NSMutableArray * scaleIntervals = [NSMutableArray arrayWithCapacity:3*n];

	for(int i = 0; i < n;i++) {
		NumericScaleDefinition * nsd = [self calculateScaleIntervalWithDataMin:dataMin
																   withDataMax:dataMax
																   withNiceNbr:[_niceNbrs objectAtIndex:i]
																  withExponent:exponent
																   includeZero:hasZero];
		if (nsd) 
			[scaleIntervals addObject:nsd];
	}

	for(int i = 0; i < n;i++) {
		NumericScaleDefinition * nsd = [self calculateScaleIntervalWithDataMin:dataMin
																   withDataMax:dataMax
																   withNiceNbr:[_niceNbrs objectAtIndex:i]
																  withExponent:exponent+1
																   includeZero:hasZero];
		if (nsd) 
			[scaleIntervals addObject:nsd];
	}
	for(int i = 0; i < n;i++) {
		NumericScaleDefinition * nsd = [self calculateScaleIntervalWithDataMin:dataMin
																   withDataMax:dataMax
																   withNiceNbr:[_niceNbrs objectAtIndex:i]
																  withExponent:exponent-1
																   includeZero:hasZero];
		if (nsd) 
			[scaleIntervals addObject:nsd];
	}
	
	return scaleIntervals;
	
}

/**
 * Create a scale definition based on the given min,max the nice number to be used, </br>
 * the exponent and if zero should be included. </br>
 */
+(NumericScaleDefinition *) calculateScaleIntervalWithDataMin:(double)dataMin
												  withDataMax:(double)dataMax
												  withNiceNbr:(BasicNiceNumber *)niceNbr
												 withExponent:(int)exponent
												  includeZero:(BOOL)hasZero
{
	int nbrOfTicks = 1;
	double tickDiff;
	double currentValue;
	double min, max;
	
	tickDiff = niceNbr.base * pow(10.0, exponent);
	
	double dataRange = [self createDataRangeWithMin:dataMin
											withMax:dataMax
										includeZero:hasZero];
		
	if (tickDiff > dataRange )
	{
		// difference is to bigg!
#ifdef TICK_DEBUG
		NSLog(@"Delta is too large - giving up (%f, %f)", tickDiff, dataRange);
#endif
		return nil;
	}
	
	if (dataMax > 0)
	{
		if (dataMin < 0)
		{
			currentValue = 0;
			while (currentValue > dataMin && nbrOfTicks < MAXMAX)
			{
				currentValue -= tickDiff;
				nbrOfTicks++;
			}
			
			min = currentValue;
			currentValue = 0;
		}
		else if (hasZero)
		{
			min = 0;
			currentValue = 0;
		}
		else if (!hasZero)
		{
            double rest = fmod(dataMin, tickDiff);

			currentValue = dataMin - rest;
			min = currentValue;
		}
		
		while(currentValue < dataMax && nbrOfTicks < MAXMAX)
		{
			currentValue += tickDiff;
			
			nbrOfTicks++;
			
		}
		
		max = currentValue;
		
		
	}
	else
	{
		if (hasZero)
		{
			max = 0;
			currentValue = 0;
		}
		else
		{
            double rest = fmod(dataMax, tickDiff);
			currentValue = dataMax - rest;
			max = currentValue;
		}
		// going down
		while (currentValue > dataMin && nbrOfTicks < MAXMAX)
		{
			currentValue -= tickDiff;
			
			nbrOfTicks++;
		}
		
		min = currentValue;
		
	}
	
	double dataCoverage = fabs(dataRange / (min - max));

	int ticks;
    BOOL shrt = nbrOfTicks < 6 ? YES : NO;
    switch ((int)(10*niceNbr.base)) {
        case 10:
        case 50:
            ticks = shrt ? 10 : 5;
            break;
        case 20:
            ticks = shrt ? 10 :4;
            break;
        case 25:
            ticks = shrt ? 5 : 3;
            break;
        case 30:
            ticks = shrt ? 10 :3;
            break;
        default:
            ticks = shrt ? 5 : 2;
            break;
    };
    if (nbrOfTicks < 4)
        ticks *= 10;
    
	NumericScaleDefinition * nsd = [[NumericScaleDefinition alloc] initWithMin:min 
																	   withMax:max 
																	  withDiff:tickDiff 
															  withNiceNbrScore:niceNbr.score 
																withNbrOfTicks:nbrOfTicks 
                                                              withSubTickCount:ticks
																  includesZero:hasZero
															  withDataCoverage:dataCoverage];
	
	return [nsd autorelease];
}

/**
 * Based on a given set of scale definitions, return the one with the highest score.
 */
+(NumericScaleDefinition*) getBestScaleIntervalWithScaleIntervalArray:(NSArray *)scaleIntervals
{
	double highestScore = -1;
	double indexHighestScore = -1;
	
    if ([scaleIntervals count] == 0)
        return nil;
    
	for (int i = 0; i < [scaleIntervals count];i++)
	{
		NumericScaleDefinition * scaleDef = [scaleIntervals objectAtIndex:i];
		
		if (scaleDef)
		{
			double score = [self calculateScore:scaleDef];
			
			// NSLog(@"Scale: %@, score %f", scaleDef, score);
			if (score > highestScore)
			{
				highestScore = score;
				indexHighestScore = i;
			}
		}
	}
	
	if (indexHighestScore >= 0)
		return [scaleIntervals objectAtIndex:indexHighestScore];
	
#ifdef DEBUG
		NSLog(@"getBestScaleIntervalWithScaleIntervalArray caboomed - no decent score scale for %@", scaleIntervals);
#endif
	return nil;
}

/**
 * Calculate the score of a given scale definition.</br>
 * The score is determined by three things:</br>
 * <ul>
 * <li><b>Simplicity</b> : How nice if the used number </li>
 * <li><b>Granularity</b> : How ideal are the number of ticks used? </li>
 * <li><b>Datacoverage</b> : How good does the scale cover the data? </br>
 * For instance if the range of the scale is 100, but the range of the data is only 50,</br>
 * the coverage is only 0.5, which is bad.</br>
 * If the datacoverage is below 75% the score lowers drastically.</br>
 * </li>
 * </ul>
 */
+(double) calculateScore:(NumericScaleDefinition*)scaleInt
{
	double simplicity = 1 - scaleInt.niceNbrScore / baseNiceNumber.count;

	if (scaleInt.includesZero)
	{
		// add because we're using a zero in the scale interval
		simplicity += 1 / baseNiceNumber.count; 
	}
	
	double granularity = 0;
	
	if (scaleInt.nbrOfTicks >= minNbrOfTicks && scaleInt.nbrOfTicks <= maxNbrOfTicks)
	{
		granularity = 1 - fabs(scaleInt.nbrOfTicks - idealNbrOfTicks) / idealNbrOfTicks;
	}
	else
	{
		granularity = -1;
	}
	
	double dcScore = 0;
    
	if (scaleInt.dataCoverage > 0.90 && scaleInt.dataCoverage  < 1.10) // normally lower!
	{
		dcScore = scaleInt.dataCoverage * 4;	
	}
	else if (scaleInt.dataCoverage > 0.80  && scaleInt.dataCoverage  < 1.20) // normally lower!
	{
		dcScore = scaleInt.dataCoverage;
	} 
    else 
    {
        dcScore = -1;
    }
	
	if (scaleInt.nbrOfTicks > 1.5*maxNbrOfTicks)
		granularity = -5;

	if (scaleInt.nbrOfTicks > 2*maxNbrOfTicks)
		granularity = -20;
		
	return (simplicity + granularity + dcScore) / 3;
}

@end
