//
//  MLCKeychainPasswordItem.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/11/17.
//  Copyright © 2017 Moblico Solutions LLC. All rights reserved.
//

#import "MLCKeychainPasswordItem.h"

NSErrorDomain const MLCKeychainPasswordItemErrorDomain = @"MLCKeychainPasswordItemErrorDomain";
NSErrorUserInfoKey const MLCKeychainPasswordItemOSStatusErrorKey = @"OSStatus";

@interface MLCKeychainPasswordItemError ()

+ (instancetype)noData;

+ (instancetype)invalidData;

+ (instancetype)invalidItem;

+ (instancetype)invalidStatus:(OSStatus)status;

@end

typedef NSString *MLCKeychainPasswordItemMatchLimit NS_TYPED_ENUM;

MLCKeychainPasswordItemMatchLimit const MLCKeychainPasswordItemMatchLimitOne = @"MLCKeychainPasswordItemMatchLimitOne";
MLCKeychainPasswordItemMatchLimit const MLCKeychainPasswordItemMatchLimitAll = @"MLCKeychainPasswordItemMatchLimitAll";

@interface MLCKeychainPasswordItem ()

@property (nonatomic, copy, readwrite) NSString *service;
@property (nonatomic, copy, readwrite, nullable) NSString *accessGroup;
@property (nonatomic, copy, readwrite) NSString *account;

+ (NSArray<MLCKeychainPasswordItem *> *)_itemsWithService:(NSString *)service accessGroup:(nullable NSString *)accessGroup error:(out NSError **)error;

+ (NSDictionary<NSString *, id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup;
+ (NSDictionary<NSString *, id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup limit:(MLCKeychainPasswordItemMatchLimit)limit returnAttributes:(NSNumber *)returnAttributes returnData:(NSNumber *)returnData;

@end

@implementation MLCKeychainPasswordItem

+ (instancetype)itemWithService:(NSString *)service account:(NSString *)account {
    return [[self alloc] initWithService:service account:account accessGroup:nil];
}

+ (instancetype)itemWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    return [[self alloc] initWithService:service account:account accessGroup:accessGroup];
}

- (instancetype)initWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    self = [super init];
    if (self) {
        _service = service;
        _account = account;
        _accessGroup = accessGroup;
    }
    return self;
}

+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service error:(out NSError **)error {
    return [self _itemsWithService:service accessGroup:nil error:error];
}

+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service accessGroup:(NSString *)accessGroup error:(out NSError **)error {
    return [self _itemsWithService:service accessGroup:accessGroup error:error];
}

+ (NSArray<MLCKeychainPasswordItem *> *)_itemsWithService:(NSString *)service accessGroup:(NSString *)accessGroup error:(out NSError **)error {

    NSDictionary<NSString *, id> *query = [self queryWithService:service account:nil accessGroup:accessGroup limit:MLCKeychainPasswordItemMatchLimitAll returnAttributes:@YES returnData:@NO];

    CFArrayRef queryResults = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResults);
    NSArray<NSString *> *accounts = [self accountsFromQueryResults:queryResults status:status error:error];
    if (queryResults) {
        CFRelease(queryResults);
    }

    if (!accounts) {
        return nil;
    }

    NSMutableArray<MLCKeychainPasswordItem *> *items = [NSMutableArray arrayWithCapacity:accounts.count];
    for (NSString *account in accounts) {
        MLCKeychainPasswordItem *item = [[self alloc] initWithService:service account:account accessGroup:accessGroup];
        [items addObject:item];
    }

    return items;
}

+ (NSArray<NSString *> *)accountsFromQueryResults:(CFArrayRef)queryResults status:(OSStatus)status error:(NSError *__autoreleasing *)error {
    if (status == errSecItemNotFound) {
        return @[];
    }

    if (status != noErr) {
        if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
        return nil;
    }

    NSArray<NSDictionary<NSString *, id> *> *resultData = (__bridge NSArray *)queryResults;
    if (![resultData isKindOfClass:[NSArray class]]) {
        if (error) *error = [MLCKeychainPasswordItemError invalidItem];
        return @[];
    }

    NSMutableArray<NSString *> *accounts = [NSMutableArray arrayWithCapacity:resultData.count];
    for (id result in resultData) {
        if (![result isKindOfClass:[NSDictionary class]]) {
            if (error) *error = [MLCKeychainPasswordItemError invalidItem];
            return @[];
        }

        NSString *account = result[(__bridge NSString *)kSecAttrAccount];
        [accounts addObject:account];
    }

    return accounts;
}

- (BOOL)setObject:(id)obj forKey:(NSString *)key error:(out NSError **)error {
    NSDictionary *attributesToUpdate = @{key: obj};
    NSDictionary<NSString *, id> *query = [[self class] queryWithService:self.service account:self.account accessGroup:self.accessGroup];
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);

    if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];

    return status == noErr;
}

