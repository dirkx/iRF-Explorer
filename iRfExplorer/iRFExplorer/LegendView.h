//
//  LegendView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 05/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "RFExplorer.h"

@interface LegendView : NSView {
    RFExplorer * device;
    IBOutlet NSView *graphView;
}

@property (retain) RFExplorer * device;
@property (retain) IBOutlet NSView *graphView;
@end
