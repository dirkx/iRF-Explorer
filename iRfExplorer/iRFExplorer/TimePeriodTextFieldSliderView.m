//
//  TimePeriodTextFieldSliderView.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimePeriodTextFieldSliderView.h"
#import "TimePeriodTextField.h"
#import "Timeperiod.h"

@implementation TimePeriodTextFieldSliderView

-(void)awakeFromNib {    
    NSRect tf = self.bounds;
    tf.size.height = kItemHeight;
    
    textField = [[TimePeriodTextField alloc] initWithFrame:tf];    
    
    minValue = 0;
    maxValue = 36000;
    
    [super awakeFromNib];
}    

@end
