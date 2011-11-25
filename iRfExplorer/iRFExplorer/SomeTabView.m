//
//  SomeTabView.m
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
