//
//  LIMS.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 02/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LIMS.h"
#import "PreferenceConstants.h"

@implementation LIMS

+(id)namedArrayWithDevice:(RFExplorer *)aDevice;
{
    
    LIMS * lims = [[[LIMS alloc] initWithTitle:@"Logbook information"] autorelease];

    if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceLimsIncludeSettings] boolValue]) {
        [lims addValue:[NSString stringWithFormat:@"%.2f",aDevice.fStartHz/1e6] withTitle:@"Frequency from (Mhz)"];
        [lims addValue:[NSString stringWithFormat:@"%.2f",aDevice.fEndHz/1e6] withTitle:@"Frequency until (Mhz)"];
        [lims addValue:[NSString stringWithFormat:@"%.2f",aDevice.fCenterHz/1e6] withTitle:@"Center Frequency (Mhz)"];
        [lims addValue:[NSString stringWithFormat:@"%.1f",aDevice.fAmplitudeBottom] withTitle:@"Signal strenght from (dBm)"];
        [lims addValue:[NSString stringWithFormat:@"%.1f",aDevice.fAmplitudeTop] withTitle:@"Signal strenght until (dBm)"];
        [lims addValue:[NSString stringWithFormat:@"%.1f",aDevice.fAmplitudeSpan] withTitle:@"Signal strenght span (dBm)"];
    }

    if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceLimsIncludeHostInfo] boolValue]) {
        CFStringRef name;
        NSString *computerName;
        name=SCDynamicStoreCopyComputerName(NULL,NULL);
        computerName=[NSString stringWithString:(NSString *)name];
        CFRelease(name);
        
        [lims addValue:computerName withTitle:@"Computer"];
        [lims addValue:NSFullUserName() withTitle:@"Operator"];
        [lims addValue:aDevice.path withTitle:@"Device path"];
        [lims addValue:aDevice.commsSpeedAsString withTitle:@"Baudrate"];        
    }
    if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceLimsIncludeDeviceInfo] boolValue]) {
        [lims addValue:aDevice.firmware withTitle:@"RF Explorer Firmware"];
        [lims addValue:aDevice.mainBoard withTitle:@"Main board"];
        [lims addValue:aDevice.expansionBoard withTitle:@"Expansion board"];
        [lims addValue:[NSString stringWithFormat:@"%.2f",aDevice.fMinFreqHz/1e6] withTitle:@"Board Frequency from (Mhz)"];
        [lims addValue:[NSString stringWithFormat:@"%.2f",aDevice.fMaxFreqHz/1e6] withTitle:@"Board Frequency until (Mhz)"];
        [lims addValue:[NSString stringWithFormat:@"%.2f",aDevice.fMaxSpanHz/1e6] withTitle:@"Board Frequency max band span (Mhz)"];
        [lims addValue:[NSString stringWithFormat:@"%.2f",aDevice.fMinSpanHz/1e6] withTitle:@"Board Frequency min band span (Mhz)"];
        [lims addValue:[NSString stringWithFormat:@"%d",aDevice.nFreqSpectrumSteps] withTitle:@"Board Frequency bands (#)"];
        [lims addValue:[NSString stringWithFormat:@"%.1f",aDevice.fAmplitudeMin] withTitle:@"Board Signal strenght from (dBm)"];
        [lims addValue:[NSString stringWithFormat:@"%.1f",aDevice.fAmplitudeMax] withTitle:@"Board Signal strenght until (dBm)"];
        [lims addValue:[NSString stringWithFormat:@"%.1f",aDevice.fAmplitudeMinSpan] withTitle:@"Board Signal strenght smallest range (dBm)"];
    }
    if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceLimsIncludeTimeStamps] boolValue]) {
        NSDateFormatter * ndf = [[[NSDateFormatter alloc] init] autorelease];
        [ndf setDateStyle:NSDateFormatterShortStyle];
        [ndf setTimeStyle:NSDateFormatterMediumStyle];
        [lims addValue:[ndf stringFromDate:aDevice.connectedTime]  withTitle:@"RF Explorer connected"];
        [lims addValue:[ndf stringFromDate:aDevice.configTime]  withTitle:@"Last Configuration change"];
        [lims addValue:[ndf stringFromDate:aDevice.spectrumTime]  withTitle:@"Last Spectrum update"];
    }

    if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceLimsIncludeComment] boolValue]) {
        NSString * cmt = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceLimsCommentString];
        [lims addValue:cmt withTitle:@"Comment"];
    }
    
    return lims.count ? lims : nil;
}
@end
