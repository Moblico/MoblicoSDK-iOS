//
//  MLCValidation.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/14/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

@import Foundation;

FOUNDATION_EXPORT NSString *const MLCValidationErrorDomain;
FOUNDATION_EXPORT NSString *const MLCValidationDetailedErrorsKey;

typedef BOOL(^MLCValidationTest)(id value);

typedef NS_ENUM(NSInteger) {
    MLCValidationUnknownError = -1,
    MLCValidationError = 0,
    MLCValidationMultipleErrorsError = 1
} MLCValidationErrorCode;

@interface MLCValidation : NSObject
@property (nonatomic, readonly) NSArray *errors;

+ (instancetype)validationWithValue:(inout __autoreleasing id *)ioValue;

- (void)validateEquals:(id)otherValue errorMessage:(NSString *)errorMessage;
- (void)validateShouldExist:(BOOL)shouldExists errorMessage:(NSString *)errorMessage;
- (void)validatePredicate:(NSPredicate *)predicate errorMessage:(NSString *)errorMessage;
- (void)validateFormat:(NSString *)format errorMessage:(NSString *)errorMessage;
- (void)validateCaseInsensitiveFormat:(NSString *)format errorMessage:(NSString *)errorMessage;
- (void)validateTest:(MLCValidationTest)test errorMessage:(NSString *)errorMessage;

@property (nonatomic, readonly, copy) NSError *firstError;
@property (nonatomic, readonly, copy) NSError *multipleErrorsError;

@property (nonatomic, getter=isValid, readonly) BOOL valid;
- (BOOL)isValid:(NSError **)firstError;

//+ (BOOL)validateValue:(id *)ioValue matchesExpression:(NSString *)expression required:(BOOL)required caseSensitive:(BOOL)caseSensitive outError:(NSError **)outError errorMessage:(NSString *)errorMessage;
+ (NSError *)errorWithMessage:(NSString *)message;
@end
