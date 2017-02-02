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

#import <MoblicoSDK/MLCEntity.h>

/**
 The prefered method of contact for the user.
 */
typedef NS_OPTIONS(NSUInteger, MLCUserContactPreferenceType) {
    /// Specifies that the user does not wish to be contacted.
    MLCUserContactPreferenceTypeNone = 0,

    /// Specifies that the user wishes to be contacted by SMS (phone text message) only.
    MLCUserContactPreferenceTypeSMS = (1 << 0),

    /// Specifies that the user wishes to be contacted by email only.
    MLCUserContactPreferenceTypeEmail = (1 << 1),
    
    /// Specifies that the user wishes to be contacted by either SMS or email.
    MLCUserContactPreferenceTypeBoth = (MLCUserContactPreferenceTypeSMS |
                                        MLCUserContactPreferenceTypeEmail)
};

/**
 The gender for the user.
 */
typedef NS_ENUM(NSUInteger, MLCUserGenderType) {
    /// Specifies that the user does not provide gender information.
    MLCUserGenderTypeUndeclared,

    /// Specifies that the user is male.
    MLCUserGenderTypeMale,
    
    /// Specifies that the user is female.
    MLCUserGenderTypeFemale
};

/**
 The social media provider for the user.
 */
typedef NS_ENUM(NSUInteger, MLCUserSocialType) {
    /// No social media provider.
    MLCUserSocialTypeNone,
    
    /// Facebook.
    MLCUserSocialTypeFacebook
};

/**
 A MLCUser object encapsulates the data of a contact stored in the Moblico
 Admin Portal.
 */
@interface MLCUser : MLCEntity

/**
 The username for the user.
 */
@property (copy, nonatomic) NSString *username;

/**
 The password for the user.
 
 @since Available in MoblicoSDK 1.1 and later.
 */
@property (copy, nonatomic) NSString *password;

/**
 The social type for this user (Optional).
 */
@property (nonatomic) MLCUserSocialType socialType;

/**
 The social token for this user (Optional).
 */
@property (copy, nonatomic) NSString *socialToken;

/**
 Specifies whether the user has opted in to recieving emails.
 */
@property (nonatomic) BOOL optinEmail;

/**
 Specifies whether the user has opted in to recieving phone text messages.
 */
@property (nonatomic) BOOL optinPhone;

/**
 The date of birth of the user.
 */
@property (copy, nonatomic) NSDate *dateOfBirth;

/**
 The phone number for the user.
 */
@property (copy, nonatomic) NSString *phone;

/**
 The nick name of the user.
 */
@property (copy, nonatomic) NSString *nickName;

/**
 The locale for the user.
 */
@property (copy, nonatomic) NSString *locale;

/**
 The fist line of the address for the user.
 */
@property (copy, nonatomic) NSString *address1;

/**
 The second line of the address for the user.
 */
@property (copy, nonatomic) NSString *address2;

/**
 The last name of the user.
 */
@property (copy, nonatomic) NSString *lastName;

/**
 The first name of the user.
 */
@property (copy, nonatomic) NSString *firstName;

/**
 The country for the user.
 */
@property (copy, nonatomic) NSString *country;

/**
 The city for the user.
 */
@property (copy, nonatomic) NSString *city;

/**
 The contact preference type for the user.
 
 @see MLCUserContactPreferenceType
 */
@property (nonatomic) MLCUserContactPreferenceType contactPreferenceType;

/**
 The postal (zip) code for the user.
 */
@property (copy, nonatomic) NSString *postalCode;

/**
 The email address for the user.
 */
@property (copy, nonatomic) NSString *email;

/**
 The age of the user.
 */
@property (nonatomic) NSInteger age;

/**
 The gender of the user.
 
 @see MLCUserGenderType
 */
@property (nonatomic) MLCUserGenderType genderType;

/**
 The state or province for the user.
 */
@property (copy, nonatomic) NSString *stateOrProvince;

/**
 The date the user was created.
 */
@property (strong, nonatomic) NSDate *createDate;

/**
 The date the user was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

@property (strong, nonatomic) NSString *attr1;
@property (strong, nonatomic) NSString *attr2;
@property (strong, nonatomic) NSString *attr3;
@property (strong, nonatomic) NSString *attr4;
@property (strong, nonatomic) NSString *attr5;

@property (copy, nonatomic) NSString *externalId;
@property (nonatomic) NSUInteger locationId;
@property (nonatomic) NSUInteger merchantId;

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

 @param socialType     The social network being used.
 @param socialId       The unique identifier of the user on the social network.
 @param socialUsername The username of the user on the social network.
 @param socialToken    The access token provided by the social network after
 authentication.

 @return A MLCUser object.

 @since Available in MoblicoSDK 1.5 and later.
 */
+ (instancetype)userWithSocialType:(MLCUserSocialType)socialType socialId:(NSString *)socialId socialUsername:(NSString *)socialUsername socialToken:(NSString *)socialToken;

@end

@interface MLCUser (Deprecated)

/**
 The contactPreference property has been deprecated,
 and will be removed in the next major release.

 @deprecated Use 'contactPreferenceType' instead.

 @see contactPreferenceType
 */
@property (copy, nonatomic) NSString *contactPreference __attribute__((deprecated ("Use 'contactPreferenceType' instead.")));

/**
 The gender property has been deprecated,
 and will be removed in the next major release.

 @deprecated Use 'genderType' instead.

 @see genderType
 */
@property (copy, nonatomic) NSString *gender __attribute__((deprecated ("Use 'genderType' instead.")));

@end
