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

#import "MLCUser.h"
#import "MLCEntity_Private.h"
#import "MLCValidation.h"

@interface MLCUser ()

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken;

@end

@implementation MLCUser

MLCUserSocial const MLCUserSocialFacebook = @"FACEBOOK";

MLCUserGender const MLCUserGenderUndeclared = @"UNDECLARED";
MLCUserGender const MLCUserGenderMale = @"MALE";
MLCUserGender const MLCUserGenderFemale = @"FEMALE";

MLCUserContactPreference const MLCUserContactPreferenceNone = @"NONE";
MLCUserContactPreference const MLCUserContactPreferenceSMS = @"SMS";
MLCUserContactPreference const MLCUserContactPreferenceEmail = @"EMAIL";
MLCUserContactPreference const MLCUserContactPreferenceBoth = @"BOTH";

@dynamic age;
@dynamic optinEmail;
@dynamic optinPhone;
@dynamic locationId;
@dynamic merchantId;

static NSArray<NSString *> *_requiredParameters = nil;

- (BOOL)isAnonymous {
    return [self.username hasPrefix:@"Anonymous."];
}

+ (NSArray<NSString *> *)requiredParameters {
    if (!_requiredParameters) {
        _requiredParameters = @[];
    }
    return [_requiredParameters copy];
}

+ (void)setRequiredParameters:(NSArray<NSString *> *)requiredParameters {
    if (requiredParameters != _requiredParameters) {
        _requiredParameters = [requiredParameters copy];
    }
}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[@"genderType", @"contactPreferenceType", @"socialType"];
}

+ (NSString *)uniqueIdentifierKey {
    return @"username";
}

+ (instancetype)userWithUsername:(NSString *)username {
    return [self userWithUsername:username password:nil social:nil socialToken:nil];
}

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password {
    return [self userWithUsername:username password:password social:nil socialToken:nil];
}

+ (instancetype)userWithSocial:(MLCUserSocial)social socialId:(NSString *)socialId socialUsername:(NSString *)socialUsername socialToken:(NSString *)socialToken {
    NSString *username = [NSString stringWithFormat:@"%@.%@.%@", social.uppercaseString, socialId, socialUsername];

    return [self userWithUsername:username password:nil social:social socialToken:socialToken];
}

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken {
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:4];

    if (username) properties[@"username"] = username;
    if (password) properties[@"password"] = password;
    if (social) properties[@"social"] = social;
    if (socialToken) properties[@"socialToken"] = socialToken;

    if (properties.count == 0) return nil;

    return [[MLCUser alloc] initWithJSONObject:properties];
}

+ (NSDateFormatter *)dateOfBirthDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"MM/dd/yyyy";
    });
    return dateFormatter;
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {

    self = [super initWithJSONObject:jsonObject];

    if (self) {
        NSMutableDictionary *attributes = [(jsonObject[@"attributes"] ?: @{}) mutableCopy];
        for (int i = 1; i <= 5; ++i) {
            NSString *attr = [NSString stringWithFormat:@"attr%@", @(i)];
            NSString *value = attributes[attr];
            if (value) {
                [self setSafeValue:value forKey:attr];
                attributes[attr] = nil;
            }
        }
        [self setSafeValue:attributes forKey:NSStringFromSelector(@selector(attributes))];

        NSString *dateOfBirth = jsonObject[@"dateOfBirth"];
        if ([dateOfBirth isKindOfClass:[NSString class]]) {
            NSDate *date = [[[self class] dateOfBirthDateFormatter] dateFromString:dateOfBirth];
            [self setSafeValue:date forKey:NSStringFromSelector(@selector(dateOfBirth))];
        }
    }

    return self;
}

+ (NSDictionary *)serialize:(MLCUser *)user {
    NSMutableDictionary *serializedObject = [[super serialize:user] mutableCopy];

    if ([user.gender isEqual:MLCUserGenderUndeclared]) {
        serializedObject[@"gender"] = nil;
    }

    if (user.social.length == 0) {
        serializedObject[@"social"] = nil;
        serializedObject[@"socialToken"] = nil;
    } else {
        serializedObject[@"password"] = nil;
    }

    id password = serializedObject[@"password"];
    if (password && (password == [NSNull null] || [@"" isEqualToString:password])) {
        [serializedObject removeObjectForKey:@"password"];
    }

    if (user.dateOfBirth) {
        serializedObject[@"dateOfBirth"] = [[self dateOfBirthDateFormatter] stringFromDate:user.dateOfBirth];
    }

    return serializedObject;
}

@end

@implementation MLCUser (Validation)


