//
//  SomeTabView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 24/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
