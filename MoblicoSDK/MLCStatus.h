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

FOUNDATION_EXPORT NSString *const MLCStatusErrorDomain;

/**
 The type for the status.
 */
typedef NS_ENUM(NSInteger, MLCStatusType) {
    /// Status type was not returned from service.
    MLCStatusTypeMissing = -1,

    /// Success.
    MLCStatusTypeSuccess = 0,

    /// Invalid error type.
    MLCStatusTypeInvalidErrorType = 1,

    /// Unknown error.
    MLCStatusTypeUnknownError = 2,

    /// Internal status code.
    MLCStatusTypeInternal3 = 3,

    /// Invalid app token.
    MLCStatusTypeInvalidAppToken = 4,

    /// Invalid postal (zip) code.
    MLCStatusTypeInvalidPostalCode = 5,

    /// Invalid latitude.
    MLCStatusTypeInvalidLatitude = 6,

    /// Invalid longitude.
    MLCStatusTypeInvalidLongitude = 7,

    /// Empty first name.
    MLCStatusTypeEmptyFirstName = 8,

    /// Empty last name.
    MLCStatusTypeEmptyLastName = 9,

    /// Invalid email address.
    MLCStatusTypeInvalidEmail = 10,

    /// User already exists.
    MLCStatusTypeUserAlreadyExists = 11,

    /// Invalid username.
    MLCStatusTypeInvalidUsername = 12,

    /// Invalid password.
    MLCStatusTypeInvalidPassword = 13,

    /// Invalid store id.
    MLCStatusTypeInvalidStoreId = 14,

    /// No geo match.
    MLCStatusTypeNoGeoMatch = 15,

    /// Internal status code.
    MLCStatusTypeInternal16 = 16,

    /// Invalid security token.
    MLCStatusTypeInvalidSecurityToken = 17,

    /// No application settings found.
    MLCStatusTypeNoApplicationSettingsFound = 18,

    /// No ads found.
    MLCStatusTypeNoAdsFound = 19,

    /// No deals found.
    MLCStatusTypeNoDealsFound = 20,

    /// Invalid deal id.
    MLCStatusTypeInvalidDealId = 21,

    /// Deal already redeemed.
    MLCStatusTypeDealAlreadyRedeemed = 22,

    /// Internal status code.
    MLCStatusTypeInternal23 = 23,

    /// Internal status code.
    MLCStatusTypeInternal24 = 24,

    /// Internal status code.
    MLCStatusTypeInternal25 = 25,

    /// Internal status code.
    MLCStatusTypeInternal26 = 26,

    /// Invalid user.
    MLCStatusTypeInvalidUser = 27,

    /// Password mismatch.
    MLCStatusTypePasswordMismatch = 28,

    /// No deal image found.
    MLCStatusTypeNoDealImageFound = 29,

    /// Internal status code.
    MLCStatusTypeInternal30 = 30,

    /// Internal status code.
    MLCStatusTypeInternal31 = 31,

    /// Internal status code.
    MLCStatusTypeInternal32 = 32,

    /// Internal status code.
    MLCStatusTypeInternal33 = 33,

    /// Internal status code.
    MLCStatusTypeInternal34 = 34,

    /// Internal status code.
    MLCStatusTypeInternal35 = 35,

    /// Internal status code.
    MLCStatusTypeInternal36 = 36,

    /// Internal status code.
    MLCStatusTypeInternal37 = 37,

    /// Invalid account.
    MLCStatusTypeInvalidAccount = 38,

    /// Invalid message.
    MLCStatusTypeInvalidMessage = 39,

    /// Invalid phone number.
    MLCStatusTypeInvalidPhone = 40,

    /// Invalid group.
    MLCStatusTypeInvalidGroup = 41,

    /// Internal status code.
    MLCStatusTypeInternal42 = 42,

    /// Invalid platform.
    MLCStatusTypeInvalidPlatform = 43,

    /// Could not send message.
    MLCStatusTypeCouldNotSendMessage = 44,

    /// Invalid payload.
    MLCStatusTypeInvalidPayload = 45,

    /// Internal status code.
    MLCStatusTypeInternal46 = 46,

    /// Internal status code.
    MLCStatusTypeInternal47 = 47,

    /// Unsupported message type.
    MLCStatusTypeUnsupportedMessageType = 48,

    /// Already redeemed.
    MLCStatusTypeAlreadyRedeemed = 49,

    /// Max redemptions reached.
    MLCStatusTypeMaxRedemptionsReached = 50,

    /// Not authorized.
    MLCStatusTypeNotAuthorized = 51,

    /// Deal expired.
    MLCStatusTypeDealExpired = 52,

    /// Unsupported payment type.
    MLCStatusTypeUnsupportedPaymentType = 53,

    /// No geo match for event.
    MLCStatusTypeNoGeoMatchForEvents = 54,

    /// Invalid auth token.
    MLCStatusTypeInvalidAuthToken = 55,

    /// Internal status code.
    MLCStatusTypeInternal56 = 56,

    /// Internal status code.
    MLCStatusTypeInternal57 = 57,

    /// Internal status code.
    MLCStatusTypeInternal58 = 58,

    /// Internal status code.
    MLCStatusTypeInternal59 = 59,

    /// Internal status code.
    MLCStatusTypeInternal60 = 60,

    /// User required.
    MLCStatusTypeUserRequired = 61,

    /// Invalid location id.
    MLCStatusTypeInvalidLocationId = 62,

    /// No media found.
    MLCStatusTypeNoMediaFound = 63,

    /// Internal status code.
    MLCStatusTypeInternal64 = 64,

    /// Internal status code.
    MLCStatusTypeInternal65 = 65,

    /// No geo matches.
    MLCStatusTypeNoGeoMatches = 66,

    /// No location found.
    MLCStatusTypeNoLocationFound = 67,

    /// Unsupported media format.
    MLCStatusTypeUnsupportedMediaFormat = 68,

    /// User suspended.
    MLCStatusTypeUserSuspended = 69,

    /// User already related.
    MLCStatusTypeUserAlreadyRelated = 70,

    /// User not related.
    MLCStatusTypeUserNotRelated = 71,

    /// No users found.
    MLCStatusTypeNoUsersFound = 72,

    /// User already registered.
    MLCStatusTypeUserAlreadyRegistered = 73,

    /// User already checked-in.
    MLCStatusTypeUserAlreadyCheckedIn = 74,

    /// No affinity found.
    MLCStatusTypeNoAffinityFound = 75,

    /// Internal status code.
    MLCStatusTypeInternal76 = 76,

    /// Internal status code.
    MLCStatusTypeInternal77 = 77,

    /// Invalid event.
    MLCStatusTypeInvalidEvent = 78,

    /// Internal status code.
    MLCStatusTypeInternal79 = 79,

    /// Internal status code.
    MLCStatusTypeInternal80 = 80,

    /// Internal status code.
    MLCStatusTypeInternal81 = 81,

    /// Internal status code.
    MLCStatusTypeInternal82 = 82,

    /// Internal status code.
    MLCStatusTypeInternal83 = 83,

    /// Internal status code.
    MLCStatusTypeInternal84 = 84,

    /// Internal status code.
    MLCStatusTypeInternal85 = 85,

    /// User not found.
    MLCStatusTypeUserNotFound = 86,

    /// Internal status code.
    MLCStatusTypeInternal87 = 87,

    /// Invalid date of birth.
    MLCStatusTypeInvalidDateOfBirth = 88,

    /// Invalid device id.
    MLCStatusTypeInvalidDeviceId = 89,

    /// Device not registered.
    MLCStatusTypeDeviceNotRegistered = 90,

    /// Invalid notification id.
    MLCStatusTypeInvalidNotificationId = 91,

    /// Invalid date.
    MLCStatusTypeInvalidDate = 92,

    /// User account locked.
    MLCStatusTypeUserAccountLocked = 93,

    /// Force password change.
    MLCStatusTypeForcePasswordChange = 94,

    /// Internal status code.
    MLCStatusTypeInternal95 = 95,

    /// Internal status code.
    MLCStatusTypeInternal96 = 96,

    /// Invalid gender.
    MLCStatusTypeInvalidGender = 97,

    /// Invalid event id.
    MLCStatusTypeInvalidEventId = 98,

    /// No credentials found.
    MLCStatusTypeNoCredentialsFound = 99,

    /// Invalid leaderboard type.
    MLCStatusTypeInvalidLeaderboardType = 100,

    /// Internal status code.
    MLCStatusTypeInternal101 = 101,

    /// Internal status code.
    MLCStatusTypeInternal102 = 102,

    /// Internal status code.
    MLCStatusTypeInternal103 = 103,

    /// Internal status code.
    MLCStatusTypeInternal104 = 104,

    /// Internal status code.
    MLCStatusTypeInternal105 = 105,

    /// Internal status code.
    MLCStatusTypeInternal106 = 106,

    /// Internal status code.
    MLCStatusTypeInternal107 = 107,

    /// Internal status code.
    MLCStatusTypeInternal108 = 108,

    /// Internal status code.
    MLCStatusTypeInternal109 = 109,

    /// Internal status code.
    MLCStatusTypeInternal110 = 110,

    /// Internal status code.
    MLCStatusTypeInternal111 = 111,

    /// Internal status code.
    MLCStatusTypeInternal112 = 112,

    /// Internal status code.
    MLCStatusTypeInternal113 = 113,

    /// Internal status code.
    MLCStatusTypeInternal114 = 114,

    /// Internal status code.
    MLCStatusTypeInternal115 = 115,

    /// Internal status code.
    MLCStatusTypeInternal116 = 116,

    /// Internal status code.
    MLCStatusTypeInternal117 = 117,

    /// Internal status code.
    MLCStatusTypeInternal118 = 118,

    /// Internal status code.
    MLCStatusTypeInternal119 = 119,

    /// Internal status code.
    MLCStatusTypeInternal120 = 120,

    /// Internal status code.
    MLCStatusTypeInternal121 = 121,

    /// Internal status code.
    MLCStatusTypeInternal122 = 122,

    /// Internal status code.
    MLCStatusTypeInternal123 = 123,

    /// Internal status code.
    MLCStatusTypeInternal124 = 124,

    /// Internal status code.
    MLCStatusTypeInternal125 = 125,

    /// Already purchased.
    MLCStatusTypeAlreadyPurchased = 126,

    /// Not enough points.
    MLCStatusTypeNotEnoughPoints = 127,

    /// No commerce point type.
    MLCStatusTypeNoCommercePointType = 128,

    /// Not purchasable.
    MLCStatusTypeNotPurchasable = 129,

    /// Invalid API key.
    MLCStatusTypeInvalidAPIKey = 130,

    /// Invalid request.
    MLCStatusTypeInvalidRequest = 131,

    /// No rewards found.
    MLCStatusTypeNoRewardsFound = 132,

    /// Invalid reward id.
    MLCStatusTypeInvalidRewardId = 133,

    /// Invalid state.
    MLCStatusTypeInvalidState = 134,

    /// Invalid content name.
    MLCStatusTypeInvalidContentName = 135,

    /// No content found.
    MLCStatusTypeNoContentFound = 136,

    /// Invalid content fields.
    MLCStatusTypeInvalidContentFields = 137,

    /// No events found.
    MLCStatusTypeNoEventsFound = 138,

    /// Internal status code.
    MLCStatusTypeInternal139 = 139,

    /// Internal status code.
    MLCStatusTypeInternal140 = 140,

    /// No groups found..
    MLCStatusTypeNoGroupsFound = 141
};

/**
 MLCStatus objects are created by services that do not retrieve data,
 but otherwise signify resuts when they are run.
 */
@interface MLCStatus : MLCEntity

/**
 The message for the status.
 */
@property (copy, nonatomic) NSString *message;

/**
 The type for the status. 
 
 @see MLCStatusType
 */
@property (nonatomic) MLCStatusType type;

/**
 The help URL for the status.
 */
@property (strong, nonatomic) NSURL *helpUrl;

/**
 The HTTP status code for the status.
 */
@property (nonatomic) NSInteger httpStatus;

/**
 The verbose message for the status.
 */
@property (copy, nonatomic) NSString *verboseMessage;

@end

@interface MLCStatus (Deprecated)

/**
 The statusType property has been deprecated,
 and will be removed in the next major release.

 @deprecated Use 'type' instead.

 @see type
 */
@property (nonatomic) NSInteger statusType __attribute__((deprecated ("Use 'type' instead.")));

@end
