//
//  FrequencyButton.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FrequencyTextField.h"
#import "Frequency.h"

@implementation FrequencyTextField

-(void)awakeFromNib {   
    [super awakeFromNib];
    value = [[Frequency alloc] initScalar:1];
    
}
@end
