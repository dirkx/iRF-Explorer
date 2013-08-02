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
#import "iRFExplorerAppDelegate.h"

#include <sys/ioctl.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/ioss.h>
#import "PreferenceConstants.h"


@implementation RFExporerCmds
@synthesize delegate;


#pragma mark init and related sundry such as thread kickoff.

#ifdef SIGNAL_TIMEOUT
static jmp_buf preopen;
static void breakout(int argv) {
    longjmp(preopen,1);
}
#endif

- (id)initWithPath:(NSString *)_path withSlowSpeed:(BOOL)_isSlow {
    self = [super init];
    if (self == nil)
        return nil;
    
    path = [_path retain];
    isSlow = _isSlow;
    
    logRH = [[[NSUserDefaults standardUserDefaults] valueForKey:kCommsLog] boolValue];
    debugRH = [[[NSUserDefaults standardUserDefaults] valueForKey:kCommsDebug] boolValue];    
    cmdRH = [[[NSUserDefaults standardUserDefaults] valueForKey:kCmdLog] boolValue];    

#if 1
    // Logging on on CTRL+ALT (and Cmd, and Shift) pressed.
    //
    CGEventRef event = CGEventCreate(NULL);
    CGEventFlags modifiers = CGEventGetFlags(event);
    CFRelease(event);
    NSUInteger buttonMask0= kCGEventFlagMaskAlternate; // already pressed to include demo device.
    NSUInteger buttonMask1 = buttonMask0 | kCGEventFlagMaskControl;
    NSUInteger buttonMask2 = buttonMask0 | kCGEventFlagMaskCommand;
    NSUInteger buttonMask3 = buttonMask0 | kCGEventFlagMaskShift;

    if ((modifiers & buttonMask1) == buttonMask1) { 
        cmdRH = TRUE;
    }
    if ((modifiers & buttonMask2) == buttonMask2) { 
        logRH = TRUE;
    }
    if ((modifiers & buttonMask3) == buttonMask3) { 
        debugRH = TRUE;
    }
#endif
    
    struct termios termattr ;
    int nfd = -1;
    
    if (path == nil) {
        NSLog(@"%@ - reopen: No path specified.", self.className);
        goto error;
    };
    
    const char * cpath = [path cStringUsingEncoding:NSASCIIStringEncoding];

#define ME_UNDERSTAND_PROFILER_OBJECTION_TO_THIS 0
    
#ifdef SIGNAL_TIMEOUT
    if (setjmp(preopen)) {
        NSLog(@"Timeout on opening device %s", cpath);
        goto error;        
    }
    sig_t oldalarm = signal(SIGALRM, &breakout);
    alarm(SIGNAL_TIMEOUT);
#endif
    
#if ME_UNDERSTAND_PROFILER_OBJECTION_TO_THIS
    if ((nfd = open(cpath , O_RDWR | O_NOCTTY | O_NONBLOCK ))<0)
#else
    if ((nfd = open(cpath , O_RDWR | O_NOCTTY))<0)
#endif
    {
        NSLog(@"Failed to open '%s': %s", cpath, strerror(errno));
        goto error;
    };
    
#if ME_UNDERSTAND_PROFILER_OBJECTION_TO_THIS
    if (ioctl(fd, TIOCEXCL) == -1) {
        NSLog(@"Error - failed to get a lock on '%s': %s",  cpath, strerror(errno));
        goto error;
    }
    
    int flag = 0;
    if (fcntl(fd, F_SETFL, &flag) == -1)
    {
        NSLog(@"Error clearing O_NONBLOCK %s - %s(%d).\n",
              cpath, strerror(errno), errno);
        goto error;
    }
#endif
    
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
        return nil;
    }
    
    int s = isSlow ? B2400 : (500 * 1000);
    
    if (ioctl(nfd, IOSSIOSPEED, &s) < 0) {
        NSLog(@"Failed to set baudrate to %d: %s", s, strerror(errno));
        close(nfd);
        return nil;
    };

#ifdef SIGNAL_TIMEOUT
    signal(SIGALRM, oldalarm);
    alarm(0);
#endif
    
    // XX todo - we could do a IOSSDATALAT and set it at 500k x 100 bytes or
    //    so; as we know that faster reading makes no sense (and we know that
    //    writes currently give some 10-15 chars often). This would let us
    //    quell this thread a bit.
    //
    fd = nfd;    

    // NSLog(@"Listening to %s - speed %d", cpath, s);

    [NSThread detachNewThreadSelector:@selector(readerHandler:) 
                             toTarget:self 
                           withObject:nil]; 
        
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
        unsigned char c = ((unsigned char *)p)[i];
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
    [self debug:msg buff:p len:l mod:16];
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
    
    if (cmdRH)
        NSLog(@"Send '#<%02d>%s'", len, cmdStr);
    return (e == s);
}

