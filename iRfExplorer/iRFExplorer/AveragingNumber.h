//
//  AveragingNumber.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 22/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AveragingNumber : NSObject {
    double v;
    NSUInteger n;
}
+(AveragingNumber *)averagingNumber;
-(double)average;
// -(void)add:(double)aVal;
-(double)add:(double)aVal;
-(BOOL)hasAnAverage;
@end
