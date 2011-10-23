//
//  AveragingNumber.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 22/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AveragingNumber.h"

@implementation AveragingNumber

- (id)init
{
    self = [super init];
    if (self) {
        n = 0;
    }
    
    return self;
}

+(AveragingNumber *)averagingNumber {
    return [[[AveragingNumber alloc] init] autorelease];
}

-(double)average {
    if (n == 0)
        return 0; // ?
    return v / n;
};

-(BOOL)hasAnAverage {
    return (n > 0);
}

-(double)add:(double)aVal {
    v += aVal;
    n ++;
    return v / n;
}
@end
