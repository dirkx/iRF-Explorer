//
//  SignalTextField.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignalTextField.h"
#import "Signal.h"

@implementation SignalTextField

-(void)awakeFromNib {   
    [super awakeFromNib];
    value = [[Signal alloc] initScalar:1];    
}
@end

