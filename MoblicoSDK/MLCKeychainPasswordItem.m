//
//  MLCKeychainPasswordItem.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/11/17.
//  Copyright © 2017 Moblico Solutions LLC. All rights reserved.
//

#import "MLCKeychainPasswordItem.h"

NSString *const MLCKeychainPasswordItemErrorDomain = @"MLCKeychainPasswordItemErrorDomain";
NSString *const MLCKeychainPasswordItemErrorKeyOSStatus = @"OSStatus";

@interface MLCKeychainPasswordItemError : NSObject
+ (NSError *)noData;
+ (NSError *)invalidData;
+ (NSError *)invalidItem;
+ (NSError *)invalidStatus:(OSStatus)status;
@end

typedef NSString * MLCKeychainPasswordItemMatchLimit NS_STRING_ENUM;

MLCKeychainPasswordItemMatchLimit const MLCKeychainPasswordItemMatchLimitOne = @"MLCKeychainPasswordItemMatchLimitOne";
MLCKeychainPasswordItemMatchLimit const MLCKeychainPasswordItemMatchLimitAll = @"MLCKeychainPasswordItemMatchLimitAll";

@interface MLCKeychainPasswordItem ()
@property (nonatomic, copy, readwrite) NSString *service;
@property (nonatomic, copy, readwrite, nullable) NSString *accessGroup;
@property (nonatomic, copy, readwrite) NSString *account;

- (instancetype)__initWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup;

+ (NSArray<MLCKeychainPasswordItem *> *)__itemsWithService:(NSString *)service accessGroup:(nullable NSString *)accessGroup error:(NSError **)error;
+ (NSDictionary<NSString *, id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup;
+ (NSDictionary<NSString *, id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup limit:(MLCKeychainPasswordItemMatchLimit)limit returnAttributes:(NSNumber *)returnAttributes returnData:(NSNumber *)returnData;

@end

@implementation MLCKeychainPasswordItem

- (instancetype)initWithService:(NSString *)service account:(NSString *)account {
    return [self __initWithService:service account:account accessGroup:nil];
}

- (instancetype)initWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    return [self __initWithService:service account:account accessGroup:accessGroup];
}

- (instancetype)__initWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    self = [super init];
    if (self) {
        self.service = service;
        self.account = account;
        self.accessGroup = accessGroup;
    }
    return self;
}

+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service error:(NSError **)error {
    return [self __itemsWithService:service accessGroup:nil error:error];
}

+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError **)error {
    return [self __itemsWithService:service accessGroup:accessGroup error:error];
}

+ (NSArray<MLCKeychainPasswordItem *> *)__itemsWithService:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError **)error {

    NSDictionary<NSString *,id> *query = [self queryWithService:service account:nil accessGroup:accessGroup limit:MLCKeychainPasswordItemMatchLimitAll returnAttributes:@YES returnData:@NO];

    CFArrayRef queryResults = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResults);

    if (status == errSecItemNotFound) {
        return @[];
    }

    if (status != noErr) {
        if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
        return nil;
    }

    NSArray<NSDictionary<NSString *, id> *> *resultData = (__bridge NSArray *)queryResults;
    if (![resultData isKindOfClass:NSArray.class]) {
        if (error) *error = [MLCKeychainPasswordItemError invalidItem];
        return @[];
    }

    NSMutableArray<MLCKeychainPasswordItem *> *items = [NSMutableArray arrayWithCapacity:resultData.count];
    for (NSDictionary<NSString *, id> *result in resultData) {
        if (![result isKindOfClass:NSDictionary.class]) {
            if (error) *error = [MLCKeychainPasswordItemError invalidItem];
            return @[];
        }

        NSString *account = result[(__bridge NSString *)kSecAttrAccount];

        MLCKeychainPasswordItem *item = [[MLCKeychainPasswordItem alloc] initWithService:service account:account accessGroup:accessGroup];
        [items addObject:item];
    }

    return items;
}

- (BOOL)setObject:(id)obj forKey:(NSString *)key error:(NSError **)error {
    NSDictionary *attributesToUpdate = @{key : obj};
    NSDictionary<NSString *,id> *query = [self.class queryWithService:self.service account:self.account accessGroup:self.accessGroup];
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);

    if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];

    return status == noErr;
}

