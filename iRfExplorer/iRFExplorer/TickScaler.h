//
//  TickScaler.h
//  iScope
//
//  Created by Dirk-Willem van Gulik on 02/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "NiceNumber.h"
#import "BasicNiceNumber.h"
#import "NumericScaleDefinition.h"
#import "StringScaleDefinition.h"

@interface TickScaler : NSObject {
}

/**
 * Based on a minimum and a maximum and if the scale needs to include zero</br>
 * this returns the best scale possible.</br>
 */
+(NumericScaleDefinition *) calculateIdealScaleFromMin:(double)min
											   withMax:(double)max;

+(NumericScaleDefinition *) calculateIdealScaleFromMin:(double)min
											   withMax:(double)max
										   includeZero:(BOOL)hasZero;
/**
 * Create an array of all the given numbers, sorted in ascending order.</br>
 * An extra property indicating the score of the nice numbers is added.</br>
 * @return an array of BaseNiceNumber
 */
+(NSArray *) createBaseNiceNumbersWith:(NSArray *)basicNiceNumbers;

/**
 * Calculates the exponent (10^x) of the given range divided by the</br>
 * ideal number of ticks.
 */ 
+(double) calculateClosestMatchingExponentWithMin:(double)min 
										  withMax:(double)max 
									  includeZero:(BOOL)hasZer 
							  withIdealNbrOfTicks:(int)idealNbrOfTicks;

/**
 * Returns the range based on the min and max and if zero should be included.</br>
 */
+(double) createDataRangeWithMin:(double)min 
						 withMax:(double)max 
					 includeZero:(BOOL)hasZero;
/**
 * Returns a range of possible scale definitions.
 */
+(NSArray *) createRangeOfCandidateScaleIntervalsWithDataMin:(double)dataMin
												 withDataMax:(double)dataMax
												withExponent:(int)exponent
												withNiceNbrs:(NSArray *)niceNbrs
												 includeZero:(BOOL)hasZero;

/**
 * Create a scale definition based on the given min,max the nice number to be used, </br>
 * the exponent and if zero should be included. </br>
 */
+(NumericScaleDefinition *) calculateScaleIntervalWithDataMin:(double)dataMin
												  withDataMax:(double)dataMax
												  withNiceNbr:(BasicNiceNumber *)niceNbr
												 withExponent:(int)exponent
												  includeZero:(BOOL)hasZero;
/**
 * Based on a given set of scale definitions, return the one with the highest score.
 */
+(NumericScaleDefinition*) getBestScaleIntervalWithScaleIntervalArray:(NSArray *)scaleIntervals;

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
+(double) calculateScore:(NumericScaleDefinition*)scaleInt;

@end
