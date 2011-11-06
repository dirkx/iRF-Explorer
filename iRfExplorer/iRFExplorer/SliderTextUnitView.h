//
//  SliderTextUnitView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextFieldWithUnit.h"
#import "NotifyingSlider.h"

extern NSUInteger const kItemHeight;

@interface SliderTextUnitView : NSControl <NSCoding> {
    TextFieldWithUnit * textField;
    NotifyingSlider *slider;
    double minValue, maxValue;
    BOOL noFeedbackNeeded, logSlider;
}

@property (assign) double minValue, maxValue, scalarValue;
@property (assign,getter=isEnabled) BOOL enabled;
@property (assign,getter=isLogSlider) BOOL logSlider;
@property (assign) BOOL noFeedbackNeeded;
@property (retain) NSString * label;
@property (retain) ScalarWithUnit * value;
@end

