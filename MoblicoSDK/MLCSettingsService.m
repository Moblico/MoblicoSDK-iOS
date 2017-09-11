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

#import "MLCSettingsService.h"
#import "MLCService_Private.h"
#import "MLCEntity_Private.h"

static NSString *const MLCSettingsDefaultKey = @"MLCSettingsDefault";

@interface MLCSettings ()

@property (nonatomic, copy) NSDictionary *dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, class, copy, readonly) NSNumberFormatter *numberFormatter;
@end

@implementation MLCSettingsService

+ (Class)classForResource {
    return Nil;
}

+ (instancetype)readSettings:(MLCSettingsServiceCompletionHandler)handler {
    return [self service:MLCServiceRequestMethodGET path:@"settings" parameters:nil handler:^(id jsonObject, NSError *error) {
        MLCSettings *settings = nil;
        if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
            [NSUserDefaults.standardUserDefaults setObject:jsonObject forKey:@"MLCSettings"];
            [NSUserDefaults.standardUserDefaults synchronize];
            settings = self.settings;
        }
        handler(settings, error);
    }];
}

+ (MLCSettings *)settings {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDictionary *settings = [defaults dictionaryForKey:@"MLCSettings"] ?: @{};
    NSDictionary *settingsDefault = [defaults dictionaryForKey:@"MLCSettingsDefault"] ?: @{};
    NSDictionary *settingsOverride = [defaults dictionaryForKey:@"MLCSettingsOverride"] ?: @{};

    NSMutableDictionary *dictionary = [settingsDefault mutableCopy];
    [dictionary addEntriesFromDictionary:settings];
    [dictionary addEntriesFromDictionary:settingsOverride];

    return [[MLCSettings alloc] initWithDictionary:dictionary];
}

+ (void)overrideSettings:(NSDictionary *)overrideSettings {
    [NSUserDefaults.standardUserDefaults setObject:overrideSettings forKey:@"MLCSettingsOverride"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)defaultSettings:(NSDictionary *)defaultSettings {
    [NSUserDefaults.standardUserDefaults setObject:defaultSettings forKey:@"MLCSettingsDefault"];
    [NSUserDefaults.standardUserDefaults synchronize];
}


@end

@implementation MLCSettings

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _dictionary = dictionary;
    }
    return self;
}

- (nullable NSString *)objectForKey:(NSString *)key {
    return [MLCEntity nilIfEmptyStringFromValue:self.dictionary[key]];
}

- (nullable NSString *)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}


- (nullable NSDictionary *)dictionaryForKey:(NSString *)key {
    NSString *value = [self objectForKey:key];
    if (!value) {
        return nil;
    }

    NSMutableDictionary *map = [@{} mutableCopy];

    for (NSString *pair in [value componentsSeparatedByString:@";"]) {
        NSArray *keyValue = [pair componentsSeparatedByString:@","];
        if (keyValue.count < 2) {
            continue;
        }
        if (keyValue.count > 2) {
            NSRange range = NSMakeRange(1, keyValue.count);
            NSArray *subarray = [keyValue subarrayWithRange:range];
            NSString *remainder = [subarray componentsJoinedByString:@","];
            keyValue = @[keyValue.firstObject, remainder];
        }
        map[keyValue.firstObject] = keyValue.lastObject;
    }

    return map;
}

- (NSArray *)arrayForKey:(NSString *)key {
    NSString *value = [self objectForKey:key];
    return [value componentsSeparatedByString:@","];
}

- (NSURL *)URLForKey:(NSString *)key {
    NSString *value = [self objectForKey:key];
    return value ? [NSURL URLWithString:value] : nil;
}

+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }

    return numberFormatter;
}

- (NSNumber *)numberForKey:(NSString *)key {
    NSString *value = [self objectForKey:key];
    if (!value) {
        return nil;
    }
    return [MLCSettings.numberFormatter numberFromString:value] ?: [self boolNumberForKey:key];
}

- (NSInteger)integerForKey:(NSString *)key {
    return [self integerForKey:key defaultValue:0];
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
    NSNumber *number = [self numberForKey:key];
    return number ? number.integerValue : defaultValue;
}

- (double)doubleForKey:(NSString *)key {
    return [self doubleForKey:key defaultValue:0.0];
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    NSNumber *number = [self numberForKey:key];
    return number ? number.doubleValue : defaultValue;
}

- (BOOL)boolForKey:(NSString *)key {
    return [self boolForKey:key defaultValue:NO];
}

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    NSNumber *number = [self numberForKey:key];
    return number ? number.boolValue : defaultValue;
}

- (NSNumber *)boolNumberForKey:(NSString *)key {
    NSString *value = [[self objectForKey:key] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (value.length == 0) {
        return nil;
    }

    switch ([value characterAtIndex:0]) {
        case 't':
        case 'T':
        case 'y':
        case 'Y':
            return @YES;

        case 'f':
        case 'F':
        case 'n':
        case 'N':
            return @NO;

        default:
            return nil;
    }
}


@end
