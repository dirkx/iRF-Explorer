//
//  TickMark.m
//  iScope
//
//  Created by Dirk-Willem van Gulik on 04/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import "TickMark.h"

@implementation TickMark

@synthesize labelStr;
@synthesize siUnit;
@synthesize value;
@synthesize siPrefix;

-(id) initWithLabelStr:(NSString *)aLabelOrNil
			withSiUnit:(NSString *)aSiUnitOrNil
		  withSiPrefix:(NSString *)aSiPrefixOrNil
			 withValue:(double)aValue
{
	if (!(self = [super init]))
		return nil;
	
	self.labelStr = aLabelOrNil ? aLabelOrNil : @"";
	self.siUnit = aSiUnitOrNil ? aSiUnitOrNil : @"";
	self.siPrefix = aSiPrefixOrNil ? aSiPrefixOrNil : @"";
	self.value = aValue;
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%f/%@%@", value, labelStr, siUnit];
}

-(void)dealloc {
    self.labelStr = nil;
    self.siUnit = nil;
    self.siPrefix = nil;
}
@end
