//
//  ScalerDefinition.m
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
    logMultiplier = 3*floor(log(m)/3.0);
    
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
