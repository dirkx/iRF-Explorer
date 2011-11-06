//
//  NSStringExtensions.m
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

#import "NSStringExtensions.h"

@implementation NSString (MyExtensions);

+(id)stringWithCString:(const char*)buff withLength:(int)len encoding:(NSStringEncoding)enc {
    const char * str = buff; // strndup(buff,len);
    
    return [NSString stringWithCString:str encoding:enc];
}

+(id)stringFromAge:(double)seconds keepShort:(BOOL)keepShort {
    NSDate * d = [NSDate dateWithTimeIntervalSinceNow:-seconds];
    return [NSString stringFromDate:d keepShort:keepShort];
}

+(id)stringFromSeconds:(double)f keepShort:(BOOL)keepShort {
    if (f > 5000) {
        return [NSString stringWithFormat:@"%.1f%@",
                f / 60 / 60, keepShort ? @"h" : @" hour"];
    }
    if (f > 1000) {
        return [NSString stringWithFormat:@"%.0f%@",
                f / 60, keepShort ? @"m" : @" min"];
    }
    if (f > 100) {
        return [NSString stringWithFormat:@"%.1f%@",
                f / 60, keepShort ? @"m" : @" min"];
    }
    return [NSString stringWithFormat:@"%.1f%@",
            f, keepShort ? @"s" : @" sec"];
}

+(id)stringFromSeconds:(double)v {
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

+(double)secondsFromString:(NSString *)s {
    double v = [s doubleValue];
    
    if ([s hasSuffix:@"m"] || [s hasSuffix:@"min"] || [s hasSuffix:@"mins"])
        v *= 60;
    if ([s hasSuffix:@"h"] || [s hasSuffix:@"hour"] || [s hasSuffix:@"hours"])
        v *= 60*60;

    return v;
}

+(id)stringFromDate:(NSDate *)age keepShort:(BOOL)keepShort {
    double f = -[age timeIntervalSinceNow];

    // we display just the date after 4 days.
    //
    if (fabs(f) > 3600 * 24 * 4) {
        NSDateFormatter * ndf = [[NSDateFormatter alloc] init];
        [ndf setDateStyle:NSDateFormatterShortStyle];
        [ndf setTimeStyle:NSDateFormatterNoStyle];
        return [ndf stringFromDate:age];
    }
    // when it is more than 4 hours we show the time
    //
    if (fabs(f) > 3600 * 4) {
        NSDateFormatter * ndf = [[NSDateFormatter alloc] init];
        [ndf setDateStyle:NSDateFormatterNoStyle];
        [ndf setTimeStyle:NSDateFormatterShortStyle];
        return [ndf stringFromDate:age];
    }
    // and anything shorter - we show the age in secnds.
    //
    return [NSString stringFromSeconds:f keepShort:YES];
}

+(id)stringFromHz:(double)f {
    NSString * unit = @"Hz";
    NSString * fmt = @"%.2f %@";
    
    if (f > 1200.0) {
        unit = @"Khz";
        f /= 1000.0;
    }    
    if (f > 1500.0) {
        unit = @"Mhz";
        f /= 1000.0;
    }    
    if (f > 3000.0) {
        unit = @"Ghz";
        f /= 1000.0;
    }   
    return [NSString stringWithFormat:fmt, f,unit];
}

-(NSString*)asLatex {
    NSMutableString *s = [NSMutableString stringWithString:self];
    for(NSString * c in [NSArray arrayWithObjects:@"_",@"&",@"#", nil]) {
        [s replaceOccurrencesOfString:c
                           withString:[NSString stringWithFormat:@"\\%@", c]
                              options:0 
                                range:NSMakeRange(0, [s length])];
    };
    return s;
}


@end
