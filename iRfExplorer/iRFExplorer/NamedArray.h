//
//  NamedArray.h
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

typedef enum { FORMAT_PLAIN, FORMAT_LATEX, FORMAT_TSV } format_t;

@interface NamedArray : NSArray {
    NSString * title;
    NSMutableArray * items;
}
@property (retain) NSString *title;
@property (retain) NSMutableArray *items;

-(id)initWithTitle:(NSString*)aTitle;
-(void)addValue:(NSString *)aValue withTitle:(NSString *)aKey;

-(NSString*)descriptionWithFormat:(format_t)fmt;
+(NSString*)descriptionFromArray:(NSArray*)someNamedArrays withTitle:(NSString*)aTitle withFormat:(format_t)format;
@end

@interface InfoPair : NSObject {
    NSString * key, * val;
}

@property (retain) NSString *key, *val;

+(id)pairWithValue:(NSString *)aValue andTitle:(NSString *)aKey;
-(NSString*)descriptionWithFormat:(format_t)fmt;
@end
    
