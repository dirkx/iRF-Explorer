//
//  TextFieldWithUnit.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 30/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "ScalarWithUnit.h"

@interface TextFieldWithUnit : NSControl <NSTextFieldDelegate, NSCoding> {
    id <NSTextFieldDelegate> delegate;
    ScalarWithUnit * value;
    IBOutlet NSTextField * text;
    IBOutlet NSTextField * label;
}

@property (assign) IBOutlet id <NSTextFieldDelegate> delegate;

@property (retain) IBOutlet NSTextField *label;
@property (retain) IBOutlet NSTextField *text;
@property (retain) NSColor * textColor;

@property (retain) ScalarWithUnit * value;
@property (assign) double scalarValue;

@property (assign,getter=isEnabled) BOOL enabled;

-(void)update;
@end
