//
//  LCDImage.h
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

#import <AppKit/AppKit.h>

@interface LCDImage : NSImage

/* The lcdByteArray is organized as 8 consecutive 
 * rows of 128 bytes each Organized top to bottom. Every bit within the byte represents 
 * a pixel ON(1) or OFF(0) being the MSB the upper pixel and the LSB the bottom pixel 
 * within the row.	
 */
+(id)imageWithLCD:(const char *)lcdByteArray;
+(id)imageWithReticule;
@end
