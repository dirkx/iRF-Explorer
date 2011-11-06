//
//  NotifyingSliderCell.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 01/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotifyingSliderCell.h"

@implementation NotifyingSliderCell

- (void)stopTracking:(NSPoint)last at:(NSPoint)end inView:(NSView *)ctrl mouseIsUp:(BOOL)up
{
    /// Hmm - this means we're sending to all.. perhaps better to do a action/target pair ?
    //
    if (up) 
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyingSliderCellDidEndEditing
                          object:self];

    [super stopTracking:last at:end inView:ctrl mouseIsUp:up];
}
@end
