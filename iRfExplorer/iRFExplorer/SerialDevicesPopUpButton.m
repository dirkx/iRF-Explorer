//
//  SerialDevicesPopUpButton.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 08/10/2011.
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

#import "SerialDevicesPopUpButton.h"

@implementation SerialDevicesPopUpButton

-(void)setDevices:(NSArray*)titles {
    [self removeAllItems];
    // [self addItemWithTitle:@"none"];
    [self addItemsWithTitles:titles];
    [self synchronizeTitleAndSelectedItem];
}

-(void)changeInDevices:(BOOL)deviceAdded 
             withTitle:(NSString*)title 
              withPath:(NSString*)path 
{
    if (1) NSLog(@"Menu: %@ %@",
                 deviceAdded ? @"Adding" : @"Removing", title);

    if (deviceAdded) {
        [devices setValue:(NSString *)path forKey:(NSString *)title];            
        [super addItemWithTitle:(NSString *)title];
    } else {
        [devices removeObject:(NSString *)title];
        [super removeItemWithTitle:(NSString *)title];
    };    
    // [self synchronizeTitleAndSelectedItem];
}
@end
