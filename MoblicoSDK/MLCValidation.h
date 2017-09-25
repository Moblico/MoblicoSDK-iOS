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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class MLCEntity;

FOUNDATION_EXPORT NSErrorDomain const MLCValidationErrorDomain NS_SWIFT_NAME(MLCValidation.ErrorDomain);
FOUNDATION_EXPORT NSErrorUserInfoKey const MLCValidationDetailedErrorsKey NS_SWIFT_NAME(MLCValidation.DetailedErrorsKey);

typedef BOOL(^MLCValidateTest)(__kindof MLCEntity *entity, NSString *key, NSString *_Nullable value) NS_SWIFT_NAME(MLCValidate.Test);

typedef NS_ERROR_ENUM(MLCValidationErrorDomain, MLCValidationErrorCode) {
    MLCValidationErrorUnknown NS_SWIFT_NAME(unknown) = -1,
    MLCValidationErrorFailure NS_SWIFT_NAME(failure) = 0,
    MLCValidationErrorMultipleFailures NS_SWIFT_NAME(multiple) = 1
} NS_SWIFT_NAME(MLCValidation.Error);


@class MLCValidate, MLCValidation, MLCValidationError;

NS_SWIFT_NAME(Validations)
@interface MLCValidations : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

- (void)appendRule:(MLCValidate *)rule forKey:(NSString *)key NS_SWIFT_NAME(append(_:forKey:));
- (void)appendRules:(NSArray<MLCValidate *> *)rules forKey:(NSString *)key NS_SWIFT_NAME(append(_:forKey:));

- (NSArray<MLCValidate *> *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(NSArray<MLCValidate *> *)obj forKeyedSubscript:(NSString *)key;

- (MLCValidation *)validate:(MLCEntity *)entity key:(NSString *)key value:(inout id _Nullable __autoreleasing *_Nonnull)ioValue;

@end

NS_SWIFT_NAME(Validate)
@interface MLCValidate : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)validatePresenceWithMessage:(NSString *)message NS_SWIFT_NAME(init(presence:));
+ (instancetype)validateFormat:(NSString *)format caseSensitive:(BOOL)caseSensitive message:(NSString *)message;
+ (instancetype)validateFormat:(NSString *)format message:(NSString *)message; // Case insensitive by default
+ (instancetype)validateCaseSensitiveFormat:(NSString *)format message:(NSString *)message;
+ (instancetype)validateWithPredicate:(NSPredicate *)predicate errorMessage:(NSString *)message;
- (instancetype)initWithMessage:(NSString *)message validateTest:(MLCValidateTest)test;
@end

NS_SWIFT_NAME(Validation)
@interface MLCValidation : NSObject
@property (nonatomic, readonly, strong, nullable) MLCValidationError *error;
@property (nonatomic, getter=isValid, readonly) BOOL valid;
@end

NS_SWIFT_NAME(MLCValidation.Error)
@interface MLCValidationError : NSError

@property (nonatomic, readonly, copy, nullable) NSArray<MLCValidationError *> *errors;
+ (instancetype)errorWithMessage:(NSString *)message;
+ (instancetype)errorWithErrors:(NSArray<MLCValidationError *> *)errors;
@property (nonatomic, readonly, strong, class) MLCValidationError *unknownError;

@end

NS_ASSUME_NONNULL_END