#define TO_CONFIG_M (1)
#define TO_CONFIG_F (2)
#define TO_SPECTRUM (4)
#define TO_SCREEN   (8)
#define TO_FIRST (16)
#define TO_ALL      (0xFF) 

-(void)setTimeoutMask:(NSUInteger)aMask withTimeout:(NSTimeInterval)tOut {
    [timeoutTimer invalidate];
    [timeoutTimer release];
    
    timeoutTimer = [[NSTimer scheduledTimerWithTimeInterval:tOut 
                                                     target:self 
                                                   selector:@selector(timeoutCallback:) 
                                                   userInfo:self 
                                                    repeats:NO] retain];
    timeoutMask |= aMask;
}

-(void)setTimeoutMask:(NSUInteger)aMask {
    [self setTimeoutMask:aMask withTimeout:3.5];
}

-(void)timeoutCallback:(id)sender {
    [timeoutTimer invalidate];
    [timeoutTimer release];
    timeoutTimer = nil;
    
    if (timeoutMask == 0)
            return;
    
    if (timeoutMask & TO_FIRST) {
        // try a reset and one more try - and do it longer.
        NSLog(@"Retry the init sequence (10 seconds)...");
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionNotification
                                                            object:@"retry"];
        
        [self setTimeoutMask:0 
                 withTimeout:10.0];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self 
                                       selector:@selector(forecfulResend:) 
                                       userInfo:nil
                                        repeats:NO];
        return;
    }
    // [self close];
    fd = -1;
    [delegate alertUser:NSLocalizedString(@"Communication with RF Explorer timed out.",
                                          @"Error in comms timeout/silence")];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionNotification
                                                        object:@"timeout"];
};

-(void)clearTimeoutMask:(NSUInteger)aMask {
    timeoutMask &= ~aMask;
    if (timeoutMask)
        return;
    
    [timeoutTimer release];
    timeoutTimer = nil;
    // NSLog(@"Timout clear %lx", timeoutMask);
}
    
-(void)resend:(NSTimer*)aTimer {
    timeoutMask &= ~TO_FIRST;
    [self sendCmd:@"C0"];
}

-(void)forecfulResend:(NSTimer *)aTimer {
    timeoutMask &= ~TO_FIRST;
    [self sendCmd:@"CH"];
    [self sendCmd:@"CS"];
    [self sendCmd:@"D0"];
}

-(void)getConfigData {
    [self setTimeoutMask:TO_CONFIG_F | TO_CONFIG_M | TO_FIRST];
    [self sendCmd:@"C0"];
}

-(void)playScreen {
    [self setTimeoutMask:TO_SCREEN];
    [self sendCmd:@"D1"];
}

-(void)pauseScreen {
    [self clearTimeoutMask:TO_SCREEN];
    [self sendCmd:@"D0"];
}

-(void)pauseSpectrum {
    [self clearTimeoutMask:TO_SPECTRUM];
    [self sendCmd:@"CH"];
}

-(void)playSpectrum {
    [self setTimeoutMask:TO_SPECTRUM];
    [self getConfigData];
}

-(void)shutdown {
    [self clearTimeoutMask:TO_ALL];
    [self sendCmd:@"CS"];
}

/* Current_Config	
 *
 * #<Size>C2-F:<Start_Freq Khz>, <End_Freq kHz>, <Amp_Top dBm>, <Amp_Bottom dBm>
 *
 * Send current Spectrum Analyzer configuration data. From PC to RFE, will change 
 * current configuration for RFE where <Size>=30 bytes.
 */
-(void) sendCurrentConfigWithStartFreq:(double)_fStartHz
                          withEndFreq:(double)_fEndHz
                            withAmpTop:(double)_fAmplitudeTop
                         withAmpBottom:(double)_fAmplitudeBottom {
    
    [self sendCmd:[NSString stringWithFormat:@"C2-F:%07d,%07d,%04d,%04d",
                   (int)floor(_fStartHz / 1000.0f),
                   (int)floor(_fEndHz   / 1000.0f),
                   (int)_fAmplitudeTop,
                   (int)_fAmplitudeBottom
                   ]];                   
}

