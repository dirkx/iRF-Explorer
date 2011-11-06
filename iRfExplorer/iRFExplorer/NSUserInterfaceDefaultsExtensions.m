//
//  NSUserInterfaceDefaultsExtensions.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 03/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSUserInterfaceDefaultsExtensions.h"

@implementation NSUserDefaults(ExtendedTextFieldSupport)

- (void)setScalarWithUnit:(ScalarWithUnit *)view forKey:(NSString *)aKey {
    NSData *theData=[NSArchiver archivedDataWithRootObject:view];
    [self setObject:theData forKey:aKey];
}

- (ScalarWithUnit *)scalarWithUnitForKey:(NSString *)aKey {
    NSData *theData = [self dataForKey:aKey];
    if (theData == nil)
        return nil;
    return (ScalarWithUnit *)[NSUnarchiver unarchiveObjectWithData:theData];
}
@end