- (id<NSCoding>)readDataOfClass:(Class)class error:(out NSError **)error {
    NSDictionary<NSString *, id> *query = [[self class] queryWithService:self.service account:self.account accessGroup:self.accessGroup limit:MLCKeychainPasswordItemMatchLimitOne returnAttributes:@YES returnData:@YES];

    CFDictionaryRef queryResult = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResult);
    NSData *data = [self dataFromQueryResult:queryResult status:status error:error];
    if (queryResult) {
        CFRelease(queryResult);
    }

    if (!data) {
        return nil;
    }

    return [NSKeyedUnarchiver unarchivedObjectOfClass:class fromData:data error:nil];;
}

- (NSData * _Nullable)dataFromQueryResult:(CFDictionaryRef)queryResult status:(OSStatus)status error:(NSError *__autoreleasing * _Nullable)error {
    if (status == errSecItemNotFound) {
        if (error) *error = [MLCKeychainPasswordItemError noData];
        return nil;
    }

    if (status != noErr) {
        if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
        return nil;
    }


    NSDictionary<NSString *, id> *result = (__bridge NSDictionary *)queryResult;
    if (![result isKindOfClass:[NSDictionary class]]) {
        if (error) *error = [MLCKeychainPasswordItemError invalidData];
        return nil;
    }

    NSData *data = result[(__bridge NSString *)kSecValueData];
    if (!data) {
        if (error) *error = [MLCKeychainPasswordItemError invalidData];
        return nil;
    }

    return data;
}

- (BOOL)saveData:(id<NSCoding>)data ofClass:(Class)class error:(out NSError **)error {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:NO error:nil];

    NSError *readError;
    if (![self readDataOfClass:class error:&readError] && readError) {
        if (readError.code != MLCKeychainPasswordItemErrorCodeNoData) {
            if (error) *error = readError;
            return NO;
        }

        NSMutableDictionary<NSString *, id> *newItem = [[[self class] queryWithService:self.service account:self.account accessGroup:self.accessGroup] mutableCopy];
        newItem[(__bridge NSString *)kSecValueData] = archivedData;
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)newItem, nil);
        if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
        return status == noErr;
    }

    return [self setObject:archivedData forKey:(__bridge NSString *)kSecValueData error:error];
}

- (BOOL)renameAccount:(NSString *)account error:(out NSError **)error {
    BOOL success = [self setObject:account
                            forKey:(__bridge NSString *)kSecAttrAccount
                             error:error];

    if (success) {
        self.account = account;
    }

    return success;
}

+ (BOOL)destroyItem:(MLCKeychainPasswordItem *)item error:(out NSError **)error {
    NSDictionary<NSString *, id> *query = [self queryWithService:item.service account:item.account accessGroup:item.accessGroup];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (error) *error = [MLCKeychainPasswordItemError invalidStatus:status];
    return status == noErr;
}


+ (NSDictionary<NSString *, id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    return [self queryWithService:service account:account accessGroup:accessGroup limit:nil returnAttributes:nil returnData:nil];
}

+ (NSDictionary<NSString *, id> *)queryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup limit:(NSString *)limit returnAttributes:(NSNumber *)returnAttributes returnData:(NSNumber *)returnData {
    NSMutableDictionary<NSString *, id> *query = [NSMutableDictionary<NSString *, id> dictionary];
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

    if (returnAttributes != nil) {
        query[(__bridge id)kSecReturnAttributes] = (__bridge id)(returnAttributes.boolValue ? kCFBooleanTrue : kCFBooleanFalse);
    }

    if (returnData != nil) {
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

+ (instancetype)noData {
    return [self errorWithDomain:MLCKeychainPasswordItemErrorDomain
                            code:MLCKeychainPasswordItemErrorCodeNoData
                        userInfo:nil];
}

+ (instancetype)invalidData {
    return [self errorWithDomain:MLCKeychainPasswordItemErrorDomain
                            code:MLCKeychainPasswordItemErrorCodeInvalidData
                        userInfo:nil];
}

+ (instancetype)invalidItem {
    return [self errorWithDomain:MLCKeychainPasswordItemErrorDomain
                            code:MLCKeychainPasswordItemErrorCodeInvalidItem
                        userInfo:nil];
}

+ (instancetype)invalidStatus:(OSStatus)status {
    if (status == noErr) return nil;
    return [self errorWithDomain:MLCKeychainPasswordItemErrorDomain
                            code:MLCKeychainPasswordItemErrorCodeInvalidStatus
                        userInfo:@{MLCKeychainPasswordItemOSStatusErrorKey: @(status)}];
}

@end
