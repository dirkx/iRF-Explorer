//
//  StopPauseView.m
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

#import "StopPauseView.h"

@implementation StopPauseView
@synthesize lastPausedDate;

#define SMALLSIZE (32.0)
#define MAXSIZE (64.0)

- (void)animate:(NSDictionary *)dict duration:(double)duration
{
    // firstView, secondView are outlets
    NSViewAnimation *theAnim;
        
    // Create the view animation object.
    theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
    
    [theAnim setDuration:duration]; 
    [theAnim setAnimationCurve:NSAnimationEaseIn];
    
    [theAnim startAnimation];
    [theAnim autorelease];
}

- (void)scaleIntoCorner
{
    // firstView, secondView are outlets
    NSRect f;
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [dict setObject:self forKey:NSViewAnimationTargetKey];
    
    [dict setObject:[NSValue valueWithRect:self.frame]
             forKey:NSViewAnimationStartFrameKey];
    
    f = self.superview.frame;
    
    f.origin.x += 0;
    f.origin.y += -32; // XXX - a bit odd.
    f.size.width = SMALLSIZE + 100; // fit the time string too.
    f.size.height = SMALLSIZE;
    
    [dict setObject:[NSValue valueWithRect:f]
             forKey:NSViewAnimationEndFrameKey];
    
    [self animate:dict  duration:0.4];
}

-(void)fadeOut {
    [self animate:[NSDictionary dictionaryWithObjectsAndKeys:
            self, NSViewAnimationTargetKey,
            NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, 
            nil] duration:0.5
     ];
}

-(void)fadeIn {
    [self animate:[NSDictionary dictionaryWithObjectsAndKeys:
                   self, NSViewAnimationTargetKey,
                   NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, 
                   nil] duration:0.1
     ];
}
-(void)setState:(e_state_t)aState {
    [timer invalidate];
    if (timer) {
        [timer release];
        timer = nil;
    }

    if (self.shadow == nil) {
        self.shadow = [[[NSShadow alloc] init] autorelease];
        [self.shadow setShadowColor:[NSColor blackColor]];
        [self.shadow setShadowBlurRadius:2];
        [self.shadow setShadowOffset:NSMakeSize(1,-1)];
    };
    
    double s = MIN(0.4 * MIN(self.superview.frame.size.width, self.superview.frame.size.height), MAXSIZE);
    NSRect f;
    f.origin.x = self.superview.bounds.origin.x + self.superview.bounds.size.width/2 - s/2 - 4;
    f.origin.y = self.superview.bounds.origin.y + self.superview.bounds.size.height/2 - s/2 - 4;
    f.size.width = f.size.height = s+8;
    switch (aState) {
        case NONE:
            [self fadeOut];
            break;
        case PLAY:
            self.frame = f;
            if (state == NONE)
                [self fadeIn];
            timer = [[NSTimer timerWithTimeInterval:0.5
                                            target:self
                                          selector:@selector(hide:) 
                                          userInfo:nil
                                           repeats:NO] retain];
            break;
        case PAUSED:
            self.frame = f;            
            if (state == NONE)
                [self fadeIn];
            timer = [[NSTimer timerWithTimeInterval:1.5
                                            target:self
                                          selector:@selector(scaledown:) 
                                          userInfo:nil
                                           repeats:NO] retain];
            self.lastPausedDate = [NSDate date];
            age = 0; 
            break;
        case PAUSEDSMALL: 
            if (state == NONE)
                [self fadeIn];
            [self scaleIntoCorner];
            
            double d = 0;
            switch(age) {
                case 0: d = 100;    // show time after 2 minuteish
                    break;
                case 1: d = 3600*20; // show date too after about a day.
                    break;
            };
            if (d) {
                timer = [[NSTimer timerWithTimeInterval:d
                                                target:self
                                              selector:@selector(scaledown:) 
                                              userInfo:nil
                                               repeats:NO] retain];
            };
            age++;
            break;
        default:
            assert(1==2);
            break;
    }
    if (timer) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        // NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
        
        [runLoop addTimer:timer 
                  forMode:NSDefaultRunLoopMode];
#if 0
        [runLoop addTimer:timer 
                  forMode:NSEventTrackingRunLoopMode];
        [runLoop addTimer:timer 
                  forMode:NSRunLoopCommonModes];
#endif
    }
    state = aState;
    [self setNeedsDisplay:YES];
}

