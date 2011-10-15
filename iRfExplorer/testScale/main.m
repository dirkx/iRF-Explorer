//
//  main.m
//  testScale
//
//  Created by Dirk-Willem van Gulik on 15/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NumericScaleDefinition.h"
#import "StringScaleDefinition.h"
#import "TickScaler.h"

int main (int argc, const char * argv[])
{
    float max =   -8;
    float min = -18;

    if (argc != 1 && argc != 3) {
        fprintf(stderr,"Syntax: %s [min max]\n", argv[0]);
        return -1;
    };
    
    if (argc == 3) {
        min = atof(argv[1]);
        max = atof(argv[2]);
    };
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NumericScaleDefinition * ns = [TickScaler calculateIdealScaleFromMin:min 
                                                                 withMax:max
                                   ];
	
    StringScaleDefinition * scale = [[StringScaleDefinition alloc] initWithNumericScaleDefinition:ns 
                                                              withDataMin:min
                                                              withDataMax:max
                                                                 withUnit:@"dBm"];

    NSLog(@"Got %@", scale.ticks);
    
    [scale dealloc];
    
    [pool drain];
    return 0;
}

