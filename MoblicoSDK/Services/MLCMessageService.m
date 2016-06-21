//
//  MLCMessageService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/8/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCService.h"
#import "MLCService_Private.h"
#import "MLCMessageService.h"
#import "MLCMessage.h"
#import "MLCInvalidService.h"
#import "MLCDeal.h"
#import "MLCReward.h"

@implementation MLCMessageService

+ (NSArray *)scopeableResources {
    return @[@"MLCDeal", @"MLCReward"];
}

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCMessage class];
}

+ (instancetype)sendMessage:(MLCMessage *)message handler:(MLCServiceResourceCompletionHandler)handler {
    return [self createResource:message handler:handler];
}

+ (instancetype)sendMessageWithText:(NSString *)text toDeviceIds:(NSArray *)deviceIds phoneNumbers:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses handler:(MLCServiceResourceCompletionHandler)handler {
    MLCMessage *message = [MLCMessage messageWithText:text deviceIds:deviceIds phoneNumbers:phoneNumbers emailAddresses:emailAddresses];

    return [self sendMessage:message handler:handler];
}

+ (instancetype)readMessageForDeal:(MLCDeal *)deal type:(MLCMessageServiceType)type handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readMessageForResource:deal type:type handler:handler];
}

+ (instancetype)readMessageForReward:(MLCReward *)reward type:(MLCMessageServiceType)type handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readMessageForResource:reward type:type handler:handler];
}

+ (instancetype)readMessageForResource:(id<MLCEntityProtocol>)resource type:(MLCMessageServiceType)type handler:(MLCServiceResourceCompletionHandler)handler {
    if ([self canScopeResource:resource] == NO) {
        NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"%@ do not have %@", nil), [[self classForResource] collectionName], [[resource class] collectionName]];
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: failureReason}];
        return (MLCMessageService *)[MLCInvalidService invalidServiceWithError:error handler:handler];
    }

    NSString *messageType = @"SHARE";
    if (type == MLCMessageServiceTypeShare) {

    }
    NSString *path = [NSString pathWithComponents:@[[[resource class] collectionName], resource.uniqueIdentifier, [[self classForResource] resourceName]]];

    return [self read:path parameters:@{@"type": messageType} handler:handler];
}

+ (instancetype)updateMessageWithMessageId:(NSUInteger)messageId status:(NSString *)status handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [@"message" stringByAppendingPathComponent:@(messageId).stringValue];

    return [self update:path parameters:@{@"status": status} handler:handler];
}

@end
