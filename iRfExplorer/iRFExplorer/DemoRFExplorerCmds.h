//
//  DemoRFExplorerCmds.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 17/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include "RFExporerCmds.h"

@interface DemoRFExplorerCmds : RFExporerCmds {
    NSMutableArray * cmdQue;
    BOOL spectrumRun, lcdRun;
    int crashMode;
}
// rely on default to be atomic.
@property (retain) NSMutableArray * cmdQue;

@end
