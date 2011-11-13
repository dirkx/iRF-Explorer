//
//  SomeTabView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 24/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SomeTabView.h"
#import "PreferenceConstants.h"
#import "NSViewExtensions.h"

@implementation SomeTabView
@synthesize device,index;
@synthesize _view, backgroundColor;

-(void)awakeFromNib {
    [self addSubview:_view];
    index = TAB_NONE;
    self.backgroundColor = nil;
}

-(void)printView:(NSView *)view {
    NSPrintInfo *printInfo;
    NSPrintOperation *printOp;
    printInfo = [NSPrintInfo sharedPrintInfo];
    
    [printInfo setHorizontalPagination: NSFitPagination];
    [printInfo setVerticalPagination: NSFitPagination];
    
    // obnoxious or useful ?
    // [printInfo setOrientation:  NSLandscapeOrientation];
    // [printInfo setScalingFactor:1.0]; - or do we give the user control or max it to page-printborders and a few percent ?
    
    [printInfo setVerticallyCentered:YES];
    [printInfo setHorizontallyCentered:YES];
    
    printOp = [NSPrintOperation printOperationWithView:view printInfo:printInfo];
    
    [printOp setShowsPrintPanel:YES];
    [printOp setShowsProgressPanel:YES];
    
    [printOp runOperation];    
}

- (IBAction) print:(id)sender
{
    [self printView:self];
}

-(void)addView:(NSView *)aView toPasteboard:(NSPasteboard*)pasteBoard 
{
    BOOL png = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferencePngOverPdf] boolValue];
    BOOL txt = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceNoImages] boolValue];

    if (txt)
        return;    
    
    if (png) {
        NSBitmapImageRep *rep =  [aView bitmapImageRepForCachingDisplayInRect:[aView bounds]];
        [self cacheDisplayInRect:[aView bounds] toBitmapImageRep:rep];
        [pasteBoard setData:[rep representationUsingType:NSPNGFileType properties:nil] 
                    forType:NSPasteboardTypePNG];
    } else {
        [pasteBoard addTypes:[NSArray arrayWithObjects:
                              NSPasteboardTypePDF,
                              nil]
                       owner:self];
        
        [aView writePDFInsideRect:aView.bounds
                     toPasteboard:pasteBoard];
    };
}

-(void)addToPasteboard:(NSPasteboard*)pasteBoard 
{
    [self addView:self toPasteboard:pasteBoard];
}

-(void)newConfig:(id)sender {
    [self setNeedsDisplay:YES];
}

-(void)setAllControls:(BOOL)on {
    [self setSubViewsEnabled:on];
}

-(void)newBoard:(id)sender {
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (device)
        return;

    if (index != TAB_SPECTROGRAM && index != TAB_SPECTRUM)
        return;
    
    [self drawEmptyRect:dirtyRect];
}

@end
