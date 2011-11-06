//
//  ConfigView.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 24/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigView.h"
#import "NSStringExtensions.h"
#import "NamedArray.h"
#import "PreferenceConstants.h"
#import "LIMS.h"

@implementation ConfigView

@synthesize infoBandCenterFreq, infoBandMinFreq, infoBandMaxFreq, infoBandSpanFreq, infoBoardTitle, infoBoardMinFreq, infoBoardMaxFreq, infoAttenTop, infoAttenBott, infoDevFirmware, infoDevMain, infoDevExpansion, infoDevBaudrate,  infoAttenMax, infoAttenMin, infoBoardSteps, infoBandApproxRbm;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [NSBundle loadNibNamed:@"ConfigTabView" owner:self];
    return self;
}

-(void)awakeFromNib {
    [self addSubview:_view];
    index = TAB_CONFIG;
}

-(void)setAllControls:(BOOL)on {    
    if (on)
        return;
    
    infoBandCenterFreq.stringValue = @"";
    infoBandMinFreq.stringValue = @"";
    infoBandMaxFreq.stringValue = @"";
    infoBandSpanFreq.stringValue = @"";
    infoBandApproxRbm.stringValue = @"";
    
    infoAttenTop.stringValue = @"";
    infoAttenBott.stringValue = @"";
    infoAttenMax.stringValue = @"";
    infoAttenMin.stringValue = @"";
    
    infoDevFirmware.stringValue = @"";
    infoDevMain.stringValue = @"";
    infoDevExpansion.stringValue = @"";
    infoDevBaudrate.stringValue = @"";
    
    infoBoardTitle.stringValue = @"";
    infoBoardMinFreq.stringValue = @"";
    infoBoardMaxFreq.stringValue = @"";
    infoBoardSteps.stringValue = @"";
}

-(void)newConfig:(id)sender {
    if (device == nil) {
        [self setAllControls:FALSE];
        return;
    };

    if (device.hasC2F) {
        infoBandMinFreq.stringValue = [NSString stringFromHz:device.fStartHz];
        infoBandMaxFreq.stringValue = [NSString stringFromHz:device.fEndHz];
        infoBandCenterFreq.stringValue = [NSString stringFromHz:device.fCenterHz];
        infoBandSpanFreq.stringValue = [NSString stringFromHz:device.fSpanHz];
        
        // http://groups.google.com/group/rf-explorer/browse_frm/thread/bcf2711c40e12993
        infoBandApproxRbm.stringValue =[NSString stringFromHz:device.fStepHz]; // approx
        
        infoAttenTop.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeTop];
        infoAttenBott.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeBottom];
        infoAttenMax.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeMax];
        infoAttenMin.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeMin];
    }
    
    // Check if we have C2-M info. If not - rely on
    // the app delegate whe/if to (re) request it.
    
    if (device.hasC2M && device.hasC2F) {
        infoBoardTitle.stringValue = device.expansionBoardActive ? device.expansionBoard : device.mainBoard;
        infoBoardMinFreq.stringValue = [NSString stringFromHz:device.fMinFreqHz];
        infoBoardMaxFreq.stringValue = [NSString stringFromHz:device.fMaxFreqHz];
        infoBoardSteps.stringValue = [NSString stringWithFormat:@"%d", device.nFreqSpectrumSteps];
    }
}

-(void)newBoard:(id)sender {
    if (device == nil) {
        [self setAllControls:FALSE];
        return;
    };

    // Check if we have C2-M info. If not - rely on
    // the app delegate whe/if to (re) request it.
    //
    if (!device.hasC2M)
        return;

    infoDevMain.stringValue = device.mainBoard;
    infoDevFirmware.stringValue = device.firmware;
    infoDevBaudrate.stringValue = device.commsSpeedAsString;    
    infoDevExpansion.stringValue = device.expansionBoard ? device.expansionBoard : @"none";
}

-(NSString *)descriptionWithFormat:(format_t)format {    
    // We expect the various labels and what not to be ready for this
    // cut-and-paste construction. I.e. in the desired order; and in
    // key/value for the fields. _views is really self.subviews its
    // first/only object. We do it this way so we pick up translations
    // of sorts where apprioriate.
    //
    NSMutableArray * info = [NSMutableArray array];
    
    for(NSView  * group in _view.subviews) {
        if (![group isKindOfClass:[NSBox class]]) {
            NSLog(@"Expect a NSBox - got a %@, ignoring. See code.", group);
            continue;
        }
        NamedArray * arr = [[[NamedArray alloc] initWithTitle:((NSBox *)group).title] autorelease];;
        
        int i = 0;
        for(NSView * v in group.subviews) {
            // skip this layer - it is used by the inside alignment box.
            //
            NSString * t = @"";
            for(NSView * item in v.subviews) {
                if (![item isKindOfClass:[NSTextField class]]) {
                    NSLog(@"Expect a NSTextField - got a %@, ignoring. See code.", item);
                    continue;
                };
                NSString * v = ((NSTextField *)item).stringValue;
                if (i & 1) 
                    [arr addValue:v withTitle:t];
                t = v;
                i++;
            }
        }
        if (arr.count)
            [info addObject:arr];
    };

    NamedArray * lims = [LIMS namedArrayWithDevice:device];
    if (lims)
        [info addObject:lims];

    return [NamedArray descriptionFromArray:info withTitle:device.activeBoard withFormat:format];
}

-(void)addToPasteboard:(NSPasteboard*)pasteBoard 
{
    BOOL latex = [[[NSUserDefaults standardUserDefaults] valueForKey:kPreferenceLatexOverTsv] boolValue];

    [super addToPasteboard:pasteBoard];

    NSString * type = latex ? NSPasteboardTypeString : NSPasteboardTypeTabularText;
    [pasteBoard addTypes:[NSArray arrayWithObjects:
                          type,
                          nil]
                   owner:self];

    [pasteBoard setString:[self descriptionWithFormat:latex ? FORMAT_LATEX : FORMAT_TSV] 
                forType:type];
    
    if (!latex) {
        [pasteBoard addTypes:[NSArray arrayWithObjects:
                              NSPasteboardTypeString,
                              nil]
                       owner:self];
        [pasteBoard setString:[self descriptionWithFormat:FORMAT_PLAIN] 
                      forType:NSPasteboardTypeString];
    }
}

- (IBAction) print:(id)sender
{
    NSTextView * tv = [[NSTextView alloc] initWithFrame:NSMakeRect(0,0, 300,600)];
    [tv setString:[self descriptionWithFormat:FORMAT_PLAIN]];
    [self printView:tv];
    [tv release];
}
@end
