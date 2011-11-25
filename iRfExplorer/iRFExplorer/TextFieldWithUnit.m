//
//  TextFieldWithUnit.m
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
#import "TextFieldWithUnit.h"
#import "NSStringExtensions.h"

@implementation TextFieldWithUnit
@synthesize label, text;
@synthesize delegate;

NSUInteger const kTextFieldWithUnitWidth = 32;
NSUInteger const kTextFieldWithUnitSeparation = 4;

// See http://www.cocoadev.com/index.pl?NSControl and
// http://stackoverflow.com/questions/3889043/nscontrol-subclass-cant-read-the-target
//
+ (Class) cellClass { 
    return [NSActionCell class]; 
}

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (!self)
        return nil;

    [self awakeFromNib];
    return self;
}

-(void)awakeFromNib {    
    [super awakeFromNib];
    
    NSRect lf = self.bounds;
    lf.origin.x += lf.size.width - kTextFieldWithUnitWidth;
    lf.size.width = kTextFieldWithUnitWidth;
    lf.origin.y -= 3; // compensate for bezel.
    
    NSRect tf = self.bounds;
    tf.size.width -= kTextFieldWithUnitWidth + kTextFieldWithUnitSeparation;

    text = [[NSTextField alloc] initWithFrame:tf];
    text.stringValue = @"";
    text.delegate = self;

    [text setBezelStyle:NSBezelBorder];
    [text setBackgroundColor:[NSColor textBackgroundColor]];
    [text setAlignment:NSRightTextAlignment];
    
    label = [[NSTextField alloc] initWithFrame:lf];
    label.stringValue = @"#";
    [label setBezelStyle:NSNoBorder];
    [label setBordered:NO];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setAlignment:NSLeftTextAlignment];
    
    [self addSubview:label];
    [self addSubview:text];
    
    return;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<%@ %@ %@>", self.class, value, label];
}

-(void)setEnabled:(BOOL)enabled {
    if (!enabled)
        text.stringValue = @"";
    // do we need to cache its value for a bit ??
    [super setEnabled:enabled];
    [label setEnabled:enabled];
    [text setEnabled:enabled];    
}

-(BOOL)isEnabled {
    return text.isEnabled;
}

- (BOOL)control:(NSControl *)control isValidObject:(id)object {
 
    [value setStringValue:text.stringValue];
    [self update];
    
    [self sendAction:self.action to:self.target]; 
    return YES;
}

-(void)setTextColor:(NSColor *)aTextColor {
    [text setTextColor:aTextColor];
}

-(NSColor *)textColor {
    return text.textColor;
}

-(void)setStringValue:(NSString *)aString 
{
    NSArray * vals = [aString componentsSeparatedByString:@" "];
    
    if (vals.count != 2) {
        [label setStringValue:@""];
        [text setStringValue:aString];
    };
    [label setStringValue:[vals objectAtIndex:1]];
    [text setStringValue:[vals objectAtIndex:0]];
}

-(NSString *)stringValue {
    return [NSString stringWithFormat:@"%@ %@", 
            text.stringValue, label.stringValue];
}

-(ScalarWithUnit *)value { 
    return value; 
}

-(void)setScalarValue:(double)aScalar {
    value.scalar = aScalar;
    [self update];
}

-(double)scalarValue {
    return value.scalar;
}
    
-(void)update {
    [text setStringValue:value.displayStringValue];
    [label setStringValue:value.suffix];        
}

-(void)setValue:(ScalarWithUnit *)aScalarWithUnit {
    value = [aScalarWithUnit retain];
    [self update];
}

-(void)dealloc {
    [value dealloc];
    [text dealloc];
    [label dealloc];
    [super dealloc];
}
@end

