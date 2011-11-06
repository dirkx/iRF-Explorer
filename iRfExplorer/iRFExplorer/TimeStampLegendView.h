//
//  TimeSlotLegendView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 05/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NumericScaleDefinition.h"
#import "StringScaleDefinition.h"
#import "LegendView.h"
#import "RFExplorer.h"

@interface TimeStampLegendView : LegendView {
    // SpectrogramView * graphView;
    NSDateFormatter * ndf;
    BOOL showTimeStamp;
}
@property (assign) BOOL showTimeStamp;
@end
