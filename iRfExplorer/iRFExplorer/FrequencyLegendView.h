//
//  FrequencyLegendView.h
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

#import <AppKit/AppKit.h>
#import "NumericScaleDefinition.h"
#import "StringScaleDefinition.h"
#import "LegendView.h"

#import "RFExplorer.h"

@interface FrequencyLegendView : LegendView {
    NSArray * ticks, * subTicks;
    double min, max, span;
    BOOL fullRange, wifi;
    NSString * graphLabel;
}

@property (retain) NSArray * ticks, * subTicks;
@property (retain) NSString * graphLabel;
@property (assign) BOOL fullRange,wifi;
@end
