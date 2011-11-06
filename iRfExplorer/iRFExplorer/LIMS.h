//
//  LIMS.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 02/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NamedArray.h"
#import "RFExplorer.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface LIMS : NamedArray

+(id)namedArrayWithDevice:(RFExplorer *)aDevice;
@end
