//
//  MLCMessage.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/8/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCMessage.h"

@implementation MLCMessage

+ (instancetype)messageWithText:(NSString *)text deviceIds:(NSArray *)deviceIds phoneNumbers:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses {
    MLCMessage *message = [[self alloc] init];

    message.text = text;
    message.deviceIds = deviceIds;
    message.phoneNumbers = phoneNumbers;
    message.emailAddresses = emailAddresses;

    return message;
}

+ (NSString *)collectionName {
    return @"users/message";
}

+ (NSDictionary *)serialize:(MLCMessage *)message {
    NSMutableDictionary *serializedObject = [[super serialize:message] mutableCopy];

    if (message.text) {
        serializedObject[@"messageText"] = message.text;
    }

    [serializedObject removeObjectForKey:@"text"];

    return serializedObject;
}

@end