#pragma mark Data receiving and decoding.

-(void)processReply:(NSData*)data {
    NSData * tmp = [NSData dataWithData:data];

    const char * p = [tmp bytes];
    ssize_t l = [tmp length];

    BOOL debugPR = FALSE;
    
    if (!l)
        return;
    
    if (debugPR) 
        [self debug:"PR" buff:p  len:l];
    
    // Give up.
    if (fd <0)
        return;

    
    if (!strncmp("RF Explorer",p,11)) {
        NSLog(@"Unexpected boot-up string seen: %s.  Scheduling a re-ask.", p);
        [NSTimer scheduledTimerWithTimeInterval:0.5 
                                         target:self 
                                       selector:@selector(getConfigData) 
                                       userInfo:nil
                                        repeats:NO];
        return;
    }
    
    if (!strncmp("(C) Ariel Rocholl",p,17)) {
        NSLog(@"Unexpected copyright string seen: %s. Scheduling a re-ask.", p);
        [NSTimer scheduledTimerWithTimeInterval:0.5 
                                         target:self 
                                       selector:@selector(getConfigData) 
                                       userInfo:nil
                                        repeats:NO];
        [NSAlert alertWithMessageText:@"RF Explorer is (re)booting" 
                        defaultButton:@"OK" 
                      alternateButton:nil 
                          otherButton:nil 
            informativeTextWithFormat:@"The RF-Exporer device is (re)booting. Will try to re-establish contact in a few seconds."];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionNotification
                                                            object:@"restarting"];
        return;
    }
    
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
     *   #C2-M:003,255,01.07[few more chars for beta]<CRLF>
     */
    if (!strncmp("#C2-M:",p,6) && l < 48) {
        if (cmdRH) NSLog(@"C2-M '%s'", p);
        
        NSString *main = [NSString stringWithCString:p+6 withLength:3 encoding:NSASCIIStringEncoding];
        NSString *expansion = [NSString stringWithCString:p+10 withLength:3 encoding:NSASCIIStringEncoding];

#if 1
        int end = 4;
        while (isspace(p[14+end]) && end > 0)
               end--;
        if (end != 4) NSLog(@"Stripped firmware string");
#endif
        NSString *firmware = [NSString stringWithCString:p+14 withLength:end+1 encoding:NSASCIIStringEncoding];
            
        [delegate configWithBoard:[main intValue]
                    withExpansion:[expansion intValue]
                     withFirmware:firmware];

        [self clearTimeoutMask:TO_CONFIG_M | TO_FIRST];
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
            double adBm = ((unsigned char *)p)[3+i] / -2.0f;
            [arr addObject:[NSNumber numberWithDouble:adBm]];
        };
        
        [delegate newData:arr]; 
        
        // reset the spectrum timer unless we're paused.
        //
        if (timeoutMask & TO_SPECTRUM)
            [self setTimeoutMask:TO_SPECTRUM];        
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
        
        // reset the screen timer if we're still 'playing'.
        //
        if (timeoutMask & TO_SCREEN)
            [self setTimeoutMask:TO_SCREEN];        
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
        if (cmdRH) 
            NSLog(@"C2-F '%s'", p);
        if (debugPR) 
            [self debug:"rw2" buff:p len:l];
        long fStartKHz,fStepHz;
        long fAmplitudeTop, fAmplitudeBottom, nFreqSpectrumSteps;
        long fMinFreqKHz, fMaxFreqKHz, fMaxSpanKHz;
        RF_mode_t eMode;
        int flag;
        
        // #C2-M:0022500,0892857,-050,-120,0112,0,000,0240000,0960000,0100000\r\n'
        sscanf(p+6,"%ld,%ld,%ld,%ld,%ld,%u,%ld,%ld,%ld,%ld",
               &fStartKHz, &fStepHz, 
               &fAmplitudeTop, &fAmplitudeBottom, &nFreqSpectrumSteps,
               &flag,
               (long*)&eMode, &fMinFreqKHz, &fMaxFreqKHz, &fMaxSpanKHz);
        
        BOOL bExpansionBoardActive = (flag == 1);
                
        [delegate configWithStartHz:fStartKHz * 1000.
                         withStepHz:fStepHz
                    withAmplitudeTop:fAmplitudeTop
                 withAmplitudeBottom:fAmplitudeBottom
                           withSteps:nFreqSpectrumSteps
            withExpansionBoardActive:bExpansionBoardActive
                             witMode:eMode
                         withMinFreq:fMinFreqKHz * 1000.
                         withMaxFreq:fMaxFreqKHz * 1000.
                        withSpanFreq:fMaxSpanKHz * 1000. ];
        
        [self clearTimeoutMask:TO_CONFIG_F];

        if (debugPR)
            NSLog(@"config details passed:\n"
                  "\tStart:\t%ld KHz\n"
                  "\tStep:\t%ld Hz\n"
                  "\tAmpl:\t%ld - %ld dBM\n"
                  "\tSteps:\t%ld #\n"
                  "\tRange:\t%ld .. %ld KHz\n"
                  "\tBand:\t%ld KHz",
                  fStartKHz, fStepHz, 
                  fAmplitudeTop, fAmplitudeBottom, nFreqSpectrumSteps,
                  fMinFreqKHz, fMaxFreqKHz, fMaxSpanKHz);
        return;
    };

    if (!strncmp("#C1-F:",p,6)) {
        NSLog(@"Old firmware detected -- upgrade");
        [delegate alertUser:@"Unexpected data received - firmware may be too old."];
        return;
    }

    if (unkPktTypeCount++ < 5) {
        char ign[24];
        for(int i = 0; i < sizeof(ign)-1 && i < l; i++) {
            // rely on *p to be unsigned char; so >128 is in fact below 32.
            ign[i] = (p[i]<32) ? '.' : p[i];
        }
        ign[sizeof(ign)-1] = '\0';
	    NSLog(@"No idea what to do with <%s..> - ignoring.%@",ign,
              ((unkPktTypeCount==5) ? @" And won't tell you about it any more" : @""));
    }
}

