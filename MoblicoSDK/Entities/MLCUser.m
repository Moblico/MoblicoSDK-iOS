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

@interface MLCUser ()

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken;

@end

@implementation MLCUser

static NSString *const MLCUserSocialTypeNoneString = @"NONE";
static NSString *const MLCUserSocialTypeFacebookString = @"FACEBOOK";

static NSString *const MLCUserGenderTypeUndeclaredString = @"UNDECLARED";
static NSString *const MLCUserGenderTypeMaleString = @"MALE";
static NSString *const MLCUserGenderTypeFemaleString = @"FEMALE";

static NSString *const MLCUserContactPreferenceTypeNoneString = @"NONE";
static NSString *const MLCUserContactPreferenceTypeSMSString = @"SMS";
static NSString *const MLCUserContactPreferenceTypeEmailString = @"EMAIL";
static NSString *const MLCUserContactPreferenceTypeBothString = @"BOTH";

@dynamic age;
@dynamic optinEmail;
@dynamic optinPhone;
@dynamic socialType;
@dynamic contactPreferenceType;
@dynamic genderType;
@dynamic locationId;
@dynamic merchantId;

- (void)setContactPreference:(NSString *)contactPreference {
    if (contactPreference.length) {
        [self setSafeValue:@([[self class] contactPreferenceTypeFromString:contactPreference]) forKey:@"contactPreferenceType"];
    }
    else {
        [self setSafeValue:nil forKey:@"contactPreferenceType"];
    }
}

- (NSString *)contactPreference {
    id value = [self valueForKey:@"contactPreferenceType"];
    if (value && value != [NSNull null]) {
        return [[self class] stringForContactPreferenceType:[value unsignedIntegerValue]];
    }
    return nil;
}

- (void)setGender:(NSString *)gender {
    if (gender.length) {
        [self setSafeValue:@([[self class] genderTypeFromString:gender]) forKey:@"genderType"];
    }
    else {
        [self setSafeValue:nil forKey:@"genderType"];
    }
}

- (NSString *)gender {
    id value = [self valueForKey:@"genderType"];
    if (value && value != [NSNull null]) {
        return [[self class] stringForGenderType:[value unsignedIntegerValue]];
    }
    return nil;
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

+ (instancetype)userWithSocialType:(MLCUserSocialType)socialType socialId:(NSString *)socialId socialUsername:(NSString *)socialUsername socialToken:(NSString *)socialToken {
    NSString *social = [self stringForSocialType:socialType];
    NSString *username = [NSString stringWithFormat:@"%@.%@.%@", social.uppercaseString, socialId, socialUsername];

    return [self userWithUsername:username password:nil social:social socialToken:socialToken];
}

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken {
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:
                                       (username != nil) +
                                       (password != nil) +
                                       (social != nil) +
                                       (socialToken != nil)
                                       ];

	if (username) properties[@"username"] = username;
    if (password) properties[@"password"] = password;
    if (social) properties[@"social"] = social;
    if (socialToken) properties[@"socialToken"] = socialToken;

    if (properties.count == 0) return nil;

//    NSLog(@"properties: %@", properties);
    return [[[self class] alloc] initWithJSONObject:properties];
}

+ (MLCUserSocialType)socialTypeFromString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) return MLCUserSocialTypeNone;

    if ([string isEqualToString:MLCUserSocialTypeNoneString]) return MLCUserSocialTypeNone;
    if ([string isEqualToString:MLCUserSocialTypeFacebookString]) return MLCUserSocialTypeFacebook;

    return MLCUserSocialTypeNone;
}

+ (NSString *)stringForSocialType:(MLCUserSocialType)socialType {
    if (socialType == MLCUserSocialTypeNone) return MLCUserSocialTypeNoneString;
    if (socialType == MLCUserSocialTypeFacebook) return MLCUserSocialTypeFacebookString;

    return nil;
}

+ (MLCUserGenderType)genderTypeFromString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) return MLCUserGenderTypeUndeclared;

    NSString *uppercaseString = string.uppercaseString;
    if ([uppercaseString isEqualToString:MLCUserGenderTypeUndeclaredString]) return MLCUserGenderTypeUndeclared;
    if ([uppercaseString isEqualToString:MLCUserGenderTypeMaleString]) return MLCUserGenderTypeMale;
    if ([uppercaseString isEqualToString:MLCUserGenderTypeFemaleString]) return MLCUserGenderTypeFemale;

    return MLCUserGenderTypeUndeclared;
}

+ (NSString *)stringForGenderType:(MLCUserGenderType)type {

    if (type == MLCUserGenderTypeUndeclared) return MLCUserGenderTypeUndeclaredString;
    if (type == MLCUserGenderTypeMale) return MLCUserGenderTypeMaleString;
    if (type == MLCUserGenderTypeFemale) return MLCUserGenderTypeFemaleString;


    return nil;
}

