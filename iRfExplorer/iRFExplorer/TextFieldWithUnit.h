//
//  TextFieldWithUnit.h
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
#import "ScalarWithUnit.h"

@interface TextFieldWithUnit : NSControl <NSTextFieldDelegate> {
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
