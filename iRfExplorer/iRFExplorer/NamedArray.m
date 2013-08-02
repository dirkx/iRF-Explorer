//
//  NamedArray.m
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

#import "NamedArray.h"
#import "NSStringExtensions.h"

@implementation NamedArray
@synthesize title, items;

-(id)initWithTitle:(NSString*)aTitle {
    self = [self init];
    if (self)
        self.title = aTitle;
    self.items = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    return self;
}

-(NSUInteger)count {
    return [items count];
}

-(NSString*)description {
    return [self descriptionWithFormat:FORMAT_PLAIN];
}

-(NSString*)descriptionWithFormat:(format_t)format {
    NSMutableString * out = [NSMutableString string];

    switch(format) {
        case FORMAT_TSV: 
            [out appendFormat:@"%@\n",title];
            
            for(InfoPair * item in items) {
                [out appendFormat:@"\t%@\t%@\n", item.key, item.val];   
            }
            [out appendFormat:@"\n"];
            break;
        case FORMAT_LATEX:
            [out appendFormat:@""
             "\t\t\t\\hline\n"
             "\t\t\t\\multicolumn{2}{|l|}{%@} \\\\\n"
             "\t\t\t\\hline\n",[title asLatex]];
            for(InfoPair * item in items) {
                [out appendFormat:@""
                 "\t\t\t\t" "%@ & %@\\\\ \\hline\n", [item.key asLatex], [item.val asLatex]];    
            }
            break;
        case FORMAT_PLAIN:
        default:
            [out appendFormat:@"%@\n",title];
            
            for(NSObject * item in items) {
                [out appendFormat:@"\t%@", item];
            }
            [out appendFormat:@"\n"];
            break;
    };
    
    return out;
}
+(NSString*)descriptionFromArray:(NSArray*)someNamedArrays withTitle:(NSString*)aTitle withFormat:(format_t)format {
    NSMutableString * out = [NSMutableString string];
    
    switch(format) {
        case FORMAT_LATEX:
            [out appendFormat:@""
             "\\begin{table}[htdp]\n"
             "  %% ensure that \\usepackage{multirow} is included in the pre-amble\n"
             "  %%\n"
             "  \\caption{Settings of the %@ Spectrum Analyser}\n"
             "  \\label{SettingsTable_%05ld}\n"
             "  %%\n"
             "  \\begin{center}\n"
             "      \\begin{tabular}{|r|l|}\n"
             , [aTitle asLatex], time(NULL)];
            break;
        default:
            [out appendFormat:@"%@\n", aTitle];
            break;
    };
    
    for(NamedArray * item in someNamedArrays) {
        [out appendString:[item descriptionWithFormat:format]];
    }

    switch(format) {
        case FORMAT_LATEX:
            [out appendString:@""
             "      \\end{tabular}\n"
             "  \\end{center}\n"
             "\\end{table}\n"
             ];
            break;
        default:
            [out appendFormat:@"\n"];
            break;
    };
    
    return out;
}

-(void)addValue:(NSString *)aValue withTitle:(NSString *)aKey {
    [items addObject:[InfoPair pairWithValue:aValue andTitle:aKey]];
}

-(void)dealloc {
    self.items = nil;
    self.title = nil;
    [super dealloc];
}

@end

@implementation InfoPair
@synthesize key, val;

+(id)pairWithValue:(NSString *)aValue andTitle:(NSString *)aKey {
    InfoPair * p = [[InfoPair alloc] init];
    p.key = aKey;
    p.val = aValue;
    return [p autorelease];
}

-(NSString*)description {
    return [self descriptionWithFormat:FORMAT_PLAIN];
}

-(NSString*)descriptionWithFormat:(format_t)format {
    NSMutableString * out = [NSMutableString string];
    
    [out appendFormat:@"%@:\t%@", key, val];

    return out;
}

-(void)dealloc {
    self.key = nil;
    self.val = nil;
    [super dealloc];
}
@end
