//
//  AppDelegate.h
//  CheckInstalledDrivers
//
//  Created by Dirk-Willem van Gulik on 01-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *result1;
@property (assign) IBOutlet NSTextField *result2;
@property (assign) IBOutlet NSTextField *result3;

@property (assign) IBOutlet NSTextField *ok1;
@property (assign) IBOutlet NSTextField *ok2;
@property (assign) IBOutlet NSTextField *ok3;
@property (assign) IBOutlet NSTextField *okFinal;

@property (assign) IBOutlet NSTextField *fail1;
@property (assign) IBOutlet NSTextField *fail2;
@property (assign) IBOutlet NSTextField *fail3;

@property (assign) IBOutlet NSButton *skipButton, * retryButton, * doneButton;

-(IBAction)done:(id)sender;
@end
