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

@implementation MLCUser (Validation)

- (BOOL)validateUsername:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"username"]) {
        [validation validateShouldExist:YES errorMessage:@"Your username is required."];
    }
    [validation validateCaseInsensitiveFormat:@"^[A-Z0-9._%+-@ ]{5,200}$"
                                 errorMessage:@"Please enter a valid username."];

    return [validation isValid:outError];
}

//- (BOOL)validatePassword:(id *)ioValue error:(NSError **)outError {
//	MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
//	[validation validateShouldExist:[self.class.requiredParameters containsObject:@"password"]
//                       errorMessage:@"Your password is required."];
//
//	return [validation isValid:outError];
//}

- (BOOL)validateEmail:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"email"]) {
        [validation validateShouldExist:YES errorMessage:@"Your email address is required."];
    }
    [validation validateCaseInsensitiveFormat:@"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$"
                                 errorMessage:@"Please enter a valid email address."];

    return [validation isValid:outError];
}


- (BOOL)validatePostalCode:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"postalCode"]) {
        [validation validateShouldExist:YES errorMessage:@"Your zip code is required."];
    }
    [validation validateFormat:@"^\\d{5}(?:[-\\s]\\d{4})?$"
                  errorMessage:@"Please enter a valid zip code."];

    return [validation isValid:outError];
}

- (BOOL)validateFirstName:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"firstName"]) {
        [validation validateShouldExist:YES errorMessage:@"Your first name is required."];
    }
    [validation validateCaseInsensitiveFormat:@"^[A-Z -']{1,}$"
                                 errorMessage:@"Please enter a valid first name."];

    return [validation isValid:outError];
}

- (BOOL)validateLastName:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"lastName"]) {
        [validation validateShouldExist:YES errorMessage:@"Your last name is required."];
    }
    [validation validateCaseInsensitiveFormat:@"^[A-Z -']{1,}$"
                                 errorMessage:@"Please enter a valid last name."];

    return [validation isValid:outError];
}

- (BOOL)validatePhone:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"phone"]) {
        [validation validateShouldExist:YES errorMessage:@"Your phone number is required."];
    }
    [validation validateFormat:@"^(?:\\+?1[-.?]?)?\\(?([0-9]{3})\\)?[-.?]?([0-9]{3})[-.?]?([0-9]{4})$"
                  errorMessage:@"Please enter a valid phone number."];

    return [validation isValid:outError];
}

- (BOOL)validateStateOrProvince:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"stateOrProvince"]) {
        [validation validateShouldExist:YES errorMessage:@"Your state is required."];
    }
    [validation validateFormat:@"^[A-Z]{2}$" errorMessage:@"Please enter a valid state."];

    return [validation isValid:outError];
}

- (BOOL)validateGender:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    if ([self.class.requiredParameters containsObject:@"gender"]) {
        [validation validateShouldExist:YES errorMessage:@"Your gender is required."];
    }
    return [validation isValid:outError];
}

- (BOOL)validateOptinEmail:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    [validation validateTest:^BOOL(id value) {
        BOOL selected = [value boolValue];
        NSString *email = self.email;
        BOOL valid = self.email.length && [self validateEmail:&email error:nil];
        if (selected && !valid) {
            return NO;
        }
        return YES;
    } errorMessage:@"A valid email address is required for Email Alerts."];

    return [validation isValid:outError];
}

- (BOOL)validateOptinPhone:(id *)ioValue error:(NSError **)outError {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];
    [validation validateTest:^BOOL(id value) {
        BOOL selected = [value boolValue];
        NSString *phone = self.phone;
        BOOL valid = self.phone.length && [self validatePhone:&phone error:nil];
        if (selected && !valid) {
            return NO;
        }
        return YES;
    } errorMessage:@"A valid mobile phone number is required for Phone Alerts."];

    return [validation isValid:outError];
}
/*
 - (BOOL)validateDateOfBirth:(id *)ioValue error:(NSError **)outError {
	NSDate * value = *ioValue;
 if (value == nil) {
 // If not required return YES;
 return YES;
 NSString * errorStr = NSLocalizedString(@"No Birthdate Error String", @"Your birthdate is required.");
 NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
 if (outError) *outError = [[[NSError alloc] initWithDomain:@"ValidationError" code:-1 userInfo:userInfoDict] autorelease];
 return NO;
	}

	//	NSCalendar* calendar = [NSCalendar currentCalendar];
	//	NSDate * now = [NSDate date];
	//	unsigned dateComponentFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
	//	NSDateComponents * dateComponents = [calendar components:dateComponentFlags fromDate:now];
	//
	//	[dateComponents setYear:([dateComponents year] - 13)];
	//	NSDate * limit = [calendar dateFromComponents:dateComponents];

	NSDate * limit = [NSDate date];

	if ([value compare:limit] == NSOrderedDescending) {
 NSString * errorStr = NSLocalizedString(@"Underage Birthdate Error String", @"Invalid birthdate.");
 NSDictionary *userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"userIsUnderage",  errorStr, NSLocalizedDescriptionKey, nil];
 if (outError) *outError = [[[NSError alloc] initWithDomain:@"ValidationError" code:-2 userInfo:userInfoDict] autorelease];
 return NO;
	}

 return YES;
 }

 - (BOOL)validateAge:(id *)ioValue error:(NSError **)outError {
	double value = [MLCEntity doubleFromValue:*ioValue];
 if (value <= 0.0) {
 // If not required return YES;
 return YES;
 NSString * errorStr = NSLocalizedString(@"No Age Error String", @"Your age is required.");
 NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
 if (outError) *outError = [[[NSError alloc] initWithDomain:@"ValidationError" code:-1 userInfo:userInfoDict] autorelease];
 return NO;
	}

	if (value < 12 || value > 120) {
 NSString * errorStr = NSLocalizedString(@"Invalid Age Error String", @"Invalid age.");
 NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
 if (outError) *outError = [[[NSError alloc] initWithDomain:@"ValidationError" code:-2 userInfo:userInfoDict] autorelease];
 return NO;
	}

 return YES;
 }

 - (BOOL)validateGender:(id *)ioValue error:(NSError **)outError {
	NSString * value = [MLCEntity stringFromValue:*ioValue];
 if (value.length == 0) {
 // If not required return YES;
 return YES;
 NSString * errorStr = NSLocalizedString(@"No Gender Error String", @"Your gender is required.");
 NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
 if (outError) *outError = [[[NSError alloc] initWithDomain:@"ValidationError" code:-1 userInfo:userInfoDict] autorelease];
 return NO;
	}

 return YES;
 }


 - (BOOL)validateMessagePermission:(id *)ioValue error:(NSError **)outError {
	if (![MLCEntity boolFromValue:*ioValue] || self.phone.length) return YES;

	NSString * errorStr = NSLocalizedString(@"Message Permission Validation Error String", @"A valid mobile phone number is required for Text Alerts.");
	NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
	if (outError) *outError = [[[NSError alloc] initWithDomain:@"ValidationError" code:-1 userInfo:userInfoDict] autorelease];
	return NO;
 }

 - (BOOL)validateEmailPermission:(id *)ioValue error:(NSError **)outError {
	if (![MLCEntity boolFromValue:*ioValue] || self.email.length) return YES;

	NSString * errorStr = NSLocalizedString(@"Email Permission Validation Error String", @"A valid email address is required for Email Alerts.");
	NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
	if (outError) *outError = [[[NSError alloc] initWithDomain:@"ValidationError" code:-1 userInfo:userInfoDict] autorelease];
	return NO;
 }
 */
@end
