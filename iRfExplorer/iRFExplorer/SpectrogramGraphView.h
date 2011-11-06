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

#import <Cocoa/Cocoa.h>
#import "SomeTabView.h"
#import "Spectrum.h"
#import "RFExplorer.h"
#import "AveragingNumber.h"
#import "FrequencyLegendView.h"
#import "TimeStampLegendView.h"
#import "TimeLegendView.h"

@interface SpectrogramGraphView : SomeTabView {
@private
    NSInteger nAges;
    NSMutableArray * ages;
    NSMutableArray * agesInSeconds;
    NSDate * floatAge;
    NSUInteger floatHeight;
    NSBitmapImageRep * imageRep;
    NSMutableArray * values;
    double secondsPerLine;
    NSDate *lastLineScrollDate;

    NSImageView * imageView;
}


@property (retain) NSDate * floatAge;
@property (retain) NSMutableArray * ages;
@property (retain) NSMutableArray * agesInSeconds;
@property (retain) NSMutableArray * values;
@property (retain) NSDate *lastLineScrollDate;
@property (assign) NSUInteger floatHeight;
@property (assign) NSInteger nAges;

@property (assign) double secondsPerLine;

// Assign, used by IB
@property (assign) IBOutlet NSImageView * imageView;

-(void)addSpectrum:(Spectrum *)newSpectrum;
@end