- (id<NSCoding>)readData:(NSError **)error {
    NSDictionary<NSString *,id> *query = [self.class queryWithService:self.service account:self.account accessGroup:self.accessGroup limit:MLCKeychainPasswordItemMatchLimitOne returnAttributes:@YES returnData:@YES];

    CFDictionaryRef queryResult = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResult);

    if (status == errSecItemNotFound) {
        if (error) *error = [MLCKeychainPasswordItemError noData];
        return nil;
    }

    if (status != noErr) {
        if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
        return nil;
    }


    NSDictionary<NSString *, id> *result = (__bridge NSDictionary *)queryResult;
    if (![result isKindOfClass:NSDictionary.class]) {
        if (error) *error = [MLCKeychainPasswordItemError invalidData];
        return nil;
    }
    
    NSData *data = result[(__bridge NSString *)kSecValueData];
    if (!data) {
        if (error) *error = [MLCKeychainPasswordItemError invalidData];
        return nil;
    }

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (BOOL)saveData:(id<NSCoding>)data error:(NSError **)error {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];

    NSError *readError;
    if (![self readData:&readError]) {
        if (readError.code != MLCKeychainPasswordItemErrorCodeNoData) {
            if (error) *error = readError;
            return nil;
        }

        NSMutableDictionary<NSString *,id> *newItem = [self.class queryWithService:self.service account:self.account accessGroup:self.accessGroup].mutableCopy;
        newItem[(__bridge NSString *)kSecValueData] = archivedData;
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)newItem, nil);
        if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
        return status == noErr;
    }

    return [self setObject:archivedData forKey:(__bridge NSString *)kSecValueData error:error];
}

- (BOOL)renameAccount:(NSString *)account error:(NSError **)error{
    BOOL success = [self setObject:account
                               forKey:(__bridge NSString *)kSecAttrAccount
                                error:error];

    if (success) {
        self.account = account;
    }

    return success;
}

+ (BOOL)destroyItem:(MLCKeychainPasswordItem *)item error:(NSError **)error {
    NSDictionary<NSString *,id> *query = [self queryWithService:item.service account:item.account accessGroup:item.accessGroup];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
    return status == noErr;
}


+ (NSDictionary<NSString *,id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    return [self queryWithService:service account:account accessGroup:accessGroup limit:nil returnAttributes:nil returnData:nil];
}

+ (NSDictionary<NSString *,id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup limit:(NSString *)limit returnAttributes:(NSNumber *)returnAttributes returnData:(NSNumber *)returnData {
    NSMutableDictionary<NSString *,id> *query = [NSMutableDictionary<NSString *,id> dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)(kSecClassGenericPassword);
    query[(__bridge id)kSecAttrService] = service;

    if (account) {
        query[(__bridge id)kSecAttrAccount] = account;
    }

    if (accessGroup) {
        query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
    }

    NSString *matchLimit = [self stringFromMatchLimit:limit];
    if (matchLimit) {
        query[(__bridge id)kSecMatchLimit] = matchLimit;
    }

    if (returnAttributes) {
        query[(__bridge id)kSecReturnAttributes] = (__bridge id)(returnAttributes.boolValue ? kCFBooleanTrue : kCFBooleanFalse);
    }

    if (returnData) {
        query[(__bridge id)kSecReturnData] = (__bridge id)(returnData.boolValue ? kCFBooleanTrue : kCFBooleanFalse);

    }

    return query;
}

+ (NSString *)stringFromMatchLimit:(MLCKeychainPasswordItemMatchLimit)limit {
    if ([limit isEqualToString:MLCKeychainPasswordItemMatchLimitAll]) return (__bridge NSString *)kSecMatchLimitAll;
    if ([limit isEqualToString:MLCKeychainPasswordItemMatchLimitOne]) return (__bridge NSString *)kSecMatchLimitOne;

    return nil;
}

@end

@implementation MLCKeychainPasswordItemError

+ (NSError *)noData {
    return [NSError errorWithDomain:MLCKeychainPasswordItemErrorDomain
                               code:MLCKeychainPasswordItemErrorCodeNoData
                           userInfo:nil];
}

+ (NSError *)invalidData {
    return [NSError errorWithDomain:MLCKeychainPasswordItemErrorDomain
                               code:MLCKeychainPasswordItemErrorCodeInvalidData
                           userInfo:nil];
}

+ (NSError *)invalidItem {
    return [NSError errorWithDomain:MLCKeychainPasswordItemErrorDomain
                               code:MLCKeychainPasswordItemErrorCodeInvalidItem
                           userInfo:nil];
}

+ (NSError *)invalidStatus:(OSStatus)status {
    if (status == noErr) return nil;
    return [NSError errorWithDomain:MLCKeychainPasswordItemErrorDomain
                               code:MLCKeychainPasswordItemErrorCodeInvalidStatus
                           userInfo:@{MLCKeychainPasswordItemErrorKeyOSStatus: @(status)}];
}

@end
