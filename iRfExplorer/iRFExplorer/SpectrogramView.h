//
//  SpectrogramView.h
//  iRFExplorer
//
//  Copyright 2011 WebWeaving. All rights reserved.
//                 Dirk-Willem van Gulik <dirkx(at)webweaving(dot)org>
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 
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
