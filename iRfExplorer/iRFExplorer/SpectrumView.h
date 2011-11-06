//
//  SpectrumView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 03/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SomeTabView.h"
#import "FrequencyLegendView.h"
#import "SpectrumGraphView.h"
#import "dBmLegendView.h"

@interface SpectrumView : SomeTabView {
    IBOutlet FrequencyLegendView * frequencyLegendView;
    IBOutlet dBmLegendView * dbmLegendView;
    IBOutlet SpectrumGraphView * spectrumGraphView;
}

@property (assign) IBOutlet FrequencyLegendView * frequencyLegendView;
@property (assign) IBOutlet dBmLegendView * dbmLegendView;
@property (assign) IBOutlet SpectrumGraphView * spectrumGraphView;

@end
