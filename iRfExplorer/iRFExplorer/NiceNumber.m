//
//  NiceNumber.m
//  iScope
//
//  Created by Dirk-Willem van Gulik on 02/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import "NiceNumber.h"


@implementation NiceNumber
@synthesize niceNbr, realValue, exponent;

-(id) initWithRealValue:(double)r 
		   withExponent:(double)e 
			withNiceNbr:(BasicNiceNumber *)n 
{
	realValue = r;
	self.niceNbr = n;
	exponent = e;
	
	return self;
}

-(void)dealloc {
    [niceNbr release];
    
    [super dealloc];
}
@end
