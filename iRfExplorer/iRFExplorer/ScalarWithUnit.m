//
//  ScalarWithUnit.m
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
#import "ScalarWithUnit.h"
#import "ScalerDefinition.h"
#import "NoPrefixes.h"

@implementation ScalarWithUnit
@synthesize multiplier, scalar, unit;

-(id)initScalar:(double)aValue withUnit:(NSString *)aUnit withPrefixes:(NSArray *)aSetOfOrderedPrefixes {
    if ((self = [super init]) == nil)
        return nil;
    
    self.scalar = aValue;
    unit = [aUnit retain];
    prefixes = [aSetOfOrderedPrefixes retain];
    return self;
}

-(id)initScalar:(double)aValue withUnit:(NSString *)aUnit {
    return [self initScalar:aValue withUnit:aUnit withPrefixes:[NoPrefixes defs]];
}

-(id)initScalar:(double)aValue {
    return [self initScalar:aValue withUnit:@"" withPrefixes:[NoPrefixes defs]];   
}

-(double)scalar {
    return scalar;
}

-(void)setScalar:(double)aValue {
    scalar = aValue;

    prefix = ((ScalerDefinition *)[prefixes objectAtIndex:0]).name;
    multiplier = ((ScalerDefinition *)[prefixes objectAtIndex:0]).multiplier;
    
    for(ScalerDefinition *sd in prefixes) {
        if (sd.multiplier == 1) {
            if (aValue < 0.1 * sd.multiplier)
                break;
        } else {
            if (aValue < 1.2 * sd.multiplier) 
                break;
        }
        prefix = sd.name;
        multiplier = sd.multiplier;        
    };
    return;
}

-(void)setStringValue:(NSString *)aString {
    NSString * s = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    double v = [s doubleValue];
    
    if ([[s lowercaseString  ]hasSuffix:[unit lowercaseString]]) {
        s = [s substringToIndex:s.length - unit.length];
        s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    };
    
    // Compare the official values first, case sensitive
    //
    for(ScalerDefinition *sd in prefixes) {
        if ([sd.name length] == 0)
            continue;
        
        if ([s hasSuffix:sd.name]) {
            multiplier = sd.multiplier;
            prefix = sd.name;
            self.scalar = v * multiplier;
            return;
        }
    }
    
    
    // And only when that fails do we try the case insensitive aliases.
    //
    s = [s lowercaseString];    
    for(ScalerDefinition *sd in prefixes) {
        for(NSString *alias in sd.aliases) {
            if ([alias length] == 0)
                continue;

            if ([s hasSuffix:alias]) {
                multiplier = sd.multiplier;
                prefix = sd.name;
                self.scalar = v * multiplier;
                return;
            }
        }
    };

    self.scalar = v * multiplier;
    return;
}
                   
-(NSString*)stringValue {
    NSString * fmt = @"%.3f %@";
    double v = [self displayValue];
    if (floor(100*v) == 100*v)
        fmt = @"%.1f";
    else
    if (floor(10*v) == 10*v)
        fmt = @"%.1f";
    
    return [NSString stringWithFormat:fmt,[self displayValue], [self suffix]];
}

-(void)setDisplayValue:(double)aDisplayValue {
    self.scalar = aDisplayValue * multiplier;
}

-(double)displayValue {
    return scalar / multiplier;
}

-(void)setDisplayStringValue:(NSString *)aDisplayStringValue {
    double aDisplayValue = [aDisplayStringValue doubleValue];
    
    self.scalar = aDisplayValue * multiplier;
}

-(NSString *)displayStringValue {
    return [NSString stringWithFormat:@"%.2f",[self displayValue]];
}

-(NSString*)suffix {
    return [NSString stringWithFormat:@"%@%@",prefix, unit];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:scalar forKey:@"value"];
    [coder encodeObject:unit forKey:@"unit"];
    [coder encodeObject:prefixes forKey:@"prefixes"];
}

- (id)initWithCoder:(NSCoder *)coder {
    double s = [coder decodeDoubleForKey:@"value"];
    NSString * u = [coder decodeObjectForKey:@"unit"];
    NSArray * a = [coder decodeObjectForKey:@"prefixes"];
    return [[ScalarWithUnit alloc] initScalar:s withUnit:u withPrefixes:a];
}

-(void)dealloc {
    self.unit = nil;
    [super dealloc];
}
@end


