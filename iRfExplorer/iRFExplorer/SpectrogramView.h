//
//  SpectrogramView.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 18/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Spectrum.h"
#import "RFExplorer.h"

@interface SpectrogramView : NSView {
    NSBitmapImageRep * imageRep;
    RFExplorer *device;
}
@property (retain) RFExplorer *device;

-(void)addSpectrum:(Spectrum *)newSpectrum;

@end

