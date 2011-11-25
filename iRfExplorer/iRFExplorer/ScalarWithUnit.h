//
//  ScalarWithUnit.h
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
