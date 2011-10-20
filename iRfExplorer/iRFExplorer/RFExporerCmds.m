//
//  RFExporerCmds.m
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
@synthesize delegate;

#pragma mark init and related sundry such as thread kickoff.

- (id)init {
    NSLog(@"One should never call init on %@ - specify Path and Speed", self.className);
    return nil;
}

- (id)initWithPath:(NSString *)_path withSlowSpeed:(BOOL)_isSlow {
    path = [_path retain];
    isSlow = _isSlow;
    
    struct termios termattr ;
    int nfd = -1;
    
    if (path == nil) {
        NSLog(@"%@ - reopen: No path specified.", self.className);
        goto error;
    };
    
    const char * cpath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    if ((nfd = open(cpath , O_RDWR | O_NOCTTY | O_NONBLOCK))<0) {
        NSLog(@"Failed to open '%s': %s", cpath, strerror(errno));
        goto error;
    };
    
#if 0
    if (ioctl(fd, TIOCEXCL) == -1) {
        NSLog(@"Error - failed to get a lock on '%s': %s (if you get this in the profiler - then change device-perms)",  cpath, strerror(errno));
        goto error;
    }
#endif
    
    int flag = 0;
    if (fcntl(fd, F_SETFL, &flag) == -1)
    {
        NSLog(@"Error clearing O_NONBLOCK %s - %s(%d).\n",
              cpath, strerror(errno), errno);
        goto error;
    }
    
    if (tcgetattr( nfd, &termattr )<0) {
        NSLog(@"Failed tcgetatttr() '%@': %s", path, strerror(errno));
        goto error;
    };
    
    termattr.c_cflag &= ~( CSIZE | PARENB | PARODD | CSTOPB );
    termattr.c_cflag |= CS8; // 8N1
    cfsetispeed( &termattr, isSlow ? B2400 : B57600);
    cfsetospeed( &termattr, isSlow ? B2400 : B57600);
    
    if ((tcsetattr( nfd, TCSANOW, &termattr )) < 0) {
        NSLog(@"Failed to set serial to 8N1: %s", strerror(errno));
        close(nfd);
        return FALSE;
    }
    
    int s = isSlow ? B2400 : (500 * 1000);
    
    if (ioctl(nfd, IOSSIOSPEED, &s) < 0) {
        NSLog(@"Failed to set baudrate to %d: %s", s, strerror(errno));
        close(nfd);
        return FALSE;
    };
    
    // XX todo - we could do a IOSSDATALAT and set it at 500k x 100 bytes or
    //    so; as we know that faster reading makes no sense (and we know that
    //    writes currently give some 10-15 chars often). This would let us
    //    quell this thread a bit.
    //
    fd = nfd;    

    NSLog(@"Listening to %s - speed %d", cpath, s);
    
    [NSThread detachNewThreadSelector:@selector(readerHandler:) toTarget:self withObject:self]; 
        
    return self;
    
error:
    fd = -1;
    if (nfd >= 0)
        close(nfd);
    
    [path release];
    return nil;
}

-(void)debug:(char*)msg buff:(const char *)p len:(long)l mod:(long)N {
    assert(N < 200);
    char line[1024];
    char strg[1024];
    for(int i=0; i < l; i++) {
        unsigned int c = p[i];
        if (i % N == 0) {
            line[0]='\0';
            strg[0]='\0';
            sprintf(line,"%04x %s ", i, msg);
        };
        // sprintf(line+strlen(line),"%c/%02x ", (c>31 && c < 128) ? c : '.',c);
	//
        sprintf(line+strlen(line)," %02x", c);
        sprintf(strg+strlen(strg),"%c", (c>31 && c < 128) ? c : '.');
        
        if (((i) && ((i % N)==N-1)) || (i == l-1)) {
            NSLog(@"%s :%s",line,strg);
        };
    };
}

-(void)debug:(char*)msg buff:(const char *)p len:(long)l {
    [self debug:msg buff:p len:l mod:32];
}

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
        case EXPANSION_433M: 
            return @"443M"; 
            break;
        case EXPANSION_868M: 
            return @"868M"; 
            break;
        case EXPANSION_915M: 
            return @"915M"; 
            break;
        case EXPANSION_WSUB1G: 
            return @"WSUB1GM"; 
            break;
        case EXPANSION_2G4: 
            return @"2.4GM"; 
            break;
        case EXPANSION_DEMO:
            return @"Emulator";
            break;
        case 255: 
            return nil; 
            break;
    }
    return board;
}

