//
//  RFExporerCmds.m
//  iRFExplorer
//
//  Created by Dirk-Willem van Gulik on 08/10/2011.
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
//  Protocol details from:
//      http://code.google.com/p/rfexplorer/wiki/RFExplorerRS232Interface
//  and from
//      hg clone https://code.google.com/p/rfexplorer/
//
#import "RFExporerCmds.h"
#import "NSStringExtensions.h"
#import "LCDImage.h"

#include <sys/ioctl.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/ioss.h>

@implementation RFExporerCmds
@synthesize delegate, path, isSlow;

#pragma mark init and related sundry such as thread kickoff.

- (id)init {
    self = [super init];
    if (!self) 
        return nil;
    
    fd = -1;
    return self;
}

- (id)initWithPath:(NSString *)_path withSlowSpeed:(BOOL)_isSlow {
    self = [self init];
    self.path = _path;
    self.isSlow = _isSlow;
    [self reopen];
    
    return self;
}

-(void)setFd:(int)_fd {
    if (fd == _fd)
        return;
    
    if (fd != -1 && _fd != -1) {
        [receiveWorker cancel];
    }
    fd = _fd;
    
    NSLog(@"Kicking of worker on fd %d", fd);
    [NSThread detachNewThreadSelector:@selector(readerHandler:) toTarget:self withObject:self]; 
}

-(int)fd { 
    return fd; 
}


-(void)debug:(char*)msg buff:(const char *)p len:(long)l {
    int i;
    char line[1024];
    for(i=0; i < l; i++) {
        unsigned int c = p[i];
        if (i % 32 == 0) {
            line[0]='\0';
            sprintf(line,"%04x %s ", i, msg);
        };
        //        sprintf(line+strlen(line),"%c/%02x ", (c>31 && c < 128) ? c : '.',c);
        sprintf(line+strlen(line),"%c", (c>31 && c < 128) ? c : '.');
        
        if (((i) && ((i % 32)==31)) || (i == l-1)) {
            NSLog(@"%s",line);
        };
    };
}
#pragma mark C-level serial port handling.

-(BOOL)reopen {
	// struct termios termattr ;
    int nfd;
    fd = -1;
    
    if (path == nil) {
        NSLog(@"%@ - reopen: No path specified.", self.name);
        return FALSE;
    };
    
    const char * cpath = [path cStringUsingEncoding:NSASCIIStringEncoding];
	if ((nfd = open(cpath , O_RDWR | O_NOCTTY))<0) {
        NSLog(@"Failed to open '%s': %s", cpath, strerror(errno));
       return FALSE;
    };
    
#if 0
	if (tcgetattr( nfd, &termattr )<0) {
        NSLog(@"Failed tcgetatttr() '%@': %s", path, strerror(errno));
        close(nfd);
        return FALSE;
    };
    
	termattr.c_cflag &= ~( CSIZE | PARENB | PARODD | CSTOPB );
	termattr.c_cflag |= CS8; // 8N1
	cfsetispeed( &termattr, self.isSlow ? B2400 : B57600);
	cfsetospeed( &termattr, self.isSlow ? B2400 : B57600);

	if ((tcsetattr( nfd, TCSANOW, &termattr )) < 0) {
        NSLog(@"Failed to set serial to 8N1: %s", strerror(errno));
        close(nfd);
        return FALSE;
    }
#endif    
    int s = isSlow ? B2400 : (500 * 1000);
    
    if (ioctl(nfd, IOSSIOSPEED, &s) < 0) {
        NSLog(@"Failed to set baudrate to %d: %s", s, strerror(errno));
        close(nfd);
        return FALSE;
    };
    
    NSLog(@"Listening to %s - speed %d", cpath, s);
    
    if (fd >=0) 
        close(fd);    
    self.fd = nfd;
    
	return TRUE;
}

#pragma mark Command sending and commands

-(BOOL)sendCmd:(NSString *)cmd {
    if (fd<0) 
        return FALSE;
    
    int len = (int) [cmd length] + 2;
    char buff[256+3];
    const char *cmdStr = [cmd cStringUsingEncoding:NSASCIIStringEncoding];
    int s = snprintf(buff,sizeof(buff),"#%c%s", 
                     len, cmdStr);
    
    ssize_t e = write(fd, buff, s);
    if (e<0) {
        NSLog(@"Failed to sendCmd: %s", strerror(errno));
    };
    
    NSLog(@"Send '#<%02d>%s'", len, cmdStr);
    return (e == s);
}

-(void)getConfigData {
    [self sendCmd:@"C0"];
}