-(void)alertUser:(NSString *)userMsg {
    [delegate alertUser:userMsg];
}

#pragma mark In thread

-(void)submit:(const char *)buff withLength:(ssize_t)len 
{   
    NSData * data = [[NSData alloc] initWithBytes:buff length:len];

    if (fd >=0 )
    [self performSelectorOnMainThread:@selector(processReply:)
                           withObject:data
                        waitUntilDone:NO];
    
    [data release];
}

#pragma mark Receive thread

-(void)readerHandler:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    char buff[32 * 1024];
    long lenInBuff = 0;
    unsigned int errCnt = 0;
    unsigned int okCnt = 0;
    int ofd = fd;
 
    if (logRH) 
        NSLog(@"%@ - Listening on fd %d...",self, fd);
    
    while(1) {
        if (okCnt > 30) 
            errCnt = 0;
        
        if (fd < 0) {
            break;
        };
        
        if (errCnt>5)
            break;
        
        // Keep one byte at the end for termination.
        ssize_t s = read(fd,buff + lenInBuff,sizeof(buff)-1-lenInBuff);

        if (fd < 0) {
            break;
        };
        
        if (s <= 0) {
            if ((s < 0) && (errno == EAGAIN || errno == EINTR)) {
                //                NSLog(@"EAGAIN/EINTR");
                continue;
            };
            if (s == 0) {
                [self performSelectorOnMainThread:@selector(alertUser:) 
                                       withObject:NSLocalizedString(@"Lost serial connection to device", 
                                                                    @"Error on serial con close")
                                    waitUntilDone:YES];
                if (logRH) NSLog(@"Serial close");
            } else {
                NSString * fmt = NSLocalizedString(@"Reading data from RF-Explorer failed: %s", 
                                                   @"Error on serial read with strerror()");
                [self performSelectorOnMainThread:@selector(alertUser:) 
                               withObject:[NSString stringWithFormat:fmt,strerror(errno)]
                                    waitUntilDone:YES];
                if (logRH) NSLog(@"Serial read failed: %s", strerror(errno));
            }
            close(fd);
            fd = -1;
            break;
        }

        lenInBuff+=s;

        if (debugRH) {
            NSLog(@"Read %ld bytes - have %ld bytes", s, lenInBuff);
            [self debug:"HH" buff:buff len:lenInBuff];
        };
        
        // terminate as to allow us to use strstr/index and similar.
        //
        buff[lenInBuff+1]='\0';
        
        if (lenInBuff >= sizeof(buff)-1) {
            char * p = index(buff,'#');
            
            NSLog(@"Blew a buffer, %@.",
                  (p ? @"scanning to next '#'" : @"resetting"));
            errCnt++; okCnt = 0;
            
            if (p) {
                lenInBuff = p-buff;
                memcpy(buff,p,lenInBuff);
            } else {
                lenInBuff = 0;
            }
            continue;
        };
 
        while(lenInBuff > 2) // try extracing/parsing what we have
        {            
            char * endCmd;
            
            if (buff[0] == '$') {
                long i = 2 + 128 * 8 +2;
                if ((lenInBuff >= i) && (buff[1] == 'D')) {
                    [self submit:buff withLength:i -2 ];
                    okCnt++;
                    
                    if (logRH) 
                        NSLog(@"$D .. of %ld bytes", i);
                    
                    lenInBuff -= i;
                    memcpy(buff,buff+i,lenInBuff);  

                    // continue straight after with the next command if we can.
                    continue; 
                };
                
                if ((lenInBuff > 2) && (buff[1] == 'S')) {
                    unsigned int  steps = buff[2];
                    unsigned int i = 3 + steps + 2;

                    // current device seems to be 112 only; but
                    // wifi analyser may go as low as 13 and future
                    // devices may hit 255.
                    //
                    if (lenInBuff < i) 
                        break; // gather more data.
                    
                    [self submit:buff withLength:i-2 ];
                    okCnt++;
                    
                    if (logRH) 
                        NSLog(@"$S .. of %u bytes", i);
                        
                    lenInBuff -= i;
                    memcpy(buff,buff+i,lenInBuff);
                    // continue straight after with the next command if we can.
                    continue;
                }
                
                // we'll need more data - break out of the command parsing loop.
                break;
            } // if $
            
            if ((buff[0] == '#') && (endCmd = strnstr(buff,"\r\n",lenInBuff))) {
                long len = endCmd  - buff + 2;
                [self submit:buff withLength:len-2];

                if (logRH)  
                    NSLog(@"#..\\r\\n of %ld bytes", len);

                lenInBuff -= len;
                memcpy(buff,buff+len,lenInBuff);                
                // continue straight after with the next command if we can.
                continue;
            }; // if #
            
            // And finally try for simple ascii strings.
            //
            if ((endCmd = strnstr(buff,"\r\n",lenInBuff))) {
                int i = 0;
                for(i = 0; buff + i < endCmd; i++)
                    if (!(isprint(buff[i])))
                        break;
                
                if (buff + i == endCmd) {
                    long len = endCmd  - buff + 2;
                    [self submit:buff withLength:len-2];
                
                    if (logRH)  
                        NSLog(@"<string>\\r\\n of %ld bytes", len);
                
                    lenInBuff -= len;
                    memcpy(buff,buff+len,lenInBuff);                
                    // continue straight after with the next command if we can.
                    continue;
                }; // if some simple string.
            }; 
            // f we do not have that much data - and no line ending
            // then read a bit more (or timeout on that).
            //
            if (!strnstr(buff,"\r\n",lenInBuff) && lenInBuff < 400)
                break;

            errCnt++; 
            okCnt = 0;

            // Skip over stuff until it looks like something we can deal with.
            //
            long i = 0;
            NSString *rlabel = @"no resync-  ignoring whole buffer";

            for(; i < lenInBuff-2; i++) {
                if (buff[i] == '$' && (buff[i+1] == 'S' || buff[i+1] == 'D')) {
                    rlabel = [NSString stringWithFormat:@"resync on a $%c", buff[i+1]];
                    break;
                }
                if ((buff[i] == '#') && (buff[i+1] == 'C')) {
                    rlabel = @"resync on a #C";
                    break;                   
                };
            };
            
            lenInBuff -= i;
            memcpy(buff, buff+i, lenInBuff);
            
            NSLog(@"Skipping %ld bytes (%ld left) - no ^(\\$[DS]|\\#C)...\\r\\n$ sequence; %@", i, lenInBuff, rlabel);
            if (logRH) 
                [self debug:"skip" buff:buff len:i];
            
        }; // while we can extract stuff
    }; // while read() loop
    
    if (logRH)  
        NSLog(@"%@ Serial listener thread exited on fd %d",self, ofd);
    [pool release];
};

#pragma  mark Cleanups

-(void)close {
    int nfd = fd;
    fd = -1;
    
    if (nfd >=0 ) {
        close(nfd);
        // DebugNSLog(@"Normal close(%d) of %@ on its serial connection.", nfd, self.className);
    };
}

-(void)dealloc {
    if (fd >=0) 
        [self close];
    
    [timeoutTimer invalidate];
    [timeoutTimer release];
    timeoutTimer = nil;

    [path release];
    
    [super dealloc];    
    
}
@end
