//
//  MLCMessage.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/8/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

/**
 Messages can be sent from mobile applications to multiple devices, using the
 device ID, phone number, and email address.

 A MLCMessage object encapsulates the data of a message which will be sent from
 Moblico.

 @since Available in MoblicoSDK 1.4 and later.
 */
@interface MLCMessage : MLCEntity

/**
 The text for this message.

 @since Available in MoblicoSDK 1.4 and later.
 */
@property (nonatomic, strong) NSString *text;

/**
 The device IDs for the recipents of this message.

 @since Available in MoblicoSDK 1.4 and later.
 */
@property (nonatomic, strong) NSArray *deviceIds;

/**
 The phone numbers for the recipients of this message.

 @since Available in MoblicoSDK 1.4 and later.
 */
@property (nonatomic, strong) NSArray *phoneNumbers;

/**
 The email addresses for the recipents of this message.

 @since Available in MoblicoSDK 1.4 and later.
 */
@property (nonatomic, strong) NSArray *emailAddresses;

/**
 Convenience class method to create a MLCMessage object with the provided parameters.

 @param text           The text for this message.
 @param deviceIds      The recipient device ids for this message.
 @param phoneNumbers   The recipient phone numbers for this message.
 @param emailAddresses The recipient email addresses for this message.

 @return A MLCMessage object to use with +[MLCMessageService sendMessage:].

 @since Available in MoblicoSDK 1.4 and later.
 */
+ (instancetype)messageWithText:(NSString *)text deviceIds:(NSArray *)deviceIds phoneNumbers:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses;

@end