+ (MLCUserContactPreferenceType)contactPreferenceTypeFromString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) return MLCUserContactPreferenceTypeNone;

    NSString *contactPreference = string.uppercaseString;
    if ([contactPreference isEqualToString:MLCUserContactPreferenceTypeNoneString]) return MLCUserContactPreferenceTypeNone;
    if ([contactPreference isEqualToString:MLCUserContactPreferenceTypeSMSString]) return MLCUserContactPreferenceTypeSMS;
    if ([contactPreference isEqualToString:MLCUserContactPreferenceTypeEmailString]) return MLCUserContactPreferenceTypeEmail;
    if ([contactPreference isEqualToString:MLCUserContactPreferenceTypeBothString]) return MLCUserContactPreferenceTypeBoth;


    return MLCUserContactPreferenceTypeNone;
}

+ (NSString *)stringForContactPreferenceType:(MLCUserContactPreferenceType)type {
    if (type == MLCUserContactPreferenceTypeBoth) return MLCUserContactPreferenceTypeBothString;
    if (type == MLCUserContactPreferenceTypeEmail) return MLCUserContactPreferenceTypeEmailString;
    if (type == MLCUserContactPreferenceTypeNone) return MLCUserContactPreferenceTypeNoneString;
    if (type == MLCUserContactPreferenceTypeSMS) return MLCUserContactPreferenceTypeSMSString;

    return nil;
}

+ (NSDateFormatter *)dateOfBirthDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy";
    });
    return dateFormatter;
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
//    if (jsonObject) {
//        <#statements#>
//    }
    self = [super initWithJSONObject:jsonObject];

    if (self) {
        NSDictionary *attributes = jsonObject[@"attributes"];
        if (attributes) {
            [self setSafeValue:attributes[@"attr1"] forKey:@"attr1"];
            [self setSafeValue:attributes[@"attr2"] forKey:@"attr2"];
            [self setSafeValue:attributes[@"attr3"] forKey:@"attr3"];
            [self setSafeValue:attributes[@"attr4"] forKey:@"attr4"];
            [self setSafeValue:attributes[@"attr5"] forKey:@"attr5"];
        }

        NSString *dateOfBirth = jsonObject[@"dateOfBirth"];
        if ([dateOfBirth isKindOfClass:[NSString class]]) {
            NSDate *date = [[MLCUser dateOfBirthDateFormatter] dateFromString:dateOfBirth];
            [self setSafeValue:date forKey:@"dateOfBirth"];
        }

        if (jsonObject[@"social"] != [NSNull null] && [jsonObject[@"social"] length]) {
            [self setSafeValue:@([MLCUser socialTypeFromString:jsonObject[@"social"]]) forKey:@"socialType"];
        }
        if (jsonObject[@"gender"] != [NSNull null] && [jsonObject[@"gender"] length]) {
            [self setSafeValue:@([MLCUser genderTypeFromString:jsonObject[@"gender"]]) forKey:@"genderType"];
        }
        if (jsonObject[@"contactPreference"] != [NSNull null] && [jsonObject[@"contactPreference"] length]) {
            [self setSafeValue:@([MLCUser contactPreferenceTypeFromString:jsonObject[@"contactPreference"]]) forKey:@"contactPreferenceType"];
        }

//        self.socialType = [MLCUser socialTypeFromString:jsonObject[@"social"]];
//        self.genderType = [MLCUser genderTypeFromString:jsonObject[@"gender"]];
//        self.contactPreferenceType = [MLCUser contactPreferenceTypeFromString:jsonObject[@"contactPreference"]];

    }

    return self;
}

+ (NSDictionary *)serialize:(MLCUser *)user {
    NSMutableDictionary *serializedObject = [[super serialize:user] mutableCopy];



    NSString *social = [self stringForSocialType:user.socialType];


    if (social) {
        serializedObject[@"social"] = social;
    }

    if (user.genderType != MLCUserGenderTypeUndeclared) {

        serializedObject[@"gender"] = [self stringForGenderType:user.genderType];
    }



    id value = [user valueForKey:@"contactPreferenceType"];
    
    if (value && value != [NSNull null]) {
        NSString *contactPrefernce = [self stringForContactPreferenceType:user.contactPreferenceType];
        serializedObject[@"contactPreference"] = contactPrefernce;
    }
    else {
        [serializedObject removeObjectForKey:@"contactPreference"];
    }

    if (user.socialType == MLCUserSocialTypeNone) {
        [serializedObject removeObjectForKey:@"social"];
        [serializedObject removeObjectForKey:@"socialToken"];
    } else {
        [serializedObject removeObjectForKey:@"password"];
    }

    id password = serializedObject[@"password"];
    if (password && (password == [NSNull null] || [@"" isEqualToString:password])) {
//        NSLog(@"Password is empty!");
        [serializedObject removeObjectForKey:@"password"];
    }
    
    if (user.dateOfBirth) {
        serializedObject[@"dateOfBirth"] = [[self dateOfBirthDateFormatter] stringFromDate:user.dateOfBirth];
    }
    
    return serializedObject;
}

@end