-(void)playScreen {
    [self sendCmd:@"D1"];
}

-(void)pauseScreen {
    [self sendCmd:@"D0"];
}

-(void)pauseSpectrum {
    [self sendCmd:@"CH"];
}

-(void)playSpectrum {
    [self getConfigData];
}

-(void)shutdown {
    [self sendCmd:@"CS"];
}
/* Current_Config	
 *
 * #<Size>C2-F:<Start_Freq (Khz)>, <Freq_Step (hz)>, <Amp_Top (dBm)>, <Amp_Bottom (dBm)>	 
 * 
 * Send current Spectrum Analyzer configuration data. From PC to RFE, will change 
 * current configuration for RFE where <Size>=30 bytes.
 */
-(void) sendCurrentConfigWithStartFreq:(float)_fStartMhz
                          withEndFreq:(float)_fEndMhz
                            withAmpTop:(float)_fAmplitudeTop
                         withAmpBottom:(float)_fAmplitudeBottom {
    
    [self sendCmd:[NSString stringWithFormat:@"C2-F:%07d,%007d,%04d,%04d",
                   (int)(_fStartMhz * 1000.0f),
                   (int)(_fEndMhz   * 1000.0f),
                   (int)_fAmplitudeTop,
                   (int)_fAmplitudeBottom
                   ]];                   
}

#pragma mark Data receiving and decoding.

-(NSString *)numToBoard:(NSString *)board {
    switch ([board intValue]) {
        case 0: 
            return @"443M"; 
            break;
        case 1: 
            return @"868M"; 
            break;
        case 2: 
            return @"915M"; 
            break;
        case 3: 
            return @"WSUB1GM"; 
            break;
        case 4: 
            return @"2.4GM"; 
            break;
        case 255: 
            return nil; 
            break;
    }
    return board;
}

