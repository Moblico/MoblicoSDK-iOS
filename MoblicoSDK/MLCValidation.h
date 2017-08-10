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

@protocol MLCEntityProtocol;

FOUNDATION_EXPORT NSString *const MLCValidationErrorDomain;
FOUNDATION_EXPORT NSString *const MLCValidationDetailedErrorsKey;

typedef BOOL(^MLCValidationTest)(id<MLCEntityProtocol> entity, NSString *key, NSString *_Nullable value);

typedef NS_ENUM(NSInteger, MLCValidationErrorCode) {
    MLCValidationUnknownError NS_SWIFT_NAME(unknown) = -1,
    MLCValidationError NS_SWIFT_NAME(error) = 0,
    MLCValidationMultipleErrorsError NS_SWIFT_NAME(multiple) = 1
};

@class MLCValidate, MLCValidationResults;

@interface MLCValidations : NSObject
@property (nonatomic, assign, readonly) NSUInteger count;
- (NSArray<MLCValidate *> *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (MLCValidationResults *)validate:(id<MLCEntityProtocol>)entity key:(NSString *)key value:(inout id _Nullable __autoreleasing *_Nonnull)ioValue;

@end

@interface MLCValidate : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)validatePresenceWithMessage:(NSString *)message NS_SWIFT_NAME(init(presence:));
+ (instancetype)validateFormat:(NSString *)format message:(NSString *)message;
+ (instancetype)validateFormat:(NSString *)format caseSensitive:(BOOL)caseSensitive message:(NSString *)message;
+ (instancetype)validateWithPredicate:(NSPredicate *)predicate errorMessage:(NSString *)message;
- (instancetype)initWithMessage:(NSString *)message validationTest:(MLCValidationTest)test;
@end

@interface MLCValidationResults : NSObject
@property (nonatomic, readonly, copy, nullable) NSError *firstError;
@property (nonatomic, readonly, copy, nullable) NSError *multipleErrorsError;
@property (nonatomic, getter=isValid, readonly) BOOL valid;
@end

NS_ASSUME_NONNULL_END

// MLCValidations *validations = [[MLCValidations alloc] init];
// validations[@"phoneNumber"] = [MLCValidate validatePresenceWitMessage:@"Your phone number is required."];
// validations[@"phoneNumber"] = [MLCValidate validateFormat:@"[0-9]{10,11}" message:@"Invalid phone number."];

// MLCUser.class.validations[@"attr3"] = [MLCValidate validatePresenceWitMessage:@"Your card number is required."];
// MLCUser.class.validations[@"attr3"] = [MLCValidate validateFormate:@"4[0-9]{11}" message:@"Invalid card number."];

// [validations validate:@"phoneNumber" value:@"8008675309"];

// let validations = MLCValidations()
// validations["phoneNumber"] = MLCValidate(presence: "Your phone number is required.")
// validations["phoneNumber"] = MLCValidate(format:"[0-9]{10,11}", message: "Your phone number is required.")
// validations.validate("phoneNumber", value: "8008675309")
