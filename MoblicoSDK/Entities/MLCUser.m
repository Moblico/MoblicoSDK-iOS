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

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password social:(NSString *)social;

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

- (void)setContactPreference:(NSString *)contactPreference {
    self.contactPreferenceType = [[self class] contactPreferenceTypeFromString:contactPreference];
}

- (NSString *)contactPreference {
    return [[self class] stringForContactPreferenceType:self.contactPreferenceType];
}

- (void)setGender:(NSString *)gender {
    self.genderType = [[self class] genderTypeFromString:gender];
}

- (NSString *)gender {
    return [[self class] stringForGenderType:self.genderType];
}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[@"genderType", @"contactPreferenceType", @"socialType"];
}

+ (NSString *)uniqueIdentifierKey {
    return @"username";
}

+ (instancetype)userWithUsername:(NSString *)username {
    return [self userWithUsername:username password:nil social:nil];
}

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password {
    return [self userWithUsername:username password:password social:nil];
}

+ (instancetype)userWithSocialType:(MLCUserSocialType)socialType socialId:(NSString *)socialId socialUsername:(NSString *)socialUsername socialToken:(NSString *)socialToken {
    NSString *social = [self stringForSocialType:socialType];
    NSString *username = [NSString stringWithFormat:@"%@.%@.%@", [social lowercaseString], socialId, socialUsername];

    return [self userWithUsername:username password:socialToken social:social];
}

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password social:(NSString *)social {
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:
                                       (username != nil) +
                                       (password != nil) +
                                       (social != nil)
                                       ];

	if (username) properties[@"username"] = username;
	if (password) properties[@"password"] = password;
	if (social) properties[@"social"] = social;

    if ([properties count] == 0) return nil;

//    NSLog(@"properties: %@", properties);
    return [MLCUser deserialize:properties];
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

    NSString *uppercaseString = [string uppercaseString];
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

    NSString *uppercaseString = [string uppercaseString];
    if ([uppercaseString isEqualToString:MLCUserContactPreferenceTypeNoneString]) return MLCUserContactPreferenceTypeNone;
    if ([uppercaseString isEqualToString:MLCUserContactPreferenceTypeSMSString]) return MLCUserContactPreferenceTypeSMS;
    if ([uppercaseString isEqualToString:MLCUserContactPreferenceTypeEmailString]) return MLCUserContactPreferenceTypeEmail;
    if ([uppercaseString isEqualToString:MLCUserContactPreferenceTypeBothString]) return MLCUserContactPreferenceTypeBoth;


    return MLCUserContactPreferenceTypeNone;
}

+ (NSString *)stringForContactPreferenceType:(MLCUserContactPreferenceType)type {
    if (type == MLCUserContactPreferenceTypeBoth) return MLCUserContactPreferenceTypeBothString;
    if (type == MLCUserContactPreferenceTypeEmail) return MLCUserContactPreferenceTypeEmailString;
    if (type == MLCUserContactPreferenceTypeNone) return MLCUserContactPreferenceTypeNoneString;
    if (type == MLCUserContactPreferenceTypeSMS) return MLCUserContactPreferenceTypeSMSString;

    return nil;
}

+ (instancetype)deserialize:(NSDictionary *)jsonObject {
    MLCUser *user = [super deserialize:jsonObject];

    NSDictionary *attributes = jsonObject[@"attributes"];
    if (attributes) {
        user.attr1 = attributes[@"attr1"];
        user.attr2 = attributes[@"attr2"];
        user.attr3 = attributes[@"attr3"];
        user.attr4 = attributes[@"attr4"];
        user.attr5 = attributes[@"attr5"];
    }
    user.socialType = [MLCUser socialTypeFromString:jsonObject[@"social"]];
    user.genderType = [MLCUser genderTypeFromString:jsonObject[@"gender"]];
    user.contactPreferenceType = [MLCUser contactPreferenceTypeFromString:jsonObject[@"contactPreference"]];

    return user;
}

- (NSDictionary *)serialize {
    NSMutableDictionary *serializedObject = [[super serialize] mutableCopy];

    NSString *social = [[self class] stringForSocialType:self.socialType];

    if (social) {
        serializedObject[@"social"] = social;
    }

    NSString *type = [[self class] stringForGenderType:self.genderType];

    if (self.genderType != MLCUserGenderTypeUndeclared) {
        serializedObject[@"gender"] = type;
    }

    NSString *contactPrefernce = [[self class] stringForContactPreferenceType:self.contactPreferenceType];
    serializedObject[@"contactPreference"] = contactPrefernce;

    if (self.socialType == MLCUserSocialTypeNone) {
        [serializedObject removeObjectForKey:@"social"];
    } else {
        [serializedObject removeObjectForKey:@"password"];
    }

    return serializedObject;
}

@end
