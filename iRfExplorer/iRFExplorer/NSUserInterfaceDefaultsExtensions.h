//
//  NSUserInterfaceDefaultsExtensions.h
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 03/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScalarWithUnit.h"

@interface NSUserDefaults(ExtendedTextFieldSupport)
- (void)setScalarWithUnit:(ScalarWithUnit *)view forKey:(NSString *)aKey;
- (ScalarWithUnit *)scalarWithUnitForKey:(NSString *)aKey;
@end
