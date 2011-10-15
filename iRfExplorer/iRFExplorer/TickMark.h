//
//  TickMark.h
//  iScope
//
//  Created by Dirk-Willem van Gulik on 04/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TickMark : NSObject {
	NSString * labelStr;
	NSString * siUnit;
	NSString * siPrefix;
	double value;
}

@property (retain) NSString * labelStr;
@property (retain) NSString * siUnit;
@property (retain) NSString * siPrefix;
@property (assign) double value;

-(id) initWithLabelStr:(NSString *)aLabelOrNil
			withSiUnit:(NSString *)aSiUnitOrNil
		  withSiPrefix:(NSString *)aSiPrefixOrNil
			 withValue:(double)avalue;
@end
