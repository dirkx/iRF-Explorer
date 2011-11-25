//
//  DemoRFExplorerCmds.m
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

#import "DemoRFExplorerCmds.h"

#import "NSStringExtensions.h"
#import "LCDImage.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation DemoRFExplorerCmds
@synthesize cmdQue;

// experimentally found value - makes standard mic on an
// MBA sorta look Ok when talking at normal volume.
//
double const kGAIN = 0.31;

#pragma mark init and related sundry such as thread kickoff.

- (id)initWithPath:(NSString *)_path withSlowSpeed:(BOOL)_isSlow {
    self = [super init];
    if (self == nil)
        return nil;
    
    if ((scl = [SCListener sharedListener]) == nil) {
        [self release];
        return nil;
    }    
    
    cmdQue = [[NSMutableArray alloc] initWithCapacity:10];
    
    path = [_path retain];
    isSlow = _isSlow;
    fd = 1;
    crashMode = [[_path substringWithRange:NSMakeRange(4, 1)] intValue];
    
    minFreq = 0;
    maxFreq =  kSAMPLERATE / 4;
    maxSpan = maxFreq - minFreq;
    
    startFreq = 200;
    endFreq =   kSAMPLERATE / 4;
    
    steps = 100;
    
    // complete lie - we just picked something which sora looked OK.
    botAmp = -120;
    topAmp = -1;
    
    [NSThread detachNewThreadSelector:@selector(readerHandler:) 
                             toTarget:self 
                           withObject:nil]; 
    
    return self;
}

-(BOOL)sendCmd:(NSString *)cmd {
    if (fd<0) 
        return FALSE;
        
    [cmdQue addObject:cmd];
    return true;
}

-(void)submitStr:(const char *)str {
    [self submit:str withLength:strlen(str)];
}

#pragma mark Receive thread - where we fake up our stuff.

// RFExplorer to PC
// #C2-F:<Start_Freq KHZ>, <Freq_Step HZ>, <Amp_Top>, <Amp_Bottom>, <Sweep_Steps>, <ExpModuleActive>, 
//    <CurrentMode>, <Min_Freq KHZ>, <Max_Freq KHZ>, <Max_Span KHZ> <EOL>
-(NSString *)c2String {
    return [NSString stringWithFormat:@"#C2-F:%07ld,%07d,-%03.0f,-%03.0f,%04d,%1d,%03d,%07d,%07d,%07d\r\n",
            (long)floor(startFreq/1000.),
            (long)floor((endFreq-startFreq)/steps), 
            -topAmp,
            -botAmp,
            steps,
            0, // not using the expansion card.
            MODE_SPECTRUM_ANALYZER,
            (long)floor(minFreq/1000.),
            (long)floor(maxFreq/1000.),
            (long)floor(maxSpan/1000.)
            ];
}

-(void)readerHandler:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    lcdRun = spectrumRun = FALSE;
    
    // NSLog(@"%@: Listening on fd %d...",self.className, fd);
    while(1)
    {
        char buff[1024];
        int len;
        NSUInteger bytesRW = 0;

        if (fd < 0)
            break;
        
        if ([cmdQue count] > 0) 
        {
            NSString * cmd = [NSString stringWithString:[cmdQue objectAtIndex:0]];
            [cmdQue removeObjectAtIndex:0];

            bytesRW += [cmd length];
            
            if ([cmd isEqualToString:@"D1"]) {
                lcdRun = TRUE;
            } else if ([cmd isEqualToString:@"D0"]) 
            {
                lcdRun = FALSE;
            } else if ([cmd isEqualToString:@"C0"]) 
            { 
                spectrumRun = TRUE;
                [scl listen];
                [self submitStr:"#C2-M:254,255,00.01\r\n"];
                [self submitStr:[[self c2String] UTF8String]];
                
            } else if ([cmd hasPrefix:@"C2-F"]) { 
                const char * p = [cmd UTF8String];
                long fAmplitudeTop, fAmplitudeBottom;
                long startFreqKhz, endFreqKhz;

                // #<Size>C2-F:<Start_Freq KHZ>, <End_Freq KHZ>, <Amp_Top>, <Amp_Bottom
                // PC to RF Explorer
                //
                sscanf(p+6,"%ld,%ld,%ld,%ld",
                       &startFreqKhz, &endFreqKhz, 
                       &fAmplitudeTop, &fAmplitudeBottom);
                                
                startFreq = 1000. * startFreqKhz;
                endFreq =  1000. * endFreqKhz;
                topAmp = (int)fAmplitudeTop;
                botAmp = (int)fAmplitudeBottom;
                
                [self submitStr:[[self c2String] UTF8String]];
            } else if ([cmd isEqualToString:@"CH"]) 
            {
                spectrumRun = FALSE;
                [scl pause];
            } else 
            {
                NSLog(@"Ignoring command '%@'", cmd);
            };
        };
        
        if (spectrumRun) {
            memset(buff,255,steps+3);
            buff[0]='$';
            buff[1]='S';
            buff[2]=steps;
            // we obviously ought to read this off the microphone and FFT it :)
            //
            [scl frequency]; // Have to all this -- as otherwise we get no FFT done.
            [[SCListener sharedListener] frequency];

            int fftN = kFFTSIZE / 2;
            double fftMin = 0;
            double fftRange = kSAMPLERATE / 2;
            double fftSpan = fftRange / fftN;
            double spanRage = endFreq - startFreq;
            double bwidth = spanRage / steps;
            
            for(int i = 0; i < steps; i++) {
                double f = startFreq + i * bwidth;
                
                long j = (f - fftMin) / fftSpan;
                double v = 0; int n = 0;
                
                while(j < fftN) {
                    v += [scl freq_db][j];
                    j++; n++;
                    
                    double ff = fftMin + j * fftSpan;
                    if (ff >= f + bwidth)
                        break;
                }

                if (n == 0)
                    continue;
                v /= n;
                
                // Calculate to device space. We do a bit
                // of divide to get into a somewhat sensible
                // range;
                v = -120 + v*kGAIN;

                if (v <= botAmp)
                    continue;
                if (v >= topAmp)
                    v = topAmp;
                
                buff[i+3] = (unsigned char)((127 - v) * 2);
            }                
            
            len = 3+steps;
            [self submit:buff withLength:len];
            bytesRW += len;
        }
        
        if (lcdRun) {
            buff[0]='$';
            buff[1]='D';
            for(int x = 0; x < 128; x++) {
                for(int y = 0; y < 8; y++) {
                    buff[2 + x + y*128] = rand() & 0xFF;
                }
            }
            len = 128 * 8 + 2;
            
            [self submit:buff withLength:len];
            bytesRW += len;
        }
        
        // sleep to mimic 500k/2400 baud speeds and the 0.03-6 delay we seem to
        // observe in practice for any type of turn around.
        //
        NSTimeInterval interval = (NSTimeInterval)(bytesRW) * 8.f / (isSlow ? 2400.f : 500000.f) + 0.2f;
        
        [NSThread sleepForTimeInterval:interval];            
    }; // while read() loop
    
    // NSLog(@"serial listener thread exited on fd %d (#%lu)",fd,[self retainCount]);

    [pool release];
    [NSThread exit];
};

-(void)dealloc {
    if (spectrumRun)
        [scl stop];
    
    self.cmdQue = nil;
    [super dealloc];
}

@end