+ (void)addValidations:(MLCValidations *)validations key:(NSString *)key {
    [self addValidations:validations format:nil caseSensitive:NO key:key named:key];
}

+ (void)addValidations:(MLCValidations *)validations key:(NSString *)key named:(NSString *)named {
    [self addValidations:validations format:nil caseSensitive:NO key:key named:named];
}

+ (void)addValidations:(MLCValidations *)validations format:(NSString *)format key:(NSString *)key {
    [self addValidations:validations format:format caseSensitive:NO key:key named:key];
}

+ (void)addValidations:(MLCValidations *)validations format:(NSString *)format key:(NSString *)key named:(NSString *)keyName {
    [self addValidations:validations format:format caseSensitive:NO key:key named:keyName];
}

+ (void)addValidations:(MLCValidations *)validations format:(NSString *)format caseSensitive:(BOOL)caseSensitive key:(NSString *)key named:(NSString *)keyName {
    NSMutableArray *rules = [NSMutableArray array];
    MLCValidate *validPresence = [self validatePresenceOfRequiredKey:key withMessage:[NSString localizedStringWithFormat:NSLocalizedString(@"Your %@ is required.", @"Your {user field} is required."), keyName]];
    if (validPresence) {
        [rules addObject:validPresence];
    }
    if (format.length > 0) {
        NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"Please enter a valid %@.", @"Please enter a valid {user field}."), keyName];
        MLCValidate *validFormat = [MLCValidate validateFormat:format caseSensitive:caseSensitive message:message];
        if (validFormat) {
            [rules addObject:validFormat];
        }
    }

    [validations appendRules:rules forKey:key];
}

+ (MLCValidate *)validatePresenceOfRequiredKey:(NSString *)key withMessage:(NSString *)message {
    if (![self.requiredParameters containsObject:key]) return nil;
    return [MLCValidate validatePresenceWithMessage:message];
}

+ (MLCValidations *)validations {
    MLCValidations *validations = super.validations;
    if (validations.count) {
        return validations;
    }

    [self addValidations:validations format:@"^[A-Z0-9._%+-@ ]{3,200}$" key:@"username"];
    [self addValidations:validations format:@"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$" key:@"email" named:@"email address"];
    [self addValidations:validations format:@"^\\d{5}(?:[-\\s]\\d{4})?$" key:@"postalCode" named:@"zip code"];
    [self addValidations:validations format:@"^[A-Z -']{1,}$" key:@"firstName" named:@"first name"];
    [self addValidations:validations format:@"^[A-Z -']{1,}$" key:@"lastName" named:@"last name"];
    [self addValidations:validations format:@"^(?:\\+?1[-.?]?)?\\(?([0-9]{3})\\)?[-.?]?([0-9]{3})[-.?]?([0-9]{4})$" key:@"phone" named:@"phone number"];
    [self addValidations:validations format:@"^[A-Z]{2}$" caseSensitive:YES key:@"stateOrProvince" named:@"state"];

    [self addValidations:validations key:@"password"];
    [self addValidations:validations key:@"dateOfBirth" named:@"date of birth"];
    [self addValidations:validations key:@"nickName" named:@"nickname"];
    [self addValidations:validations key:@"companyName" named:@"company name"];
    [self addValidations:validations key:@"address1" named:@"address line 1"];
    [self addValidations:validations key:@"address2" named:@"address line 2"];
    [self addValidations:validations key:@"country"];
    [self addValidations:validations key:@"city"];
    [self addValidations:validations key:@"age"];
    [self addValidations:validations key:@"gender"];

    [validations appendRule:[[MLCValidate alloc] initWithMessage:@"A valid email address is required for Email Alerts."
                                                    validateTest:^BOOL(MLCUser *user, __unused NSString *key, NSString *value) {
                                                        BOOL selected = value.boolValue;
                                                        NSString *email = user.email;
                                                        BOOL valid = email.length && [user validateValue:&email forKey:NSStringFromSelector(@selector(email)) error:nil];
                                                        return !selected || valid;
                                                    }] forKey:@"optinEmail"];

    [validations appendRule:[[MLCValidate alloc] initWithMessage:@"A valid mobile phone number is required for Phone Alerts."
                                                    validateTest:^BOOL(MLCUser *user, __unused NSString *key, NSString *value) {
                                                        BOOL selected = value.boolValue;
                                                        NSString *phone = user.phone;
                                                        BOOL valid = phone.length && [user validateValue:&phone forKey:NSStringFromSelector(@selector(phone)) error:nil];
                                                        return !selected || valid;
                                                    }] forKey:@"optinPhone"];

    return validations;
}

@end
