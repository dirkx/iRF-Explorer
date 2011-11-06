//
//  TimePeriodButton.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimePeriodTextField.h"
#import "Timeperiod.h"

@implementation TimePeriodTextField

-(void)awakeFromNib {    
    [super awakeFromNib];
    value = [[Timeperiod alloc] initScalar:1];
}

@end
