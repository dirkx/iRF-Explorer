//
//  NSStringExtensions.h
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

@interface NSString (MyExtensions);

+(id)stringWithCString:(const char*)buff withLength:(int)len encoding:(NSStringEncoding)enc;
-(BOOL)contains:(NSString *)aSubstring;

+(id)stringFromAge:(double)seconds keepShort:(BOOL)keepShort;
+(id)stringFromDate:(NSDate *)age keepShort:(BOOL)keepShort;

+(id)stringFromHz:(double)f;

+(id)stringFromSeconds:(double)seconds;
+(id)stringFromSeconds:(double)f keepShort:(BOOL)keepShort;
+(double)secondsFromString:(NSString *)s;
+(id)stringFromDouble:(double) v;

-(NSString*)asLatex;
@end
