//
//  SomeTabView.h
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
#import "RFExplorer.h"

typedef enum {
    TAB_SPECTRUM = 0, TAB_SCREEN, TAB_SPECTROGRAM, TAB_CONFIG, TAB_NONE=255
} tab_t;

// We'll prolly change to a proper NSViewController at some
// point. I.e. when the MVC in the appDelegate gets too 
// painful. But we'r holding off as we end up passing defaults,
// device and spectrum data all over the place otherwise.
//
@interface SomeTabView : NSView {
    RFExplorer *device;
    IBOutlet NSView * _view;
    tab_t index;
    NSColor *backgroundColor;
}

@property (retain) RFExplorer *device;
@property (retain) IBOutlet NSView * _view;
@property (retain) NSColor *backgroundColor;
@property (assign) tab_t index;

-(void)newConfig:(id)sender;
-(void)setAllControls:(BOOL)on;
-(void)newBoard:(id)sender;

-(void)addView:(NSView *)aView toPasteboard:(NSPasteboard*)pasteBoard;
-(void)addToPasteboard:(NSPasteboard*)pasteBoard;
-(void)printView:(NSView *)view;

@end