-(void)processReply:(NSData*)data {
    NSData * tmp = [NSData dataWithData:data];
    [data release];

    const char * p = [tmp bytes];
    ssize_t l = [tmp length];

    BOOL debugPR = FALSE;
    BOOL logPR = FALSE;
    if (!l)
        return;
    
    if (debugPR) 
        [self debug:"PR" buff:p  len:l];
    
    /* #C2-M:<Main_Model>, <Expansion_Model>, <Firmware_Version> <EOL>
     *
     * Example: "#C2-M:003,255,01.07\r\n"
     *
     * <Main_Model>	
     *      3 ASCII digits, decimal	 -
     *      Codified values are 433M:0, 868M:1, 915M:2, WSUB1G:3, 2.4G:4
     * <Expansion_Model>	
     *      3 ASCII digits, decimal	
     *      Codified values are 433M:0, 868M:1, 915M:2, WSUB1G:3, 2.4G:4, NONE:255
     * <Firmware_Version>	
     *      5 ASCII chars
     *      Standard format xx.yy, may change format for betas or custom version
     * E.g.
     *   #C2-M:003,255,01.07<CRLF>
     */
    if (!strncmp("#C2-M:",p,6) && l < 22) {
        if (logPR) NSLog(@"C2-M '%s'", p);
        NSString *main = [NSString stringWithCString:p+6 withLength:3 encoding:NSASCIIStringEncoding];
        NSString *expansion = [NSString stringWithCString:p+10 withLength:3 encoding:NSASCIIStringEncoding];
        NSString *firmware = [NSString stringWithCString:p+14 withLength:5 encoding:NSASCIIStringEncoding];
        
        main = [self numToBoard:main];
        expansion = [self numToBoard:expansion];
        
        if (logPR)
            NSLog(@"Mainboard %@, expansion card: %@, firmware: %@",
              main,expansion,firmware);
    
        [delegate configWithBoard:main 
                    withExpansion:expansion 
                     withFirmware:firmware];
        return;
    }
    
    /* $S<Sample_Steps> <AdBm>… <AdBm> <EOL>	
     *
     * Send all dBm sample points to PC client, in binary.
     *
     * <AdBm>
     *      Binary byte	 dBm	 
     *      Sampled value in dBm, repeated n times one per sample. To get the real 
     *      value in dBm, consider this an unsigned byte, divide it by two and 
     *      change sign to negative. For instance a byte=0x11 (17 decimal) will 
     *      be -17/2= -8.5dBm. This is now normalized and consistent for all 
     *      modules and setups
     */
    if (!strncmp("$S",p,2)) {
        int sampleSteps = p[2];
        NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:sampleSteps];
        for (int i = 0; i < sampleSteps; i++) {
            float adBm = ((unsigned char *)p)[3+i] / -2.0f;
            [arr addObject:[NSNumber numberWithFloat:adBm]];
        };
        
        [delegate newData:arr]; 
        
        if (debugPR)
            NSLog(@"Dataset of %d samples passed.", sampleSteps);
            
        return;
    }
    /* $D<Byte><EOL>
     *
     * Dump all 128*8 screen bytes to PC client. The memory is organized as 8 consecutive 
     * rows of 128 bytes each Organized top to bottom. Every bit within the byte represents 
     * a pixel ON(1) or OFF(0) being the MSB the upper pixel and the LSB the bottom pixel 
     * within the row.	
     */
    if (!strncmp("$D",p,2)) {
        // original code check if we expect this (D1 or D0 state).
        // 128 x 8 bytes == 128 x 64 bits
        if (l >= 128 * 8 + 2) {
            if (logPR)
                NSLog(@"Screendump passed to %@", delegate);
            NSImage * img = [LCDImage imageWithLCD:p+2];
            [delegate newScreen:img]; 
            [img release];
        };
        return;
    }
    /*
     * #C2-F:<Start_Freq>, <Freq_Step>, <Amp_Top>, <Amp_Bottom>, <Sweep_Steps>, <ExpModuleActive>, 
     * <CurrentMode>, <Min_Freq>, <Max_Freq>, <Max_Span> <EOL>
     *
     * Example: '#C2-M:0022500,0892857,-050,-120,0112,0,000,0240000,0960000,0100000\r\n'
     *
     * <Start_Freq>
     *      7 ASCII digits, decimal	 KHZ	 
     *      Value of frequency span start (lower)
     * <Freq_Step>
     *      7 ASCII digits, decimal	 HZ	 
     *      Value of frequency of sample step	
     * <Amp_Top>	
     *      4 ASCII digits, decimal	 dBm	 
     *      Highest value of amplitude for GUI
     * <Amp_Bottom>	4 ASCII digits, decimal	 dBm	 
     *      Lowest value of amplitude for GUI	 
     * <Sweep_Steps>	
     *      4 ASCII digits, decimal	Steps
     *      Number of sweep steps in the current configuration
     * <ExpModuleActive>	
     *      1 ASCII digit, binary
     *      1 if the Expansion module is the active circuit, 0 otherwise (the main board is active)	
     * <CurrentMode>	
     *      3 ASCII digits, decimal	 -	 
     *      Codified values are SPECTRUM_ANALYZER:0, RF_GENERATOR:1, WIFI_ANALYZER:2, UNKNOWN:255	
     * <Min_Freq>	
     *      7 ASCII digits, decimal	 KHZ	 
     *      Min supported frequency value for the selected RF circuit and mode
     * <Max_Freq>	
     *      7 ASCII digits, decimal	 KHZ	 
     *      Max supported frequency value for the selected RF circuit and mode	
     * <Max_Span>	
     *      7 ASCII digits, decimal	 KHZ	 
     *      Max supported Span value for the selected RF circuit and mode
     *
     */
    if (((!strncmp("#C2-F:",p,6)) || (!strncmp("#C2-M:",p,6))) && (l >= 50)) {
        if (logPR) NSLog(@"C2-F '%s'", p);
        long fStartMhz,fStepMhz;
        long fAmplitudeTop, fAmplitudeBottom, nFreqSpectrumSteps;
        long fMinFreqMhz, fMaxFreqMhz, fMaxSpanMhz;
        RF_mode_t eMode;
        int flag;
        
        // #C2-M:0022500,0892857,-050,-120,0112,0,000,0240000,0960000,0100000\r\n'
        sscanf(p+6,"%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld",
               &fStartMhz, &fStepMhz, 
               &fAmplitudeTop, &fAmplitudeBottom, &nFreqSpectrumSteps,
               &flag,
               &eMode, &fMinFreqMhz, &fMaxFreqMhz, &fMaxSpanMhz);
        
        BOOL bExpansionBoardActive = (flag == 1);
                
        [delegate configWithStartMhz:fStartMhz / 1000.0f
                         withStepMhz:fStepMhz / 1000000.0f
                    withAmplitudeTop:fAmplitudeTop
                 withAmplitudeBottom:fAmplitudeBottom
                           withSteps:nFreqSpectrumSteps
            withExpansionBoardActive:bExpansionBoardActive
                             witMode:eMode
                         withMinFreq:fMinFreqMhz / 1000.0f
                         withMaxFreq:fMaxFreqMhz / 1000.0f
                        withSpanFreq:fMaxSpanMhz / 1000.0f ];
        
        if (logPR)
            NSLog(@"config details passed:\n"
                  "\tStart:\t%ld KHz\n"
                  "\tStep:\t%ld Hz\n"
                  "\tAmpl:\t%ld - %ld dBM\n"
                  "\tSteps:\t%ld #\n"
                  "\tRange:\t%ld .. %ld KHz\n"
                  "\tBand:\t%ld KHz",
                  fStartMhz, fStepMhz, 
                  fAmplitudeTop, fAmplitudeBottom, nFreqSpectrumSteps,
                  fMinFreqMhz, fMaxFreqMhz, fMaxSpanMhz);
        return;
    };

    if (!strncmp("#C1-F:",p,6)) {
        NSLog(@"Old firmware detected -- upgrade");
        [delegate alertUser:@"Unexpected data received - firmware may be too old."];
        return;
    }

    NSLog(@"No idea what to do -- discarding.");
}

