//
//  StopPauseView.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 02/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum { NONE, PAUSED, PLAY, PAUSEDSMALL } e_state_t;

@interface StopPauseView : NSView {
    NSDate *lastPausedDate;
    NSUInteger age;
    NSTimer *timer;
    e_state_t state;
}
@property (assign) e_state_t state;
@property (retain) NSDate *lastPausedDate;
-(void)pause:(id)i;
-(void)play:(id)i;
-(void)hide:(id)i;
-(void)toggle:(id)i;
-(BOOL)isPaused;
@end
