//
//  SerialDeviceTracker.h
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

#import <Foundation/Foundation.h>
#include <IOKit/serial/IOSerialKeys.h>

#ifndef SERIALTYPE
#  if 1
#    define SERIALTYPE kIOSerialBSDRS232Type /* Normal Serial ports */
#  else
#    define SERIALTYPE kIOSerialBSDAllTypes /* Antying serial - inc. things like modems */
#  endif
#endif

@protocol SerialDeviceTrackerDelegate <NSObject>
@optional
-(void)changeInDevices:(BOOL)deviceAdded 
             withTitle:(NSString*)title 
              withPath:(NSString*)path;
@end

@interface SerialDeviceTracker : NSObject {
    id <SerialDeviceTrackerDelegate> delegate;
    IONotificationPortRef notifyPort ;
	io_iterator_t addDeviceIterator, removeDeviceIterator ;
    
    NSMutableDictionary * devices;
}

@property (retain) NSDictionary * devices;
@property (assign) id <SerialDeviceTrackerDelegate> delegate;

// Rescan all serial ports.
-(void)rescan;

-(void)startNotification;
-(void)stopNotification;

@end
