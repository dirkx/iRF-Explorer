//
//  FrequencyTextFieldSliderView.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FrequencyTextFieldSliderView.h"
#import "FrequencyTextField.h"

@implementation FrequencyTextFieldSliderView

-(void)awakeFromNib {    
    NSRect tf = self.bounds;
    tf.size.height = kItemHeight;
    
    textField = [[FrequencyTextField alloc] initWithFrame:tf]; 
    
    minValue = 110e3; // 110 kHz
    maxValue =   5e9; //   5 Ghz
    
    [super awakeFromNib];
}  
@end