-(void)submit:(const char *)buff withLength:(ssize_t)len 
{   
    NSData * data = [[NSData alloc] initWithBytes:buff length:len];

    [self performSelectorOnMainThread:@selector(processReply:)
                           withObject:[data retain]
                        waitUntilDone:NO];
}

#pragma mark Receive thread

-(void)readerHandler:(id)sender {
    char buff[32 * 1024];
    long l = 0;
    BOOL debugRH = FALSE;
    BOOL logRH = FALSE;
    
    NSLog(@"Listening on fd %d...",fd);
    while(fd>=0 && ![self isCancelled])
    {
        // Keep one byte at the end for termination.
        ssize_t s = read(fd,buff + l,sizeof(buff)-1-l);
        
        if (s <= 0) {
            NSLog(@"Read from serial failed: %s", strerror(errno));
            break;
        }

        l+=s;

        if (debugRH) {
            NSLog(@"Read %ld bytes - have %ld bytes", s, l);
            
            [self debug:"HH" buff:buff len:l];
        };
        
        // terminate as to allow us to use strstr/index and similar.
        //
        buff[l+1]='\0';
        
        if (l >= sizeof(buff)-1) {
            char * p = index(buff,'#');
            
            NSLog(@"Blew a buffer, %@.",
                  (p ? @"scanning to next '#'" : @"resetting"));
            
            if (p) {
                l = p-buff;
                memcpy(buff,p,l);
            } else {
                l = 0;
            }
            continue;
        };
 
        while(1) {            
            if (buff[0] == '$') {
                long i = 2 + 128 * 8 +2;
                if ((l >= i) && (buff[1] == 'D')) {
                    // queue 0 .. i -1;
                    if (logRH) 
                        NSLog(@"Submit D (%ld bytes)", i);

                    [self submit:buff withLength:i];
                    
                    // continue straight after.
                    memcpy(buff,buff+i,l-i);
                    l -= i;
                    
                    continue;
                };
                
                if ((l > 2) && (buff[1] == 'S')) {
                    long steps = buff[2];
                    long i = 3 + steps + 2;
                    if (l >= i) {
                        // queue 0 .. i -1;
                        if (logRH) 
                            NSLog(@"Submit Short S (%ld bytes)", i);
                        
                        [self submit:buff withLength:i];
                        
                        // continue straight after.
                        memcpy(buff,buff+i,l-i);
                        l -= i;
                    }
                }
                break;
            } // if $
            
            char *e = strnstr(buff,"\r\n",l);
            if (e) {
                long i = e - buff + 2;
                char * p;
                long len;
                
                p = index(buff,'#');
                len = i - (p - buff);
                
                // Queue 0 .. i-1;
                if (p && l) {
                    if (logRH) 
                        NSLog(@"# .. \\r\\n segment (%ld bytes) submitting",len);
                    [self submit:p withLength:len];
                } else {
                    NSLog(@"Skipping to next \\r\\n terminated as no initial '#'.");
                };
                
                // Skip \r\n and continue just after.
                if (l-i > 0) {
                    memcpy(buff, e+2, l - i);
                    l -= i;
                    if (debugRH) 
                        NSLog(@"and moving %ld bytes to the start", l);
                } else {
                    l = 0;
                };
                continue;
            }
            
            if (l >= sizeof(buff)-1) {
                NSLog(@"Blowing complete buffer");
                l = 0;
            };
            
            break;
        }; // while we can extract stuff
    }; // while read() loop
    
    NSLog(@"serial listener thread exited on fd %d",fd);
    [NSThread exit];
};

#pragma  mark Cleanups

-(void)dealloc {
    // ensure our child exits too.
    fd = -1;
}
@end
