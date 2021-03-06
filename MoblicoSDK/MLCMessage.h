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

/**
 Messages can be sent from mobile applications to multiple devices, using the
 device ID, phone number, and email address.

 A MLCMessage object encapsulates the data of a message which will be sent from
 Moblico.
 */
NS_SWIFT_NAME(Message)
@interface MLCMessage : MLCEntity

/**
 The text for this message.
 */
@property (copy, nonatomic, nullable) NSString *text;

/**
 The device IDs for the recipients of this message.
 */
@property (copy, nonatomic, nullable) NSArray<NSString *> *deviceIds;

/**
 The phone numbers for the recipients of this message.
 */
@property (copy, nonatomic, nullable) NSArray<NSString *> *phoneNumbers;

/**
 The email addresses for the recipients of this message.
 */
@property (copy, nonatomic, nullable) NSArray<NSString *> *emailAddresses;

/**
 Convenience class method to create a MLCMessage object with the provided parameters.

 @param text           The text for this message.
 @param deviceIds      The recipient device ids for this message.
 @param phoneNumbers   The recipient phone numbers for this message.
 @param emailAddresses The recipient email addresses for this message.

 @return A MLCMessage object to use with +[MLCMessageService sendMessage:].
 */
+ (nonnull instancetype)messageWithText:(nullable NSString *)text deviceIds:(nullable NSArray<NSString *> *)deviceIds phoneNumbers:(nullable NSArray<NSString *> *)phoneNumbers emailAddresses:(nullable NSArray<NSString *> *)emailAddresses;

@end
