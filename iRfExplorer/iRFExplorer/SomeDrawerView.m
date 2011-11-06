//
//  SomeDrawerView.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SomeDrawerView.h"

@implementation SomeDrawerView
@synthesize device;

-(void)awakeFromNib {
    [self newBoard:self];
    [self newConfig:self];
}

-(void)newBoard:(id)sender {
}

-(void)newConfig:(id)sender {
    [self setAllControls:(device != nil) ? YES : NO];
}

-(void)setAllControls:(BOOL)on {
}


@end
