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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const MLCKeychainPasswordItemErrorDomain NS_SWIFT_NAME(MLCKeychainPasswordItem.ErrorDomain);

FOUNDATION_EXPORT NSErrorUserInfoKey const MLCKeychainPasswordItemOSStatusErrorKey NS_SWIFT_NAME(MLCKeychainPasswordItem.OSStatusErrorKey);

typedef NS_ERROR_ENUM(MLCKeychainPasswordItemErrorDomain, MLCKeychainPasswordItemErrorCode) {
    MLCKeychainPasswordItemErrorCodeNoData,
    MLCKeychainPasswordItemErrorCodeInvalidData,
    MLCKeychainPasswordItemErrorCodeInvalidItem,
    MLCKeychainPasswordItemErrorCodeInvalidStatus
} NS_SWIFT_NAME(MLCKeychainPasswordItem.Error);

NS_SWIFT_NAME(KeychainPasswordItem)
@interface MLCKeychainPasswordItem : NSObject

@property (nonatomic, copy, readonly) NSString *service;
@property (nonatomic, copy, readonly, nullable) NSString *accessGroup;
@property (nonatomic, copy, readonly) NSString *account;

- (instancetype)initWithService:(NSString *)service account:(NSString *)account;
- (instancetype)initWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup;

- (BOOL)renameAccount:(NSString *)account error:(out NSError **)error;
- (BOOL)saveData:(id<NSCoding>)data error:(out NSError **)error;
- (nullable id<NSCoding>)readData:(out NSError **)error;


+ (BOOL)destroyItem:(MLCKeychainPasswordItem *)item error:(out NSError **)error;

+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service error:(out NSError **)error;
+ (NSArray<MLCKeychainPasswordItem *> *)itemsWithService:(NSString *)service accessGroup:(NSString *)accessGroup error:(out NSError **)error;
@end

@interface MLCKeychainPasswordItemError : NSError
@property (nonatomic, assign) OSStatus status;
@end

NS_ASSUME_NONNULL_END
