//
//  TickMark.m
//  iScope
//
///  Copyright 2011 WebWeaving. All rights reserved.
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

#import "TickMark.h"

@implementation TickMark

@synthesize labelStr;
@synthesize siUnit;
@synthesize value;
@synthesize siPrefix;

-(id) initWithLabelStr:(NSString *)aLabelOrNil
			withSiUnit:(NSString *)aSiUnitOrNil
		  withSiPrefix:(NSString *)aSiPrefixOrNil
			 withValue:(double)aValue
{
	if (!(self = [super init]))
		return nil;
	
	self.labelStr = aLabelOrNil ? aLabelOrNil : @"";
	self.siUnit = aSiUnitOrNil ? aSiUnitOrNil : @"";
	self.siPrefix = aSiPrefixOrNil ? aSiPrefixOrNil : @"";
	self.value = aValue;
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%f/%@%@", value, labelStr, siUnit];
}

-(void)dealloc {
    self.labelStr = nil;
    self.siUnit = nil;
    self.siPrefix = nil;
    
    [super dealloc];
}
@end
