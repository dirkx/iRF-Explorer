//
//  ScalerDefinition.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 31/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScalerDefinition : NSObject <NSCoding> {
    NSString * name; double multiplier; int logMultiplier; NSArray * aliases;
}
@property (retain) NSString * name; 
@property (assign) double multiplier; 
@property (assign, readonly) int logMultiplier; 
@property (retain) NSArray * aliases;

-(id)initWithPrefix:(NSString *)aName withMultiplier:(double)m withAliases:(NSArray*)lowercaseAliases;
+(id)scaleDefWithPrefix:(NSString *)aName withMultiplier:(double)m withAliases:(NSArray*)lowercaseAliases;

@end