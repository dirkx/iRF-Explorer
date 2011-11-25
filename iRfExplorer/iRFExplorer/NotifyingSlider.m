//
//  NotifyingSlider.m
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

#import "NotifyingSlider.h"

@implementation NotifyingSlider
@synthesize doneAction;

- (void)viewDidMoveToWindow {
    
    if ([self.cell isKindOfClass:[NotifyingSliderCell class]])
        return;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    NSSliderCell *notifySliderCell = [[[NotifyingSliderCell alloc] init] autorelease];

#if 1
    // Bit scary - as we now prolly forget to copy a whole raft of other stuff too, like
    // tick details, type, colours and so on.
    //
    [notifySliderCell setTarget:[self.cell target]];
    [notifySliderCell setAction:[self.cell action]];
#else
    NSData * settings = [NSKeyedArchiver archivedDataWithRootObject:self.cell];
    [notifySliderCell some merge
#endif
    double val = self.doubleValue;
    [self setCell:notifySliderCell];
    self.doubleValue = val;
    
    // We seem to get called more than once - keep the number of notifications
    // down a wee bit.
    [center removeObserver:self];
    
    [center addObserver:self
               selector:@selector(sliderCellDidEndEditing:)
                   name:kNotifyingSliderCellDidEndEditing
                 object:nil];
    
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
}

// For some reason NSSlider loses track of its target; prolly 
// lost in some Cell optimisation. 
//
-(void)setTarget:(id)aTarget {
    [super setTarget:aTarget];
    target = aTarget;
}

-(id)target {
    return target;
}

// End of that stuff

- (void)sliderCellDidEndEditing:(NSNotification *)msg {
    // This is a bit messy with lots of sliders. Perhaps
    // we should skip the NSNotificationCenter and go
    // for target/actions here too.
    //
    if (msg.object == self.cell) {
        [self sendAction:self.doneAction to:target];
    }
}
@end
