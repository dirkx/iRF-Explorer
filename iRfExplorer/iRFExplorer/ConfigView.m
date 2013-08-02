//
//  ConfigView.m
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
    
    NSString * noVal = NSLocalizedString(@"<none>", @"No data yet value");
                                         
    infoBandCenterFreq.stringValue =noVal;
    infoBandMinFreq.stringValue = noVal;
    infoBandMaxFreq.stringValue = noVal;
    infoBandSpanFreq.stringValue = noVal;
    infoBandApproxRbm.stringValue = noVal;
    
    infoAttenTop.stringValue = noVal;
    infoAttenBott.stringValue = noVal;
    infoAttenMax.stringValue = noVal;
    infoAttenMin.stringValue = noVal;
    
    infoDevFirmware.stringValue = noVal;
    infoDevMain.stringValue = noVal;
    infoDevExpansion.stringValue = noVal;
    infoDevBaudrate.stringValue = noVal;
    
    infoBoardTitle.stringValue = noVal;
    infoBoardMinFreq.stringValue = noVal;
    infoBoardMaxFreq.stringValue = noVal;
    infoBoardSteps.stringValue = noVal;
}

-(void)newConfig:(id)sender {
    if (device == nil) {
        [self setAllControls:FALSE];
        return;
    };

    if (device.hasReceivedC2FReply) {
        infoBandMinFreq.stringValue = [NSString stringFromHz:device.fStartHz];
        infoBandMaxFreq.stringValue = [NSString stringFromHz:device.fEndHz];
        infoBandCenterFreq.stringValue = [NSString stringFromHz:device.fCenterHz];
        infoBandSpanFreq.stringValue = [NSString stringFromHz:device.fSpanHz];
        
        // http://groups.google.com/group/rf-explorer/browse_frm/thread/bcf2711c40e12993
        // However observed in the wild:
        // On 2.4Ghz - display 50k; shown  17.857k
        // On Sub1G - display 600k; shown 892.57 k
        //
        infoBandApproxRbm.stringValue =[NSString stringFromHz:device.fStepHz]; // approx
        
        infoAttenTop.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeTop];
        infoAttenBott.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeBottom];
        infoAttenMax.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeMax];
        infoAttenMin.stringValue = [NSString stringWithFormat:@"%.1f dBm", device.fAmplitudeMin];
    }
    
    // Check if we have C2-M info. If not - rely on
    // the app delegate whe/if to (re) request it.
    
    if (device.hasReceivedC2MReply && device.hasReceivedC2FReply) {
        infoBoardTitle.stringValue = device.expansionBoardActive ? device.expansionBoard : device.mainBoard;
        infoBoardMinFreq.stringValue = [NSString stringFromHz:device.fMinFreqHz];
        infoBoardMaxFreq.stringValue = [NSString stringFromHz:device.fMaxFreqHz];
        infoBoardSteps.stringValue = [NSString stringWithFormat:@"%lu", device.nFreqSpectrumSteps];
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
    if (!device.hasReceivedC2MReply)
        return;

    infoDevMain.stringValue = device.mainBoard;
    infoDevFirmware.stringValue = device.firmware;
    infoDevBaudrate.stringValue = device.commsSpeedAsString;    
    infoDevExpansion.stringValue = device.expansionBoard ? device.expansionBoard : NSLocalizedString(@"none", @"Shown when an expansion board is not present");
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
