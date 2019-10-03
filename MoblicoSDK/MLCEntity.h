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

@class MLCValidations;

NS_ASSUME_NONNULL_BEGIN

/**
 Base class for all Moblico model objects.
 */
NS_SWIFT_NAME(Entity)
@interface MLCEntity : NSObject<NSCoding, NSCopying>
@property (nonatomic, readonly, strong, nullable) NSString *uniqueIdentifier;

- (nullable instancetype)initWithJSONObject:(nullable NSDictionary<NSString *, id> *)jsonObject;
+ (nullable NSDictionary<NSString *, id> *)serialize:(nullable __kindof MLCEntity *)entity;

+ (NSString *)collectionName;
+ (NSString *)resourceName;

+ (NSString *)uniqueIdentifierKey;
- (BOOL)isEquivalent:(id)object;

@property (nonatomic, readonly, class, strong) MLCValidations *validations;
- (BOOL)validate:(out NSError **)error;

@end

NS_ASSUME_NONNULL_END
