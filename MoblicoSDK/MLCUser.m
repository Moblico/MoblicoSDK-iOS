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

    return [[[self class] alloc] initWithJSONObject:properties];
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
        NSDictionary *attributes = jsonObject[@"attributes"];
        if (attributes) {
            [self setSafeValue:attributes[@"attr1"] forKey:NSStringFromSelector(@selector(attr1))];
            [self setSafeValue:attributes[@"attr2"] forKey:NSStringFromSelector(@selector(attr2))];
            [self setSafeValue:attributes[@"attr3"] forKey:NSStringFromSelector(@selector(attr3))];
            [self setSafeValue:attributes[@"attr4"] forKey:NSStringFromSelector(@selector(attr4))];
            [self setSafeValue:attributes[@"attr5"] forKey:NSStringFromSelector(@selector(attr5))];
        }

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

+ (MLCValidate *)validatePresenceOfRequiredKey:(NSString *)key withMessage:(NSString *)message {
    if (![self.requiredParameters containsObject:key]) return nil;
    return [MLCValidate validatePresenceWithMessage:message];
}

+ (MLCValidations *)validations {
    MLCValidations *validations = super.validations;
    if (validations.count) {
        return validations;
    }
    [validations appendRules:@[[self validatePresenceOfRequiredKey:@"username" withMessage:@"Your username is required."],
                               [MLCValidate validateFormat:@"^[A-Z0-9._%+-@ ]{3,200}$" message:@"Please enter a valid username."]] forKey:@"username"];
    
    [validations appendRules:@[[self validatePresenceOfRequiredKey:@"email" withMessage:@"Your email address is required."],
                               [MLCValidate validateFormat:@"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$" message:@"Please enter a valid email address."]] forKey:@"email"];
    
    [validations appendRules:@[[self validatePresenceOfRequiredKey:@"postalCode" withMessage:@"Your zip code is required."],
                               [MLCValidate validateFormat:@"^\\d{5}(?:[-\\s]\\d{4})?$" message:@"Please enter a valid zip code."]] forKey:@"postalCode"];
    
    [validations appendRules:@[[self validatePresenceOfRequiredKey:@"firstName" withMessage:@"Your first name is required."],
                               [MLCValidate validateFormat:@"^[A-Z -']{1,}$" message:@"Please enter a valid first name."]] forKey:@"firstName"];
    
    [validations appendRules:@[[self validatePresenceOfRequiredKey:@"lastName" withMessage:@"Your last name is required."],
                               [MLCValidate validateFormat:@"^[A-Z -']{1,}$" message:@"Please enter a valid last name."]] forKey:@"lastName"];
    
    [validations appendRules:@[[self validatePresenceOfRequiredKey:@"phone" withMessage:@"Your phone number is required."],
                               [MLCValidate validateFormat:@"^(?:\\+?1[-.?]?)?\\(?([0-9]{3})\\)?[-.?]?([0-9]{3})[-.?]?([0-9]{4})$" message:@"Please enter a valid phone number."]] forKey:@"phone"];
    
    [validations appendRules:@[[self validatePresenceOfRequiredKey:@"stateOrProvince" withMessage:@"Your state is required."],
                               [MLCValidate validateCaseSensitiveFormat:@"^[A-Z]{2}$" message:@"Please enter a valid state."]] forKey:@"stateOrProvince"];
    
    [validations appendRule:[self validatePresenceOfRequiredKey:@"gender" withMessage:@"Your gender is required."] forKey:@"gender"];
    
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
