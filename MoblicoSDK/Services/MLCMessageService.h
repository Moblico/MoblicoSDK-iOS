//
//  MLCMessageService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/8/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@class MLCMessage;

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
 
 @see -[MLCServiceProtocol start]
 */
+ (instancetype)sendMessage:(MLCMessage *)message handler:(MLCServiceStatusCompletionHandler)handler;

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
+ (instancetype)sendMessageWithText:(NSString *)text toDeviceIds:(NSArray *)deviceIds phoneNumbers:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses handler:(MLCServiceStatusCompletionHandler)handler;

@end
