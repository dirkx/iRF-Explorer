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
    NSString * h = NSLocalizedString(@"h",@"short hour unit");
    NSString * hour = NSLocalizedString(@" hour",@"medium hour unit  - prefix with space where needed");
    NSString * m = NSLocalizedString(@"m",@"short minute unit");
    NSString * min = NSLocalizedString(@" min",@"medium minute unit  - prefix with space where needed");
    NSString * s = NSLocalizedString(@"s",@"short second unit");
    NSString * sec = NSLocalizedString(@" sec",@"medium second unit - prefix with space where needed");

    if (f > 5000) {
        return [NSString stringWithFormat:@"%.1f%@",
                f / 60 / 60, keepShort ? h : hour];
    }
    if (f > 1000) {
        return [NSString stringWithFormat:@"%.0f%@",
                f / 60, keepShort ? m : min];
    }
    if (f > 100) {
        return [NSString stringWithFormat:@"%.1f%@",
                f / 60, keepShort ? m : min];
    }
    return [NSString stringWithFormat:@"%.1f%@",
            f, keepShort ? s : sec];
}

+(id)stringFromSeconds:(double)v {
    NSString * minuteLabel = NSLocalizedString(@"minute",@"Long minute unit");
    NSString * secondLabel = NSLocalizedString(@"second",@"Long second unit");
    NSString * minutesLabel = NSLocalizedString(@"minutes",@"Long minute unit");
    NSString * secondsLabel = NSLocalizedString(@"seconds",@"Long second unit");

    NSString *label = secondLabel;
    NSString *labels = secondsLabel;
    
    NSString * fmt = @"%.1f %@";
    if (v > 400) {
        v /= 60;
        fmt = @"%.0f %@";
        label = minuteLabel;
        labels = minutesLabel;
    }
    else if (v > 120) {
        v /= 60;
        fmt = @"%.1f %@";
        label = minuteLabel;
        labels = minutesLabel;
    };
    return [NSString stringWithFormat:fmt, v, (v >= 2.0) ? labels : label];
}

+(double)secondsFromString:(NSString *)s {
    NSString * h = NSLocalizedString(@"h",@"short hour unit");
    NSString * hour = NSLocalizedString(@" hour",@"medium hour unit  - prefix with space where needed");
    NSString * hours = NSLocalizedString(@" hours",@"medium hour unit plural  - prefix with space where needed");
    NSString * m = NSLocalizedString(@"m",@"short minute unit");
    NSString * min = NSLocalizedString(@" min",@"medium minute unit  - prefix with space where needed");
    NSString * mins = NSLocalizedString(@" mins",@"medium minute unit plural - prefix with space where needed");

    double v = [s doubleValue];
    
    if ([s hasSuffix:m] || [s hasSuffix:min] || [s hasSuffix:mins])
        v *= 60;
    if ([s hasSuffix:h] || [s hasSuffix:hour] || [s hasSuffix:hours])
        v *= 60*60;

    return v;
}

+(id)stringFromDate:(NSDate *)age keepShort:(BOOL)keepShort {
    double f = -[age timeIntervalSinceNow];

    // we display just the date after 4 days.
    //
    if (fabs(f) > 3600 * 24 * 4) {
        NSDateFormatter * ndf = [[[NSDateFormatter alloc] init] autorelease];
        [ndf setDateStyle:NSDateFormatterShortStyle];
        [ndf setTimeStyle:NSDateFormatterNoStyle];
        return [ndf stringFromDate:age];
    }
    // when it is more than 4 hours we show the time
    //
    if (fabs(f) > 3600 * 4) {
        NSDateFormatter * ndf = [[[NSDateFormatter alloc] init] autorelease];
        [ndf setDateStyle:NSDateFormatterNoStyle];
        [ndf setTimeStyle:NSDateFormatterShortStyle];
        return [ndf stringFromDate:age];
    }
    
    // and anything shorter - we show the age in secnds.
    //
    return [NSString stringFromSeconds:f keepShort:YES];
}

// String where we try to keep the extra zero's as limited as we can.
//
+(id)stringFromDouble:(double) v {
    NSString * label;
    double c = fabs(v);
    if (c == floor(c)) {
        label = [NSString stringWithFormat:@"%.0f", v];
    } else if (c*10 == floor(10*c)) {
        label = [NSString stringWithFormat:@"%.01f", v];
    } else if (c*100 == floor(100*c)) {
        label = [NSString stringWithFormat:@"%.02f", v];
    } else if (c*3 == floor(3*c)) {
        label = [NSString stringWithFormat:@"%.02f", v];
    } else if (c*6 == floor(6*c)) {
        label = [NSString stringWithFormat:@"%.02f", v];
    } else {
        label = [NSString stringWithFormat:@"%.3f", v];
    }
    return label;
}

+(id)stringFromHz:(double)f {
    NSString * unit = @"Hz";
    NSString * fmt = @"%@ %@";
    
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
    return [NSString stringWithFormat:fmt, [NSString stringFromDouble:f] ,unit];
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

-(BOOL)contains:(NSString *)aSubstring {
    NSRange r = [self rangeOfString:aSubstring];
    return r.location != NSNotFound;
}

@end
