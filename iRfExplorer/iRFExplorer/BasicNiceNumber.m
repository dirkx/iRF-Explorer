//
//  BasicNiceNumber.m
//  iScope
//
//  Created by Dirk-Willem van Gulik on 02/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import "BasicNiceNumber.h"

@implementation BasicNiceNumber

@synthesize base,score;

-(id) initWithBase:(double)_base 
		 withScore:(double)_score
{
	base = _base;
	score = _score;
return self;
}
@end
