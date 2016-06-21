//
//  MLCNotification.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCNotification.h"
#import "MLCEntity_Private.h"
@implementation MLCNotification

//+ (id)deserialize:(id)object {
//    Notification * notification = [[Notification alloc] init];
//
//    for (id temp in object) {
//        id key = temp;
//        id value = object[key];
//        if ([key isEqualToString:@"id"]) key = @"notificationId";
//        if ([key isEqualToString:@"notificationMessage"]) key = ;
//        if ([key isEqualToString:@"notificationTitle"]) key = @"title";
//        if ([key isEqualToString:@"notificationType"]) key = @"type";
//        @try {
//            [notification setValue:value forKey:key];
//        }
//        @catch (NSException *exception) {
//            if ([[exception name] isEqualToString:NSUndefinedKeyException]) {
//                MLCLogDebug(@"Notification does not recognize the property %@", key);
//            } else MLCLogDebug(@"Notification had an exception: %@", exception);
//        }
//    }
//    return notification;
//}

+ (NSDictionary *)renamedPropertiesDuringDeserialization {
    NSMutableDictionary *renamed = [@{
                                      @"notificationMessage" : @"message",
                                      @"notificationTitle" : @"title",
                                      @"notificationType" : @"type"
                                      } mutableCopy];

    [renamed addEntriesFromDictionary:[super renamedPropertiesDuringDeserialization]];

    return renamed;
}

+ (NSDictionary *)renamedPropertiesDuringSerialization {
    NSDictionary *renamedDuringDeserialization = [self renamedPropertiesDuringDeserialization];

    NSMutableDictionary *renamed = [NSMutableDictionary dictionaryWithCapacity:renamedDuringDeserialization.count];

    [renamedDuringDeserialization enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        renamed[obj] = key;
    }];

    return renamed;
}
@end
