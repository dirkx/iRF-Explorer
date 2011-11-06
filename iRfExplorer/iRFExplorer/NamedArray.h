//
//  NamedArray.h
//  iRFExplorer
//
//  Created by Dirk-WIllem van Gulik on 27/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
    