-(e_state_t)state { 
    return state;
}

-(void)scaledown:(id)n {
    self.state = PAUSEDSMALL;
}

-(void)pause:(id)n {
    self.state = PAUSED;
}

-(void)play:(id)n {
    self.state = PLAY;
}

-(void)hide:(id)n {
    self.state = NONE;
}

-(BOOL)isPaused {
    return self.state == PAUSED || self.state == PAUSEDSMALL;
};

-(void)toggle:(id)i {
    if ([self isPaused]) 
        self.state = PLAY;
    else
        self.state = PAUSED;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect f = self.bounds;
    
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];

    CGContextSetRGBFillColor (ctx, 0,0,0,0);
    CGContextFillRect(ctx,NSRectToCGRect(f));

    if (state == NONE)
        return;
    
    if (state != PAUSEDSMALL)
        [self.shadow set];

    CGContextSetRGBFillColor (ctx, 0.6,0.6,0.6,
                              (state != PAUSEDSMALL) ? 0.7 : 0.9);
    
    double sr = MIN(f.size.width, f.size.height)/2 - 8;
    double ox = f.origin.x + ((state != PAUSEDSMALL) ? f.size.width / 2 : (sr + 2));
    double oy = f.origin.y + f.size.height/2;
    
    double s = 2*sr*0.3;

    CGContextMoveToPoint(   ctx, ox-sr, oy);
    CGContextAddArc(ctx, ox, oy, sr, 0, 2 * M_PI, 0);

    if (state == PLAY) {        
        CGContextMoveToPoint(   ctx, ox-s*0.7, oy-s);
        CGContextAddLineToPoint(ctx, ox-s*0.7, oy+s),
        CGContextAddLineToPoint(ctx, ox+s    , oy);

        CGContextClosePath(ctx);
        CGContextFillPath(ctx);        
    };
    if (state == PAUSED || state == PAUSEDSMALL) {
        double ss = s* 0.5;// bar width
        double m = s * 0.25; // spacing
        
        CGContextMoveToPoint(   ctx, ox-m,    oy-s);
        CGContextAddLineToPoint(ctx, ox-m-ss, oy-s);
        CGContextAddLineToPoint(ctx, ox-m-ss, oy+s);
        CGContextAddLineToPoint(ctx, ox-m,    oy+s);
        CGContextAddLineToPoint(ctx, ox-m   , oy-s);

        CGContextMoveToPoint(   ctx, ox+m,    oy-s);
        CGContextAddLineToPoint(ctx, ox+m,    oy+s);
        CGContextAddLineToPoint(ctx, ox+m+ss, oy+s);
        CGContextAddLineToPoint(ctx, ox+m+ss, oy-s);
        CGContextAddLineToPoint(ctx, ox+m   , oy-s);

        CGContextClosePath(ctx);
        CGContextFillPath(ctx);        
        
        NSDateFormatter * ndf = [[[NSDateFormatter alloc] init] autorelease];
        NSString * date = nil;
        switch(age) {
            case 0:
                // do not show anyting immediately.
            case 1:
                // do not show anyting when we've just been scaled into the corner (yet).
                break;
            case 2:
                // show just time time a few minutes later.
                [ndf setDateStyle:NSDateFormatterNoStyle];
                [ndf setTimeStyle:NSDateFormatterShortStyle];
                date = [ndf stringFromDate:lastPausedDate];
                break;
            default:
                // include date if it was a really long time ago.
                [ndf setDateStyle:NSDateFormatterShortStyle];
                [ndf setTimeStyle:NSDateFormatterShortStyle];
                date = [ndf stringFromDate:lastPausedDate];
                break;
        }
        if (date) {
            NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSColor colorWithDeviceWhite:0.4
                                                           alpha:0.8],
                                   NSForegroundColorAttributeName, 
                                   nil];

            [date drawAtPoint:NSMakePoint(ox+s*2-1.0,oy-s-2.0) withAttributes:attr];
        }
    }
}

-(void)dealloc {
    [super dealloc];
    if (timer) 
        [timer release];
    self.lastPausedDate = nil;
}
@end
