//
//  ScalerDefinition.h
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