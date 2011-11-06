//
//  NotifyingSlider.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 01/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NotifyingSliderCell.h"

@interface NotifyingSlider : NSSlider {
    SEL doneAction;
    id target;
}
@property (assign) SEL doneAction;
@property (assign) id target;
@end
