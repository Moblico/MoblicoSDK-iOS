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

#import <MoblicoSDK/MLCService.h>
@class MLCMessage;
@class MLCDeal;
@class MLCReward;

typedef NS_ENUM(NSUInteger, MLCMessageServiceType) {
    MLCMessageServiceTypeShare
};

/**
 Messages can be sent from mobile applications to multiple devices, using the
 device ID, phone number, and email address.
 
 Use the MLCMessageService to send a MLCMessage using the Moblico platform.

 @since Available in MoblicoSDK 1.4 and later.
 */
@interface MLCMessageService : MLCService

/**
 This method is used to send a message with a MLCMessage object.

 @param message The MLCMessage to send.
 @param handler The request completion handler.

 @return A MLCMessageService instance.

 @since Available in MoblicoSDK 1.4 and later.
 
 @see -[MLCService start]
 */
+ (instancetype)sendMessage:(MLCMessage *)message handler:(MLCServiceResourceCompletionHandler)handler;

/**
 This method is used to send a message with the provided parameters.

 @param text           The text for this message.
 @param deviceIds      The recipient device ids for this message.
 @param phoneNumbers   The recipient phone numbers for this message.
 @param emailAddresses The recipient email addresses for this message.
 @param handler        The request completion handler.

 @return A MLCMessageService instance.

 @since Available in MoblicoSDK 1.4 and later.
 */
+ (instancetype)sendMessageWithText:(NSString *)text toDeviceIds:(NSArray *)deviceIds phoneNumbers:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses handler:(MLCServiceResourceCompletionHandler)handler;


+ (instancetype)readMessageForDeal:(MLCDeal *)deal type:(MLCMessageServiceType)type handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readMessageForReward:(MLCReward *)reward type:(MLCMessageServiceType)type handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readMessageForResource:(id<MLCEntityProtocol>)resource type:(MLCMessageServiceType)type handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)updateMessageWithMessageId:(NSUInteger)messageId status:(NSString *)status handler:(MLCServiceSuccessCompletionHandler)handler;

@end
