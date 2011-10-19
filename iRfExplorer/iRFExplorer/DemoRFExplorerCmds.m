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

@implementation DemoRFExplorerCmds
@synthesize cmdQue;

#pragma mark init and related sundry such as thread kickoff.

- (id)initWithPath:(NSString *)_path withSlowSpeed:(BOOL)_isSlow {
    cmdQue = [[NSMutableArray alloc] initWithCapacity:10];
    
    path = [_path retain];
    isSlow = _isSlow;
    fd = 1;
    crashMode = [[_path substringWithRange:NSMakeRange(4, 1)] intValue];
    
    [NSThread detachNewThreadSelector:@selector(readerHandler:) toTarget:self withObject:self]; 
    
    NSLog(@"Started %@ in %@ mode and %d bps", 
          self.className, crashMode ? @"crashy" : @"normal", isSlow ? 2400 : 500000);
    
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

-(void)readerHandler:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    lcdRun = spectrumRun = FALSE;
    
    NSLog(@"%@: Listening on fd %d...",self.className, fd);
    while(1)
    {
        char buff[1024];
        int len;
        int bytesRW = 0;

        if (fd < 0)
            break;
        
        if ([cmdQue count] > 0) 
        {
            NSString * cmd = [cmdQue objectAtIndex:0];
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
                [self submitStr:"#C2-M:254,255,00.01\r\n"];
                [self submitStr:"#C2-F:0000000,1000000,-000,-100,0100,0,000,0000000,1000000,0000000\r\n"];
            } else if ([cmd hasPrefix:@"C2-F"]) { 
                [self submitStr:"#C2-F:0000000,1000000,-000,-100,0100,0,000,0000000,1000000,0000000\r\n"];
            } else if ([cmd isEqualToString:@"CH"]) 
            {
                spectrumRun = FALSE;
            } else 
            {
                NSLog(@"Ignoring command '%@'", cmd);
            };
        };
        
        if (spectrumRun) {
            const int N = 100;
            buff[0]='$';
            buff[1]='S';
            buff[2]=N;
            
            // we obviously ought to read this off the microphone and FFT it :)
            for(int i = 0; i < N; i++)
                buff[i+3] = -i/3-45-(rand()&0xF);

            len = 3+N;
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
        NSTimeInterval interval = bytesRW * 8.f / (isSlow ? 2400.f : 500000.f) + 0.092f;
        NSLog(@"Interval %f fo %d bytes", interval, bytesRW);
        
        [NSThread sleepForTimeInterval:interval];    
        
    }; // while read() loop
    
    NSLog(@"serial listener thread exited on fd %d (#%lu)",fd,[self retainCount]);

    [pool release];
};

-(void)dealloc {
    NSLog(@"%@ -- dealloc at demo level", self.className);

    self.cmdQue = nil;
    
    [super dealloc];
}

@end