-(void)processReply:(NSData*)data {
    NSData * tmp = [NSData dataWithData:data];

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
        int sampleSteps = ((unsigned char*)p)[2];
        ssize_t need = sampleSteps + 3;
        if (l != need) {
            NSLog(@"$S spectrum has the wrong length (expected %ld, got %ld). Ignoring", need, l);
            return;
        }

        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:sampleSteps];
        for (int i = 0; i < sampleSteps; i++) {
            float adBm = ((unsigned char *)p)[3+i] / -2.0f;
            [arr addObject:[NSNumber numberWithFloat:adBm]];
        };
        
        [delegate newData:arr]; 
        
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
        ssize_t need = 128 * 8 + 2;
        if (l != need) {
            NSLog(@"$D LCD has the wrong length (expected %ld, got %ld)). Ignoring",need,l);
            return;
        }
        
        NSImage * img = [LCDImage imageWithLCD:p+2];
        [delegate newScreen:img]; 

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
        
        if (logPR || TRUE)
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

    if (unkPktTypeCount++ < 5) {
        char ign[8];
        for(int i = 0; i < sizeof(ign)-1 && i < l; i++) 
            ign[i] = (p[i]<32||p[i]>128) ? '.' : p[i];
        ign[sizeof(ign)-1] = '\0';
	    NSLog(@"No idea what to do with <%s..> - ignoring.%@",p,
              ((unkPktTypeCount==5) ? @" And won't tell you about it any more" : @""));
    }
}

-(void)submit:(const char *)buff withLength:(ssize_t)len 
{   
    NSData * data = [[NSData alloc] initWithBytes:buff length:len];

    [self performSelectorOnMainThread:@selector(processReply:)
                           withObject:data
                        waitUntilDone:NO];
    
    [data release];
}

#pragma mark Receive thread

-(void)readerHandler:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    char buff[32 * 1024];
    long l = 0;
    BOOL debugRH = FALSE;
    BOOL logRH = FALSE;
    unsigned int errCnt = 0;
    unsigned int okCnt = 0;
 
    NSLog(@"Listening on fd %d...",fd);
    while(1) {
        if (okCnt > 30) 
		errCnt = 0;
        
        if (fd < 0)
            return;

        if (errCnt>5)
            return;

        // Keep one byte at the end for termination.
        ssize_t s = read(fd,buff + l,sizeof(buff)-1-l);
        
        if (s <= 0) {
            if (errno == EAGAIN || errno == EINTR)
                continue;
            
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
            errCnt++; okCnt = 0;
            
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
                        
                    [self submit:buff withLength:i -2 ];
		    okCnt++;
                    
                    // continue straight after.
                    memcpy(buff,buff+i,l-i);  
                    l -= i;
                    continue;
                };
                
                if ((l > 2) && (buff[1] == 'S')) {
                    unsigned int  steps = buff[2];
                    unsigned int i = 3 + steps + 2; 
                    // current device seems to be 112 only; but
                    // wifi analyser may go as low as 13 and future
                    // devices may hit 255.
                    //
                    if (l >= i && steps > 10) {
                        // queue 0 .. i -1;
                        if (logRH) 
                            NSLog(@"Submit Short S (%u bytes)", i);
                        
                        [self submit:buff withLength:i-2 ];
		    	okCnt++;
                        
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
                if (p && len > 0) {
                    if (logRH) 
                        NSLog(@"# .. \\r\\n segment (%ld bytes) submitting",len);
                    [self submit:p withLength:len];
		    okCnt++;
                } else {
                    NSLog(@"Skipping to next \\r\\n terminated as no initial '#'.");
                    errCnt++; okCnt = 0;
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
                errCnt++; okCnt = 0;
                l = 0;
            };
            
            break;
        }; // while we can extract stuff
    }; // while read() loop
    
    NSLog(@"serial listener thread exited on fd %d (#%lu)",fd,[self retainCount]);
    // [NSAlert alertWithError:@"Lost connection to RF Explorer"];
    
    [pool drain];
};

#pragma  mark Cleanups

-(void)halt {
    int nfd = fd;
    fd = -1;
    
    if (nfd >=0 ) {
        close(nfd);
        NSLog(@"Normal close(%d) of %@ on serial con", nfd, self.className);
    };    
}

-(void)dealloc {
    NSLog(@"%@ -- dealloc at CMD level (%lu)", self.className,[self retainCount]);

    if (fd >=0) 
        [self halt];
    
    [path release];
    
    // XX fix-me -- this dealloc causes a crash - because we're prolly
    // over releasing something - or have just done so. But cannot 
    // quite find it yet..
    //
    [super dealloc];    
}
@end
