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

#import <MoblicoSDK/MLCService.h>
@class MLCSettings;
NS_ASSUME_NONNULL_BEGIN

typedef void(^MLCSettingsServiceCompletionHandler)(MLCSettings * _Nullable MLCSettings,  NSError * _Nullable error, NSHTTPURLResponse * _Nullable response);

@interface MLCSettingsService : MLCService
@property (class, nonatomic, strong, readonly) MLCSettings *settings;

+ (instancetype)readSettings:(MLCSettingsServiceCompletionHandler)handler;
+ (void)overrideSettings:(nullable NSDictionary *)settings;

@end


@interface MLCSettings : NSObject

- (nullable NSString *)objectForKey:(NSString *)key;
- (nullable NSString *)objectForKeyedSubscript:(NSString *)key;

- (nullable NSDictionary<NSString *, NSString *> *)dictionaryForKey:(NSString *)key;
- (nullable NSArray<NSString *> *)arrayForKey:(NSString *)key;
- (nullable NSURL *)URLForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
- (double)doubleForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue;
- (BOOL)boolForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

@end

NS_ASSUME_NONNULL_END
