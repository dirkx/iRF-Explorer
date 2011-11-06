//
//  SomeDrawerView.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFExplorer.h"

@interface SomeDrawerView : NSView {
    RFExplorer * device;
}

@property (retain) RFExplorer *device;

// Responding to changes in my environment.
-(void)newConfig:(id)sender;
-(void)setAllControls:(BOOL)on;
-(void)newBoard:(id)sender;

@end
