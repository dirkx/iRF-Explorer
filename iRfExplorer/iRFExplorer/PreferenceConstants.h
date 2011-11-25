//
//  PreferenceConstants.h
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

#ifndef iRFExplorer_PreferenceConstants_h
#define iRFExplorer_PreferenceConstants_h

NSString * const kPreferencePngOverPdf;
NSString * const kPreferenceLatexOverTsv;
NSString * const kPreferenceNoImages;
NSString * const kPreferenceLimsIncludeSettings;
NSString * const kPreferenceLimsIncludeHostInfo;
NSString * const kPreferenceLimsIncludeTimeStamps;
NSString * const kPreferenceLimsIncludeDeviceInfo;
NSString * const kPreferenceLimsIncludeComment;
NSString * const kPreferenceLimsCommentString;
NSString * const kPreferenceLineSpeed;
NSString * const kPreferenceTimeStamp;
NSString * const kPreferenceScanRange;
NSString * const kPreferenceSlowSpeed;
NSString * const kPreferenceDecayValue;
NSString * const kPreferenceAvgValue;
NSString * const kPreferenceScanStrategy;
NSString * const kPreferenceLingerTime;
NSString * const kPreferenceSelectedDevice;
NSString * const kPreferenceShowAverage;
NSString * const kPreferenceShowMax;
NSString * const kPreferenceShowTimestamps;
NSString * const kPreferenceShowDecay;
NSString * const kPreferenceScanFullrange;

// Not exposed through UI settings.
NSString * const kCmdLog;
NSString * const kCommsLog;
NSString * const kCommsDebug;

// Sort of hardcoded.
NSString * const kMainFont;
NSString * const kItalicFont;
double const kMainFontSize;
double const kMainMediumFontSize;
double const kMainSmallFontSize;
#endif
