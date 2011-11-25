//
//  StopPauseView.h
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
