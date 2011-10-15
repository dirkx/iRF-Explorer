//
//  BasicNiceNumber.h
//  iScope
//
//  Created by Dirk-Willem van Gulik on 02/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicNiceNumber : NSObject 
{
	double base;
	double score;
}

@property (assign) double base;
@property (assign) double score;

-(id)initWithBase:(double)_base withScore:(double)_score;

@end
