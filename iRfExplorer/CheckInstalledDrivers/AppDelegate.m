//
//  AppDelegate.m
//  CheckInstalledDrivers
//
//  Created by Dirk-Willem van Gulik on 01-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize doneButton, result1, result2, result3, retryButton, skipButton;
@synthesize ok1, ok2, ok3, okFinal;
@synthesize fail1, fail2, fail3;

-(IBAction)done:(id)sender {
    [NSApp terminate:self];
}

-(IBAction)check:(id)sender {
    [result1 setHidden:TRUE];
    [result2 setHidden:TRUE];
    [result3 setHidden:TRUE];

    [ok1 setHidden:TRUE];
    [ok2 setHidden:TRUE];
    [ok3 setHidden:TRUE];
    [okFinal setHidden:TRUE];

    [fail1 setHidden:TRUE];
    [fail2 setHidden:TRUE];
    [fail3 setHidden:TRUE];

    [doneButton setHidden:TRUE];
    [retryButton setHidden:TRUE];
    [skipButton setHidden:TRUE];

    NSString *script = [[NSBundle mainBundle] pathForResource:@"checks"
                                                       ofType:@"sh"];

    NSLog(@"Running validation shell script '%@'", script);
    int e = system([script cStringUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"Validation returned: %d", WEXITSTATUS(e));
    
    switch (WEXITSTATUS(e)) {
        case 1:
            [fail1 setHidden:FALSE];
            [result1 setHidden:FALSE];
            break;
        case 2:
            [fail2 setHidden:FALSE];
            [ok1 setHidden:FALSE];
            [result2 setHidden:FALSE];
            break;
        case 3:
            [fail3 setHidden:FALSE];
            [ok1 setHidden:FALSE];
            [ok2 setHidden:FALSE];
            [result3 setHidden:FALSE];
            break;
        case 0:
            [ok1 setHidden:FALSE];
            [ok2 setHidden:FALSE];
            [ok3 setHidden:FALSE];
            [okFinal setHidden:FALSE];
            break;
    };
            
    if (WEXITSTATUS(e) == 0) {
        [doneButton setHidden:FALSE];
    }  else {
        [retryButton setHidden:FALSE];
        [skipButton setHidden:FALSE];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self check:self];
}
@end
