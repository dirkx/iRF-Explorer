//
//  SerialDeviceTracker.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 06/10/2011.
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

#import "SerialDeviceTracker.h"

@implementation SerialDeviceTracker
@synthesize devices;

- (id)init
{
    self = [super init];
    if (!self) 
        return nil;
    
    self.devices = [NSMutableDictionary dictionaryWithCapacity:5];
    return self;
}

-(void)rescan {
	io_iterator_t serialDeviceIterator ;
	io_object_t serial ;
    mach_port_t bus ;
    
    CFMutableDictionaryRef matches ;
    
    if (IOMasterPort( MACH_PORT_NULL, &bus ) != KERN_SUCCESS ) 
        return;
	
    if (!(matches = IOServiceMatching( kIOSerialBSDServiceValue )))
        return;
    
	CFDictionarySetValue( matches, CFSTR(kIOSerialBSDTypeKey), CFSTR(SERIALTYPE) ) ;
    
    if (IOServiceGetMatchingServices( bus, matches, &serialDeviceIterator ))
        return;
    
    NSMutableDictionary * devicesFound = [NSMutableDictionary dictionaryWithCapacity:10];
    
	while ( ( serial = IOIteratorNext( serialDeviceIterator ) ) ) {
        
        CFStringRef streamName = IORegistryEntryCreateCFProperty( serial, CFSTR(kIOTTYDeviceKey), kCFAllocatorDefault, 0 );
        CFStringRef pathName = IORegistryEntryCreateCFProperty( serial, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0 );
        if (streamName && pathName) {
            [devicesFound setValue:(NSString *)pathName forKey:(NSString *)streamName];            
		};
        if (streamName) 
            CFRelease(streamName);
        if (pathName)
            CFRelease(pathName);
        
        IOObjectRelease( serial ) ;
    }
	IOObjectRelease( serialDeviceIterator ) ;

    if ([self.devices isEqualToDictionary:devicesFound])
        return;
    
    for(NSString * title in self.devices) {
        if (![devicesFound objectForKey:title]) 
            [delegate changeInDevices:NO 
                            withTitle:title 
                             withPath:nil];
    }

    for(NSString * title in devicesFound) {
        if (![devices objectForKey:title])
            [delegate changeInDevices:YES 
                            withTitle:title 
                             withPath:[devicesFound objectForKey:title]];
    }
    
    self.devices = devicesFound;
}

-(void)setDelegate:(id<SerialDeviceTrackerDelegate>)newDelegate {
    [self stopNotification];
    
    if (delegate != newDelegate) {
        [delegate release];
        delegate = [newDelegate retain];
    };
    
    [self rescan];
    [self startNotification];
}

-(id<SerialDeviceTrackerDelegate>)delegate {
    return delegate;
}

// Ensure we get informed about SerialBSD device (un)pluggin.
//
-(void)changeInDevices:(BOOL)deviceAdded iterator:(io_iterator_t)iterator {
    // we're not being very sophisticated right now..
    //
    io_object_t serial ;
    while ((serial = IOIteratorNext( iterator ))) {
        CFStringRef streamName = IORegistryEntryCreateCFProperty( serial, CFSTR(kIOTTYDeviceKey), kCFAllocatorDefault, 0 );
        CFStringRef pathName = IORegistryEntryCreateCFProperty( serial, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0 );
        if (streamName && pathName) {
            [delegate changeInDevices:deviceAdded 
                            withTitle:(NSString*)streamName 
                             withPath:(NSString*)pathName];
            if (deviceAdded)
                [devices setValue:(NSString*)pathName forKey:(NSString*)streamName];
            else
                [devices removeObjectForKey:(NSString*)streamName];
        };
        if (streamName) 
            CFRelease(streamName);
        if (pathName)
            CFRelease(pathName);
       IOObjectRelease( serial ) ;
    };
}

//  callback notification when device added
static void deviceAdded(void *refcon, io_iterator_t iterator )
{
	io_object_t modemService ;
	
	if ( refcon ) [ (SerialDeviceTracker*)refcon changeInDevices:YES iterator:iterator ] ;
    else {
		while ((modemService = IOIteratorNext( iterator ))) {
            IOObjectRelease( modemService ) ;
        };
	};
}

static void deviceRemoved(void *refcon, io_iterator_t iterator )
{
	io_object_t modemService ;
	
	if ( refcon ) [ (SerialDeviceTracker*)refcon changeInDevices:NO iterator:iterator ] ;
    else {
		while ((modemService = IOIteratorNext( iterator ))) {
            IOObjectRelease( modemService ) ;
        }
	}
}

- (void)startNotification
{
	CFMutableDictionaryRef matchingDict ;
	
	notifyPort = IONotificationPortCreate( kIOMasterPortDefault ) ;
	CFRunLoopAddSource( CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource( notifyPort ), kCFRunLoopDefaultMode ) ;
    
	matchingDict = IOServiceMatching( kIOSerialBSDServiceValue ) ;
	CFRetain( matchingDict ) ;
	CFDictionarySetValue( matchingDict, CFSTR(kIOSerialBSDTypeKey), CFSTR( SERIALTYPE ) ) ;
	
	IOServiceAddMatchingNotification( notifyPort, kIOFirstMatchNotification, matchingDict, deviceAdded, self, &addDeviceIterator ) ;
	deviceAdded( nil, addDeviceIterator ) ;
    
	IOServiceAddMatchingNotification( notifyPort, kIOTerminatedNotification, matchingDict, deviceRemoved, self, &removeDeviceIterator ) ;
	deviceRemoved( nil, removeDeviceIterator ) ;	
}

- (void)stopNotification
{
	if ( addDeviceIterator ) {
		IOObjectRelease( addDeviceIterator ) ;
		addDeviceIterator = 0 ; 
	}
	
	if ( removeDeviceIterator ) {
		IOObjectRelease( removeDeviceIterator ) ;
		removeDeviceIterator = 0 ;
	}
	if ( notifyPort ) {
		CFRunLoopRemoveSource( CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource( notifyPort ), kCFRunLoopDefaultMode ) ;
		IONotificationPortDestroy( notifyPort ) ;
		notifyPort = nil ;
	}
}

- (void)dealloc {
    [self stopNotification];
    self.devices = nil;
    [super dealloc];
}
@end
