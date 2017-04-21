//
//  MLCKeychainPasswordItem.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/11/17.
//  Copyright © 2017 Moblico Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const MLCKeychainPasswordItemErrorDomain;
FOUNDATION_EXPORT NSString *const MLCKeychainPasswordItemErrorKeyOSStatus;
typedef NS_ENUM(NSUInteger, MLCKeychainPasswordItemErrorCode) {
    MLCKeychainPasswordItemErrorCodeNoData,
    MLCKeychainPasswordItemErrorCodeInvalidData,
    MLCKeychainPasswordItemErrorCodeInvalidItem,
    MLCKeychainPasswordItemErrorCodeInvalidStatus
};

@interface MLCKeychainPasswordItem : NSObject
@property (nonatomic, copy, readonly) NSString *service;
@property (nonatomic, copy, readonly, nullable) NSString *accessGroup;
@property (nonatomic, copy, readonly) NSString *account;

- (instancetype)initWithService:(NSString *)service account:(NSString *)account;
- (instancetype)initWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup;

- (BOOL)renameAccount:(NSString *)account error:(NSError **)error;
- (BOOL)saveData:(id<NSCoding>)data error:(NSError **)error;
- (nullable id<NSCoding>)readData:(NSError **)error;


+ (BOOL)destroyItem:(MLCKeychainPasswordItem *)item error:(NSError **)error;

+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service error:(NSError **)error;
+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
