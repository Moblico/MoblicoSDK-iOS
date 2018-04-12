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

#import "MLCService.h"
#import "MLCService_Private.h"
#import "MLCMessageService.h"
#import "MLCMessage.h"
#import "MLCDeal.h"
#import "MLCReward.h"

MLCMessageServiceStatus const MLCMessageServiceStatusOpened = @"OPENED";
MLCMessageServiceStatus const MLCMessageServiceStatusDelivered = @"DELIVERED";

@implementation MLCMessageService

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCDeal class], [MLCReward class]];
}

+ (Class)classForResource {
    return [MLCMessage class];
}

+ (instancetype)sendMessage:(MLCMessage *)message handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self createSuccessResource:message handler:handler];
}

+ (instancetype)sendMessageWithText:(NSString *)text toDeviceIds:(NSArray *)deviceIds phoneNumbers:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCMessage *message = [MLCMessage messageWithText:text deviceIds:deviceIds phoneNumbers:phoneNumbers emailAddresses:emailAddresses];

    return [self sendMessage:message handler:handler];
}

+ (instancetype)readMessageForDeal:(MLCDeal *)deal type:(MLCMessageServiceType)type handler:(MLCMessageServiceResourceCompletionHandler)handler {
    return [self readMessageForResource:deal type:type handler:handler];
}

+ (instancetype)readMessageForReward:(MLCReward *)reward type:(MLCMessageServiceType)type handler:(MLCMessageServiceResourceCompletionHandler)handler {
    return [self readMessageForResource:reward type:type handler:handler];
}

+ (instancetype)readMessageForResource:(MLCEntity *)resource type:(MLCMessageServiceType)type handler:(MLCMessageServiceResourceCompletionHandler)handler {
    if (![self canScopeResource:resource]) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
        MLCServiceError *error = [MLCServiceError invalidParameterErrorWithDescription:description];
        return [self invalidServiceWithError:error handler:handler];
    }

    NSString *messageType = @"SHARE";
    if (type == MLCMessageServiceTypeShare) {

    }
    NSString *path = [NSString pathWithComponents:@[[[resource class] collectionName], resource.uniqueIdentifier, [[self classForResource] resourceName]]];

    return [self read:path parameters:@{@"type": messageType} handler:handler];
}

+ (instancetype)updateMessageWithMessageId:(NSUInteger)messageId status:(MLCMessageServiceStatus)status handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [@"message" stringByAppendingPathComponent:@(messageId).stringValue];

    return [self update:path parameters:@{@"status": status} handler:handler];
}

@end
