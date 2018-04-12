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

typedef void(^MLCSettingsServiceCompletionHandler)(MLCSettings *_Nullable MLCSettings, NSError *_Nullable error) NS_SWIFT_NAME(MLCSettingsService.CompletionHandler);

NS_SWIFT_NAME(SettingsService)
@interface MLCSettingsService : MLCService

@property (class, nonatomic, strong, readonly) MLCSettings *settings;

+ (instancetype)readSettings:(MLCSettingsServiceCompletionHandler)handler;
+ (void)overrideSettings:(nullable NSDictionary<NSString *, NSString *> *)settings;
+ (void)defaultSettings:(nullable NSDictionary<NSString *, NSString *> *)settings;

@end

NS_SWIFT_NAME(Settings)
@interface MLCSettings : NSObject

/**
 Returns the setting associated with the specified key.

 @param key A key in the settings.
 @return The string associated with the specified key, or nil if the setting was not found or is empty.
 */
- (nullable NSString *)objectForKey:(NSString *)key;
- (nullable NSString *)objectForKeyedSubscript:(NSString *)key;

- (nullable NSDictionary<NSString *, NSString *> *)dictionaryForKey:(NSString *)key;
- (nullable NSArray<NSString *> *)arrayForKey:(NSString *)key;
- (nullable NSURL *)URLForKey:(NSString *)key;
- (nullable NSNumber *)numberForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key NS_SWIFT_UNAVAILABLE("use `number(forKey:)` instead.");
- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue NS_SWIFT_UNAVAILABLE("use `number(forKey:)` instead.");
- (double)doubleForKey:(NSString *)key NS_SWIFT_UNAVAILABLE("use `number(forKey:)` instead.");
- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue NS_SWIFT_UNAVAILABLE("use `number(forKey:)` instead.");
- (BOOL)boolForKey:(NSString *)key NS_SWIFT_UNAVAILABLE("use `number(forKey:)` instead.");
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue NS_SWIFT_UNAVAILABLE("use `number(forKey:)` instead.");

@end

NS_ASSUME_NONNULL_END
