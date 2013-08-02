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

-(void)saveDocumentAs:(NSView *)view {
    NSArray * fileFormats = @[
                              @{
                                  @"title" : @"Comma Separated Values",
                                  @"exts" : @[ @"csv" ],
                                  @"method": @"dataAsCSV:",
                                  },
                              @{
                                  @"title" : @"Tab Separated Values",
                                  @"exts" : @[ @"tsv" ],
                                  @"method": @"dataAsTSV:",
                                  },
                              @{
                                  @"title" : @"Latex table",
                                  @"exts" : @[ @"tex" ],
                                  @"method": @"dataAsLatex:",
                                  },
                              @{
                                  @"title" : @"Portable Network Graphics format",
                                  @"exts" : @[ @"png" ],
                                  },
                              @{
                                  @"title" : @"Tagged Image File Format",
                                  @"exts" : @[ @"tif", @"tiff" ],
                                  },
                              @{
                                  @"title": @" Joint Photographic Experts Group format",
                                  @"exts" : @[ @"jpg", @"jpeg" ],
                                  },
                              @{
                                  @"title": @"Graphics Interchange Format",
                                  @"exts" : @[ @"gif" ],
                                  },
                              @{
                                  @"title" : @"Portable Document format",
                                  @"exts" : @[ @"pdf" ],
                                  }
                              ];
    
    NSSavePanel *savepanel = [NSSavePanel savePanel];
    savepanel.title = @"Save as Image";

    float w = savepanel.frame.size.width-48;
    float wL = MIN(100,MAX(120, w *0.3));
    float wR = MAX(180,w - wL - 28);
    
    float h  =24;
    
    NSTextField * fileFormatLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, wL, h)];
    fileFormatLabel.stringValue = @"File format:";

    [fileFormatLabel setBezeled:NO];
    [fileFormatLabel setDrawsBackground:NO];
    [fileFormatLabel setEditable:NO];
    [fileFormatLabel setSelectable:NO];
    [fileFormatLabel setAlignment:NSRightTextAlignment];

    NSPopUpButton * pulldownView = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(wL +12, 0, wR, h) pullsDown:YES];
    [pulldownView setAutoenablesItems:NO];
    
    [pulldownView addItemWithTitle:@""];
    
    NSMutableArray * allowedFileTypes = [NSMutableArray arrayWithCapacity:20];
    for(NSDictionary * info in fileFormats) {
        
        NSString * title = [info valueForKey:@"title"];
        NSArray * exts = [info valueForKey:@"exts"];
        for(int i = 0; i < [exts count]; i++) {
            title = [NSString stringWithFormat:@"%@%@%@%@",
                     title,
                     i == 0 ? @" (" : @", ",
                     [exts objectAtIndex:i],
                     i == [exts count] -1 ? @")." : @""
                     ];
        };
        [allowedFileTypes addObjectsFromArray:exts];
        [pulldownView addItemWithTitle:title];

        // grey out stuff we cannot do.
        //
        if ([info valueForKey:@"method"])
            if (![self respondsToSelector:NSSelectorFromString([info valueForKey:@"method"])])
                [[pulldownView itemAtIndex:[pulldownView.itemArray count]-1] setEnabled:FALSE];
    };
    
    NSView * fileFormatView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, w, h)];
    [fileFormatView addSubview:fileFormatLabel];
    [fileFormatView addSubview:pulldownView];

    [savepanel setAccessoryView:fileFormatView];
        
    [savepanel setAllowedFileTypes:allowedFileTypes];
    
    [savepanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
     {
         if (NSFileHandlingPanelOKButton == result)
         {
             NSURL* fileURL = [savepanel URL];
             NSString * extension = fileURL.pathExtension;
             NSInteger formatIdx = pulldownView.indexOfSelectedItem - 1;
             
             if (formatIdx == -1) {
                 // See if we can recognize the extension.
                 for(int i  =0; formatIdx == -1 && i < [fileFormats count]; i++ )
                     for(NSString * s in [[fileFormats objectAtIndex:i] valueForKey:@"exts"])
                         if ([extension caseInsensitiveCompare:s]) {
                             formatIdx = i;
                             break;
                         }
             }
             if (formatIdx == -1)
                 formatIdx = 0; // defaulting to first one on the list.
             
             NSDictionary * info = [fileFormats objectAtIndex:formatIdx];
             NSString * mainExtension = [[info valueForKey:@"exts"] objectAtIndex:0];
             
             if ([extension isEqualToString:@""]) {
                 extension = mainExtension;
                 fileURL = [fileURL URLByAppendingPathExtension:mainExtension];
             }
             else if ([fileURL.pathExtension caseInsensitiveCompare:mainExtension] != NSOrderedSame) {
                     NSAlert *alert = [[NSAlert alloc] init];
                     [alert addButtonWithTitle:[NSString stringWithFormat:@"Change to .%@", mainExtension]];
                     [alert addButtonWithTitle:[NSString stringWithFormat:@"Keep .%@", extension]];
                     [alert addButtonWithTitle:@"Cancel"];
                     [alert setMessageText:@"Extension not matching format"];
                     [alert setInformativeText:[NSString stringWithFormat:@"The file format (%@) selected usually has the extension '.%@'. This is not the same as the file-name extension (.%@) currently used. Do you want to correct this?",
                                                [info valueForKey:@"title"],
                                                mainExtension,
                                                extension]];
                     [alert setAlertStyle:NSWarningAlertStyle];
                     
                     switch([alert runModal]) {
                         case NSAlertFirstButtonReturn:
                             fileURL = [[fileURL URLByDeletingPathExtension] URLByAppendingPathExtension:mainExtension];
                             extension = mainExtension;
                             break;
                         case NSAlertSecondButtonReturn:
                             break;
                         default:
                             // otherwise we'll abort.
                             return;
                     }
                 };
         
             NSData * data;
         
             if ([info objectForKey:@"method"])
                 data = [self performSelector:NSSelectorFromString([info valueForKey:@"method"])];
             else if ([extension isEqualToString:@"pdf"]) {
                 data = [self dataWithPDFInsideRect:self.bounds];
             } else {
                 [self lockFocus];
                 NSBitmapImageRep * rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
                 [self unlockFocus];

                 if ([extension isEqualToString:@"jpg"])
                     data = [rep representationUsingType:NSJPEGFileType properties:nil];
                 else if ([extension isEqualToString:@"tif"])
                     data = [rep representationUsingType:NSTIFFFileType properties:nil];
                 else if ([extension isEqualToString:@"gif"])
                     data = [rep representationUsingType:NSGIFFileType properties:nil];
                 else
                     data = [rep representationUsingType:NSPNGFileType properties:nil];
             }

             [data writeToURL:fileURL atomically:YES];
         }
         
     }];
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
