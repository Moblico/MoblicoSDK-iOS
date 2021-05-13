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

#import "MLCEntity.h"

NS_ASSUME_NONNULL_BEGIN

/// The preferred method of contact for the user.
typedef NSString *MLCUserContactPreference NS_TYPED_ENUM NS_SWIFT_NAME(MLCUser.ContactPreference);

/// Specifies that the user does not wish to be contacted.
FOUNDATION_EXPORT MLCUserContactPreference const MLCUserContactPreferenceNone;
/// Specifies that the user wishes to be contacted by SMS (phone text message) only.
FOUNDATION_EXPORT MLCUserContactPreference const MLCUserContactPreferenceSMS NS_SWIFT_NAME(sms);
/// Specifies that the user wishes to be contacted by email only.
FOUNDATION_EXPORT MLCUserContactPreference const MLCUserContactPreferenceEmail;
/// Specifies that the user wishes to be contacted by either SMS or email.
FOUNDATION_EXPORT MLCUserContactPreference const MLCUserContactPreferenceBoth;

/// The gender for the user.
typedef NSString *MLCUserGender NS_TYPED_ENUM NS_SWIFT_NAME(MLCUser.Gender);
/// Specifies that the user does not provide gender information.
FOUNDATION_EXPORT MLCUserGender const MLCUserGenderUndeclared;
/// Specifies that the user is male.
FOUNDATION_EXPORT MLCUserGender const MLCUserGenderMale;
/// Specifies that the user is female.
FOUNDATION_EXPORT MLCUserGender const MLCUserGenderFemale;

/// The social media provider for the user.
typedef NSString *MLCUserSocial NS_TYPED_ENUM NS_SWIFT_NAME(MLCUser.Social);
/// Facebook.
FOUNDATION_EXPORT MLCUserSocial const MLCUserSocialFacebook;

/**
 A MLCUser object encapsulates the data of a contact stored in the Moblico
 Admin Portal.
 */
NS_SWIFT_NAME(User)
@interface MLCUser : MLCEntity

/**
 The username for the user.
 */
@property (copy, nonatomic, nullable) NSString *username;

/**
 The password for the user.
 */
@property (copy, nonatomic, nullable) NSString *password;

/**
 The social type for this user (Optional).
 */
@property (copy, nonatomic, nullable) MLCUserSocial social;

/**
 The social token for this user (Optional).
 */
@property (copy, nonatomic, nullable) NSString *socialToken;

/**
 Specifies whether the user has opted in to receiving emails.
 */
@property (nonatomic) BOOL optinEmail;

/**
 Specifies whether the user has opted in to receiving phone text messages.
 */
@property (nonatomic) BOOL optinPhone;

/**
 The date of birth of the user.
 */
@property (copy, nonatomic, nullable) NSDate *dateOfBirth;

/**
 The phone number for the user.
 */
@property (copy, nonatomic, nullable) NSString *phone;

/**
 The nick name of the user.
 */
@property (copy, nonatomic, nullable) NSString *nickName;

/**
 The locale for the user.
 */
@property (copy, nonatomic, nullable) NSString *locale;

/**
 The name of the company for the user.
 */
@property (copy, nonatomic, nullable) NSString *companyName;

/**
 The fist line of the address for the user.
 */
@property (copy, nonatomic, nullable) NSString *address1;

/**
 The second line of the address for the user.
 */
@property (copy, nonatomic, nullable) NSString *address2;

/**
 The last name of the user.
 */
@property (copy, nonatomic, nullable) NSString *lastName;

/**
 The first name of the user.
 */
@property (copy, nonatomic, nullable) NSString *firstName;

/**
 The country for the user.
 */
@property (copy, nonatomic, nullable) NSString *country;

/**
 The city for the user.
 */
@property (copy, nonatomic, nullable) NSString *city;

/**
 The contact preference type for the user.
 
 @see MLCUserContactPreferenceType
 */
@property (copy, nonatomic, nullable) MLCUserContactPreference contactPreference;

/**
 The postal (zip) code for the user.
 */
@property (copy, nonatomic, nullable) NSString *postalCode;

/**
 The email address for the user.
 */
@property (copy, nonatomic, nullable) NSString *email;

/**
 The age of the user.
 */
@property (nonatomic) NSInteger age;

/**
 The gender of the user.
 
 @see MLCUserGenderType
 */
@property (copy, nonatomic, nullable) MLCUserGender gender;

/**
 The state or province for the user.
 */
@property (copy, nonatomic, nullable) NSString *stateOrProvince;

/**
 The date the user was created.
 */
@property (strong, nonatomic) NSDate *createDate;

/**
 The date the user was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

@property (copy, nonatomic, nullable) NSString *attr1;
@property (copy, nonatomic, nullable) NSString *attr2;
@property (copy, nonatomic, nullable) NSString *attr3;
@property (copy, nonatomic, nullable) NSString *attr4;
@property (copy, nonatomic, nullable) NSString *attr5;
@property (copy, nonatomic) NSDictionary<NSString *, NSString *> *attributes;

@property (copy, nonatomic, nullable) NSString *externalId;
@property (nonatomic) NSUInteger locationId;
@property (nonatomic) NSUInteger merchantId;

@property (nonatomic, readonly, getter=isAnonymous) BOOL anonymous;

@property (nonatomic, copy, class) NSArray<NSString *> *requiredParameters;

/**
 Convenience class method to create a MLCUser object with the provided
 username.

 @param username The username for the user
 @return A MLCUser object.
 */
+ (instancetype)userWithUsername:(NSString *)username;

/**
 Convenience class method to create a MLCUser object with the provided
 username and password.

 @param username The username for the user
 @param password The password for the user
 
 @return A MLCUser object.
 */
+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password;

/**
 Convenience class method to create a MLCUser object from a social network.

 @param social     The social network being used.
 @param socialId       The unique identifier of the user on the social network.
 @param socialUsername The username of the user on the social network.
 @param socialToken    The access token provided by the social network after
 authentication.

 @return A MLCUser object.
 */
+ (instancetype)userWithSocial:(MLCUserSocial)social socialId:(NSString *)socialId socialUsername:(NSString *)socialUsername socialToken:(NSString *)socialToken;

@end

NS_ASSUME_NONNULL_END
