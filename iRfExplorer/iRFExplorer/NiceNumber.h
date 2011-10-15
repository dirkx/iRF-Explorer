//
//  NiceNumber.h
//  iScope
//
//  Created by Dirk-Willem van Gulik on 02/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicNiceNumber.h"

@interface NiceNumber : NSObject {
	double realValue, exponent;
	BasicNiceNumber * niceNbr;
}

@property (assign) 	double realValue;
@property (assign) 	double exponent;
@property (retain) 	BasicNiceNumber * niceNbr;

-(id) initWithRealValue:(double)r 
		   withExponent:(double)e 
			withNiceNbr:(BasicNiceNumber*)b; 
@end
