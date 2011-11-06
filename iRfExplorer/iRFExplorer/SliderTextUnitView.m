//
//  SliderTextUnitView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SliderTextUnitView.h"

@implementation SliderTextUnitView
@synthesize noFeedbackNeeded, logSlider;

NSUInteger const kItemHeight = 21;

// See http://www.cocoadev.com/index.pl?NSControl and
// http://stackoverflow.com/questions/3889043/nscontrol-subclass-cant-read-the-target
//
+ (Class) cellClass { 
    return [NSActionCell class]; 
}

const double lg = 3.0;

-(double)sliderToValue:(double) v {
    if (!logSlider)
        return v;
    v = pow(v,lg);
    if (!logSlider)
        return v;
    return v;
}

-(double)valueToSlider:(double) v {
    v = pow(v, 1/lg);
    return v;
}

-(void)awakeFromNib {    
    [super awakeFromNib];
    
    NSRect sf = self.bounds;
    sf.origin.y += kItemHeight;
    sf.size.height -= kItemHeight;    
    slider = [[NotifyingSlider alloc] initWithFrame:sf];
    slider.minValue = 1;
    slider.maxValue = 2;
    slider.doubleValue = (slider.minValue + slider.maxValue)/2;
    [slider setContinuous:YES];
    
    [self addSubview:slider];
    [self addSubview:textField];

    slider.action = @selector(sliderChanged:);
    slider.doneAction = @selector(sliderDone:);
    slider.target = self;

    textField.action = @selector(textFieldChange:);
    textField.target = self;
    return;
}

-(void)textFieldChange:(TextFieldWithUnit *)sender {
    self.scalarValue = sender.scalarValue;

    [textField setTextColor:noFeedbackNeeded ? [NSColor blackColor] : [NSColor blueColor]];
    
    [self sendAction:self.action to:self.target];
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
//    if ([self isEnabled] == enabled) return;
    
    [slider setAlphaValue:enabled ? 1 : 0.5];
    [textField setEnabled:enabled];    

    // Park sliders in mid-setting if disable; and move
    // back on re-enabling.
    //
    if (enabled) 
        [self setScalarValue:self.scalarValue];    
    else
        slider.doubleValue = (slider.minValue + slider.maxValue)/2;
}

-(BOOL)isEnabled {
    return textField.isEnabled;
}

-(void)setMinValue:(double)aValue {
    minValue = aValue;

    if (minValue == maxValue)
        slider.doubleValue = (slider.minValue + slider.maxValue)/2;
    
    if (textField.scalarValue < minValue) 
        [self setScalarValue:minValue];
}

-(double)minValue {
    return minValue;
}

-(void)setMaxValue:(double)aValue {
    maxValue = aValue;
    
    if (minValue == maxValue)
        slider.doubleValue = (slider.minValue + slider.maxValue)/2;

    if (textField.scalarValue > maxValue) 
        [self setScalarValue:maxValue];
}

-(double)maxValue {
    return maxValue;
}


-(void)sliderChanged:(id)sender {
    double v = [self sliderToValue:slider.doubleValue];

    if (minValue >= maxValue)
        v = minValue;
    else
        v = minValue + (maxValue-minValue) * v;

    if (v != textField.scalarValue)
        [textField setTextColor:[NSColor blueColor]];

    [textField setScalarValue:v];
    
    // Pospone notification until the slider done. Or
    // should we notify if the user has been dragging
    // for longer than a second or so ?
}

-(void)sliderDone:(id)sender {
    [self setScalarValue:textField.scalarValue];

    [textField setTextColor:noFeedbackNeeded ? [NSColor blackColor] : [NSColor darkGrayColor]];

    [self sendAction:self.action to:self.target];
}

-(void)setScalarValue:(double)aValue {
    double scalarValue = MIN(maxValue, MAX(minValue,aValue));
    
    // we try to avoid upsetting any editing going on.
    //
    if (textField.scalarValue != scalarValue || 
        [textField.text.stringValue isEqual:@""]) {
        [textField setScalarValue:scalarValue];
    }
    
    if (minValue >= maxValue)
        slider.doubleValue   = (slider.minValue + slider.maxValue)/2;
    else
        slider.doubleValue   = [self valueToSlider:(scalarValue - minValue) / (maxValue - minValue)];
    
    [textField setTextColor:[NSColor blackColor]];
}

-(double)scalarValue {
    return textField.scalarValue;
}

-(ScalarWithUnit *)value {
    return textField.value;
}

-(void)setValue:(ScalarWithUnit *)value {
    textField.value = value;
    [self setScalarValue:textField.scalarValue];
}

-(void)setLabel:(NSString *)label {
    textField.label.stringValue = label;
}

-(NSString *)label {
    return textField.label.stringValue;
}

-(void)dealloc {
    [slider release];
    [textField release];
    
    [super dealloc];
}
@end
