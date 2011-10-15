//
//  StringScaleDefinition.h
//  iScope
//
//  Created by Dirk-Willem van Gulik on 03/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import "NumericScaleDefinition.h"
#import "TickMark.h"

@interface StringScaleDefinition : NSObject {
	double dataMin, dataMax;
	NumericScaleDefinition * def;
	NSString * commonSIprefix;
	NSArray * ticks;
	BOOL individualSIprefix;
}

@property (retain,readonly) NumericScaleDefinition * def;
@property (retain,readonly) NSArray * ticks;
@property (assign,readonly) BOOL individualSIprefix;
@property (assign,readonly) double dataMin;
@property (assign,readonly) double dataMax;
@property (retain) NSString * commonSIprefix;

-(BOOL) hasCommonSIprefix;

-(id)initWithNumericScaleDefinition:(NumericScaleDefinition *)def
						withDataMin:(double)aDataMin
						withDataMax:(double)aDataMax
						   withUnit:(NSString *)siUnit;
@end

