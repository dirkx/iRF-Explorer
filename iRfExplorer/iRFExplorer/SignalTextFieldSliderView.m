//
//  SignalTextFieldSliderView.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignalTextFieldSliderView.h"
#import "SignalTextField.h"

@implementation SignalTextFieldSliderView
                
-(void)awakeFromNib {    
    
    NSRect tf = self.bounds;
    tf.size.height = kItemHeight;
    
    textField = [[SignalTextField alloc] initWithFrame:tf];    
    
    minValue = -120;
    maxValue = -1;

    [super awakeFromNib];
}    

@end
