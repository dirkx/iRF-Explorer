//
//  SpectrogramView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 05/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SomeTabView.h"
#import "SpectrogramGraphView.h"
#import "FrequencyLegendView.h"
#import "TimeLegendView.h"
#import "TimeStampLegendView.h"
#import "RFExplorer.h"

@interface SpectrogramView : SomeTabView {
    IBOutlet SpectrogramGraphView * spectrogramGraphView;
    IBOutlet FrequencyLegendView * frequencyLegendView;
    IBOutlet TimeStampLegendView * timeStampLegendView;
    IBOutlet TimeLegendView * timeLegendView;
    IBOutlet NSView *graphView;
}

@property (retain) IBOutlet NSView *graphView;

@property (assign) IBOutlet SpectrogramGraphView * spectrogramGraphView;
@property (assign) IBOutlet FrequencyLegendView * frequencyLegendView;
@property (assign) IBOutlet TimeStampLegendView * timeStampLegendView;
@property (assign) IBOutlet TimeLegendView * timeLegendView;

@end
