//
//  NSViewExtensions.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 25/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (MyExtensions);
- (void)setSubViewsEnabled:(BOOL)enabled;
-(void)drawEmptyRect:(NSRect)dirtyRect;
@end
