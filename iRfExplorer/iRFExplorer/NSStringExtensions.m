//
//  NSStringExtensions.m
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

#import "NSStringExtensions.h"

@implementation NSString (MyExtensions);

+(id)stringWithCString:(const char*)buff withLength:(int)len encoding:(NSStringEncoding)enc {
    const char * str = strndup(buff,len);
    
    return [NSString stringWithCString:str encoding:enc];
}

+(id)stringFromMhz:(float)f {
    NSString * unit = @"Mhz";
    NSString * fmt = @"%.2f %@";
    
    if (f > 1200.0) {
        unit = @"Ghz";
        f /= 1000.0;
    } else {
        if (f < 1.5) {
            unit = @"Khz";
            f *= 1000.0;
            fmt = @"%.1f %@";
        }
        if (f < 1.5) {
            unit = @"hz";
            f *= 1000.0;
            fmt = @"%.0f %@";
        }
    }    
    return [NSString stringWithFormat:fmt, f,unit];
}

+(id)stringFromSeconds:(float)v {
    NSString * fmt = @"%.1f second%s";
    if (v > 400) {
        v /= 60;
        fmt = @"%.0f minute%s";
    }
    else if (v > 120) {
        v /= 60;
        fmt = @"%.1f minute%s";
    };
    return [NSString stringWithFormat:fmt, v, (v >= 2.0) ? "s" : ""];
}

@end
