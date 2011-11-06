//
//  ScalarWithUnit.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 30/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScalarWithUnit : NSObject <NSCoding> {
    double scalar, multiplier;
    NSString * unit, * prefix;
    NSArray * prefixes;
}
@property (assign) double scalar;
@property (retain) NSString *unit;

@property (retain, readonly) NSString *suffix;
@property (retain) NSString *displayStringValue;
@property (retain) NSString *stringValue;
@property (assign) double displayValue;
@property (assign, readonly) double multiplier;

-(id)initScalar:(double)aValue;
-(id)initScalar:(double)aValue withUnit:(NSString *)unit;
-(id)initScalar:(double)aValue withUnit:(NSString *)aUnit withPrefixes:(NSArray *)aSetOfOrderedPrefixes;
@end
