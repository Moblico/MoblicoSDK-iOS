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

@import Foundation;
@class MLCValidations;

/**
 Base class for all Moblico model objects.
 */
NS_SWIFT_NAME(Entity)
@interface MLCEntity : NSObject
@property (nonatomic, readonly, strong) id uniqueIdentifier;

- (instancetype)initWithJSONObject:(NSDictionary<NSString *, id> *)jsonObject;
+ (NSDictionary<NSString *, id> *)serialize:(MLCEntity *)entity;

+ (NSString *)collectionName;
+ (NSString *)resourceName;

+ (NSString *)uniqueIdentifierKey;

@property (nonatomic, readonly, class, strong) MLCValidations *validations;
- (BOOL)validate:(out NSError *__autoreleasing *)error;

@end
