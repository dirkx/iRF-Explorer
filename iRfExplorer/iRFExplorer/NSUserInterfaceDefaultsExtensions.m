//
//  NSUserInterfaceDefaultsExtensions.m
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
