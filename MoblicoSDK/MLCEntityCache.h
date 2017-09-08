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

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(EntityCache)
@interface MLCEntityCache : NSObject

+ (id)retrieveEntityWithKey:(NSString *)key;
+ (BOOL)persistEntity:(id<NSCoding>)object key:(NSString *)key error:(NSError **)error;
+ (BOOL)clearEntityWithKey:(NSString *)key error:(NSError **)error;
+ (BOOL)clearCache:(NSError **)error;
+ (BOOL)entityExistsWithKey:(NSString *)key;

@end
