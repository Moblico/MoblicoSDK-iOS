/*
 Copyright 2012 Moblico Solutions LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MLCEntity.h"

@interface MLCEntity ()
@property (nonatomic, strong) NSMutableDictionary *_scalarValues;
+ (NSString *)stringFromValue:(id)value;
+ (NSDate *)dateFromTimeStampValue:(id)value;

+ (BOOL)boolFromValue:(id)value;
+ (float)floatFromValue:(id)value;
+ (double)doubleFromValue:(id)value;
+ (int)intFromValue:(id)value;
+ (unsigned long)unsignedLongFromValue:(id)value;
+ (unsigned long long)unsignedLongLongFromValue:(id)value;
+ (long)longFromValue:(id)value;
+ (unsigned)unsignedFromValue:(id)value;
+ (short)shortFromValue:(id)value;

+ (NSNumber *)numberFromDoubleValue:(id)value;
+ (NSNumber *)numberFromIntegerValue:(id)value;
+ (NSNumber *)numberFromBoolValue:(id)value;

+ (NSURL *)URLFromValue:(id)value;
+ (NSArray *)arrayFromValue:(id)value;
+ (NSDictionary *)dictionaryFromValue:(id)value;

//- (BOOL)validate:(NSError**)error;
- (void)setSafeValue:(id)value forKey:(NSString *)key;

+ (NSArray *)ignoredPropertiesDuringSerialization;
+ (NSArray *)ignoredPropertiesDuringDeserialization;

+ (NSDictionary *)renamedPropertiesDuringSerialization;
+ (NSDictionary *)renamedPropertiesDuringDeserialization;

@end
