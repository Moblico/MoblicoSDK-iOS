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

@interface MLCSettings ()
@property (nonatomic, copy) NSDictionary *dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, class, copy, readonly) NSNumberFormatter *numberFormatter;
@end

@implementation MLCSettingsService

+ (Class<MLCEntityProtocol>)classForResource {
    return Nil;
}

+ (instancetype)readSettings:(MLCSettingsServiceCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:@"settings"
                       parameters:nil
                          handler:^(MLCService *service, id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              MLCSettings *settings = nil;
                              if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
                                  [[NSUserDefaults standardUserDefaults] setObject:jsonObject forKey:@"MLCSettings"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  settings = [self settings];
                              }
                              handler(settings, error, response);
                              service.dispatchGroup = nil;
                          }];
}

+ (MLCSettings *)settings {
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"MLCSettings"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:settings];
    NSDictionary *override = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"MLCSettingsOverride"];
    if (override.count > 0) {
        [dictionary addEntriesFromDictionary:override];
    }
    return [[MLCSettings alloc] initWithDictionary:dictionary];
}

+ (void)overrideSettings:(NSDictionary *)override {
    [[NSUserDefaults standardUserDefaults] setObject:override forKey:@"MLCSettingsOverride"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation MLCSettings

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
    }
    return self;
}

- (nullable NSString *)objectForKey:(NSString *)key {
    return self.dictionary[key];
}

- (nullable NSString *)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}


- (nullable NSDictionary *)dictionaryForKey:(NSString *)key {
    NSString *value = self.dictionary[key];
    if (value == nil) {
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

- (nullable NSArray *)arrayForKey:(NSString *)key {
    NSString *value = self.dictionary[key];
    return [value componentsSeparatedByString:@","];
}

- (nullable NSURL *)URLForKey:(NSString *)key {
    NSString *url = self.dictionary[key];
    return url.length > 0 ? [NSURL URLWithString:url] : nil;
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

- (NSInteger)integerForKey:(NSString *)key {
    return [self integerForKey:key defaultValue:0];
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
    NSNumber *number = [MLCSettings.numberFormatter numberFromString:self.dictionary[key]];
    return number ? number.integerValue : defaultValue;
}

- (double)doubleForKey:(NSString *)key {
    return [self doubleForKey:key defaultValue:0.0];
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    NSNumber *number = [MLCSettings.numberFormatter numberFromString:self.dictionary[key]];
    return number ? number.doubleValue : defaultValue;
}

- (BOOL)boolForKey:(NSString *)key {
    return [self boolForKey:key defaultValue:NO];
}

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    NSString *value = self.dictionary[key];
    value = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (!value || value.length == 0) {
        return defaultValue;
    }

    unichar c = [value characterAtIndex:0];
    switch (c) {
        case 't':
        case 'T':
        case 'y':
        case 'Y':
            return YES;

        case 'f':
        case 'F':
        case 'n':
        case 'N':
            return NO;
        default:
            ;
    }

    NSNumber *number = [MLCSettings.numberFormatter numberFromString:value];
    return number ? number.boolValue : defaultValue;
}

@end
