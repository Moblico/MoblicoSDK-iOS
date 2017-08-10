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
    NSMutableDictionary *renamed = [@{@"notificationMessage": @"message",
                                      @"notificationTitle": @"title",
                                      @"notificationType": @"type"} mutableCopy];

    [renamed addEntriesFromDictionary:[super renamedPropertiesDuringDeserialization]];

    return renamed;
}

+ (NSDictionary *)renamedPropertiesDuringSerialization {
    NSDictionary *renamedDuringDeserialization = [self renamedPropertiesDuringDeserialization];

    NSMutableDictionary *renamed = [NSMutableDictionary dictionaryWithCapacity:renamedDuringDeserialization.count];

    [renamedDuringDeserialization enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        renamed[obj] = key;
    }];

    return renamed;
}
@end
