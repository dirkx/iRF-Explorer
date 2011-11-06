//
//  ConfigView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 24/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SomeTabView.h"

@interface ConfigView : SomeTabView {
    IBOutlet NSTextField *infoBandCenterFreq;
    IBOutlet NSTextField *infoBandMinFreq;
    IBOutlet NSTextField *infoBandMaxFreq;
    IBOutlet NSTextField *infoBandSpanFreq;
    IBOutlet NSTextField *infoBandApproxRbm;
    IBOutlet NSTextField *infoBoardTitle;
    IBOutlet NSTextField *infoBoardMinFreq;
    IBOutlet NSTextField *infoBoardMaxFreq;
    IBOutlet NSTextField *infoBoardSteps;
    IBOutlet NSTextField *infoAttenTop;
    IBOutlet NSTextField *infoAttenBott;
    IBOutlet NSTextField *infoAttenMax;
    IBOutlet NSTextField *infoAttenMin;
    IBOutlet NSTextField *infoDevFirmware;
    IBOutlet NSTextField *infoDevMain;
    IBOutlet NSTextField *infoDevExpansion;
    IBOutlet NSTextField *infoDevBaudrate;
}

@property (retain) IBOutlet NSTextField *infoBandCenterFreq, *infoBandMinFreq, *infoBandMaxFreq, *infoBandSpanFreq, *infoBoardTitle, *infoBoardMinFreq, *infoBoardMaxFreq, *infoAttenTop,*infoAttenBott,*infoDevFirmware, *infoDevMain, *infoDevExpansion, *infoDevBaudrate, *infoAttenMax, *infoAttenMin, *infoBoardSteps, *infoBandApproxRbm;

@end
