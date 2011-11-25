//
//  ScalerDefinition.m
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

#import "ScalerDefinition.h"

@implementation ScalerDefinition
@synthesize name, multiplier, logMultiplier, aliases;

+(id)scaleDefWithPrefix:(NSString *)aName withMultiplier:(double)m withAliases:(NSArray*)lowercaseAliases {
    ScalerDefinition * sd = [[ScalerDefinition alloc] initWithPrefix:aName withMultiplier:m withAliases:lowercaseAliases];
    return [sd autorelease];
}

-(id)initWithPrefix:(NSString *)aName withMultiplier:(double)m withAliases:(NSArray*)als {
    self = [self init];
    
    self.name = aName;
    self.aliases = als;
    multiplier = m; 
    logMultiplier = 3*floorf((float)log(m)/3.0f);
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:name forKey:@"aliases"];
    [coder encodeDouble:multiplier forKey:@"multiplier"];
}

- (id)initWithCoder:(NSCoder *)coder {
    NSString * n = [coder decodeObjectForKey:@"name"];
    NSArray * a = [coder decodeObjectForKey:@"aliases"];
    double m = [coder decodeDoubleForKey:@"multiplier"];    
    return [[ScalerDefinition scaleDefWithPrefix:n withMultiplier:m withAliases:a] retain];
}

-(void)dealloc { 
    self.name = nil; 
    self.aliases = nil; 
    [super dealloc]; 
};
@end
