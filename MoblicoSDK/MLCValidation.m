//
//  MLCValidation.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/14/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCValidation.h"
#import "MLCEntity.h"
#import "MLCEntity_Private.h"

NSString *const MLCValidationErrorDomain = @"MLCValidationErrorDomain";
NSString *const MLCValidationDetailedErrorsKey = @"MLCValidationDetailedErrorsKey";

@interface MLCValidations ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<MLCValidate *> *> *validations;
@end

@interface MLCValidate ()
@property (nonatomic, copy) MLCValidationTest test;
@property (nonatomic, copy) NSString *message;
@end

@interface MLCValidationResults ()
@property (nonatomic, strong) NSMutableArray<NSError *> *errors;
- (void)addMessage:(NSString *)message;
+ (NSError *)errorWithMessage:(NSString *)message;
@end

@implementation MLCValidations

- (NSMutableDictionary<NSString *,NSMutableArray<MLCValidate *> *> *)validations {
    if (!_validations) {
        _validations = [NSMutableDictionary<NSString *,NSMutableArray<MLCValidate *> *> dictionary];
    }
    return _validations;
}

- (NSArray<MLCValidate *> *)objectForKeyedSubscript:(NSString *)key {
    NSArray *rules = self.validations[key];
    if (!rules) {
        return @[];
    }
    return rules;
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    NSMutableArray *rules = self.validations[key];
    if (!rules) {
        rules = [NSMutableArray<MLCValidate *> array];
        self.validations[key] = rules;
    }

    if ([obj isKindOfClass:[NSArray class]]) {
        [rules addObjectsFromArray:obj];
    }
    else if ([obj isKindOfClass:[MLCValidate class]]) {
        [rules addObject:obj];
    }
    else if ([obj isKindOfClass:[NSNull class]]) {
        [rules removeAllObjects];
    }
}

- (MLCValidationResults *)validate:(id<MLCEntityProtocol>)entity key:(NSString *)key value:(inout id  _Nullable __autoreleasing *)ioValue {
    MLCValidationResults *results = [[MLCValidationResults alloc] init];
    for (MLCValidate *rule in self[key]) {
        NSString *value = [MLCEntity stringFromValue:*ioValue];
        if (!rule.test(entity, key, value)) {
            [results addMessage:rule.message];
        }
    }
    return results;
}

@end

@implementation MLCValidate

- (NSString *)description {
    NSMutableString *description = [[super description] mutableCopy];
    [description appendFormat:@" message: %@", self.message];
    return description;
}

- (instancetype)initWithMessage:(NSString *)message validationTest:(MLCValidationTest)test {
    self = [super init];
    if (self) {
        self.test = test;
        self.message = message;
    }
    return self;
}

+ (instancetype)validatePresenceWithMessage:(NSString *)message {
    return [[MLCValidate alloc] initWithMessage:message validationTest:^BOOL(id<MLCEntityProtocol> entity, NSString *key, NSString *value) {
        return value != nil && value.length > 0;
    }];
}

+ (instancetype)validateFormat:(NSString *)format message:(NSString *)message {
    return [MLCValidate validateFormat:format caseSensitive:YES message:message];
}

+ (instancetype)validateFormat:(NSString *)format caseSensitive:(BOOL)caseSensitive message:(NSString *)message {
    NSString *predicateFormat = caseSensitive ? @"SELF MATCHES %@" : @"SELF MATCHES[c] %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, format];
    return [MLCValidate validateWithPredicate:predicate errorMessage:message];
}

+ (instancetype)validateWithPredicate:(NSPredicate *)predicate errorMessage:(NSString *)message {
    return [[MLCValidate alloc] initWithMessage:message validationTest:^BOOL(id<MLCEntityProtocol> entity, NSString *key, NSString *value) {
        if (value == nil || value.length == 0) return YES;
        return [predicate evaluateWithObject:value];
    }];
}

@end

@implementation MLCValidationResults

- (NSMutableArray<NSError *> *)errors {
    if (!_errors) {
        _errors = [NSMutableArray<NSError *> array];
    }
    return _errors;
}

- (void)addMessage:(NSString *)message {
    [self.errors addObject:[MLCValidationResults errorWithMessage:message]];
}

+ (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:MLCValidationErrorDomain
                               code:MLCValidationError
                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, nil)}];
}

- (NSError *)firstError {
    if (self.isValid) return nil;

    return [self.errors firstObject];
}

- (NSError *)multipleErrorsError {
    if (self.isValid) return nil;

    return [NSError errorWithDomain:MLCValidationErrorDomain
                               code:MLCValidationMultipleErrorsError
                           userInfo:@{MLCValidationDetailedErrorsKey: self.errors}];
}

- (BOOL)isValid {
    return self.errors.count == 0;
}

@end

/*
@interface MLCValidation ()

@property (nonatomic, strong) NSMutableArray *mutableErrors;
@property (nonatomic, assign) __autoreleasing id *ioValue;

@end

@implementation MLCValidation

+ (instancetype)validationWithValue:(inout __autoreleasing id *)ioValue {
    MLCValidation *validation = [[self alloc] init];
    validation.ioValue = ioValue;
    return validation;
}

- (NSMutableArray *)mutableErrors {
    if (!_mutableErrors) {
        _mutableErrors = [NSMutableArray array];
    }
    return _mutableErrors;
}

- (NSArray *)errors {
    return [self.mutableErrors copy];
}

- (NSError *)firstError {
    return self.errors.firstObject;
}

- (NSError *)multipleErrorsError {
    if (!self.valid) {
        if (self.errors.count == 1) {
            return self.firstError;
        }
        
        return [NSError errorWithDomain:MLCValidationErrorDomain
                                   code:MLCValidationMultipleErrorsError
                               userInfo:@{MLCValidationDetailedErrorsKey: self.errors}];
    }

    return nil;
}


- (BOOL)isValid:(out NSError *__autoreleasing *)outError {
    if (outError) {
        *outError = self.multipleErrorsError;
    }

    return self.valid;
}

- (BOOL)isValid {
    return self.errors.count == 0;
}

+ (NSError *)errorWithMessage:(NSString *)message {
	return [NSError errorWithDomain:MLCValidationErrorDomain
                               code:MLCValidationError
                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, nil)}];
}

- (void)validateEquals:(id)otherValue errorMessage:(NSString *)errorMessage {
    NSString *value = [MLCEntity stringFromValue:*self.ioValue];

    if (value != nil) {
        NSString *otherStringValue = [MLCEntity stringFromValue:otherValue];
        if (![value isEqualToString:otherStringValue]) {
            [self.mutableErrors addObject:[MLCValidation errorWithMessage:errorMessage]];
        }
    }

}

- (void)validateTest:(MLCValidationTest)test errorMessage:(NSString *)errorMessage {
    NSString *value = *self.ioValue;
    if (value && test && !test(value)) {
        [self.mutableErrors addObject:[MLCValidation errorWithMessage:errorMessage]];
    }
}

- (void)validateFormat:(NSString *)format errorMessage:(NSString *)errorMessage {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format];
    [self validatePredicate:predicate errorMessage:errorMessage];
}

- (void)validateShouldExist:(BOOL)shouldExists errorMessage:(NSString *)errorMessage {
    NSString *value = [MLCEntity stringFromValue:*self.ioValue];
    if (shouldExists == (value.length == 0)) {
        [self.mutableErrors addObject:[MLCValidation errorWithMessage:errorMessage]];
    }
}

- (void)validatePredicate:(NSPredicate *)predicate errorMessage:(NSString *)errorMessage {
    NSString *value = [MLCEntity stringFromValue:*self.ioValue];
    if (value.length && ![predicate evaluateWithObject:value]) {
        [self.mutableErrors addObject:[MLCValidation errorWithMessage:errorMessage]];
    }
}

- (void)validateCaseInsensitiveFormat:(NSString *)format errorMessage:(NSString *)errorMessage {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", format];
    [self validatePredicate:predicate errorMessage:errorMessage];
}

+ (BOOL)validateValue:(inout __autoreleasing id *)ioValue matchesExpression:(NSString *)expression required:(BOOL)required caseSensitive:(BOOL)caseSensitive outError:(out NSError *__autoreleasing *)outError errorMessage:(NSString *)errorMessage {
    MLCValidation *validation = [MLCValidation validationWithValue:ioValue];

    if (required) {
        [validation validateShouldExist:YES errorMessage:errorMessage];
    }
    if (expression.length) {
        if (caseSensitive) {
            [validation validateFormat:expression errorMessage:errorMessage];
        }
        else {
            [validation validateCaseInsensitiveFormat:expression errorMessage:errorMessage];
        }
    }

    if (outError) {
        *outError = validation.multipleErrorsError;
    }

    return validation.valid;
}


//- (void)validateValue:(inout __autoreleasing id *)ioValue withRules:(NSDictionary *)rules {
//    [rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        if ([key isEqualToString:MLCValidationRulePresenceKey]) {
//            BOOL mustBePresent = [MLCEntity boolFromValue:obj];
//            if ((*ioValue != nil) != mustBePresent) {
//                self.mutableErrors
//            }
//        }
//    }];
//}

//- (NSError *)joinedError;
*/

/*

+ (BOOL)ioValue:(inout __autoreleasing id *)ioValue matchesExpression:(NSString *)expression outError:(out NSError *__autoreleasing *)outError errorMessage:(NSString *)errorMessage {
    return [self ioValue:ioValue matchesExpression:expression required:NO caseSensitive:NO outError:outError errorMessage:errorMessage];
}

+ (BOOL)ioValue:(inout __autoreleasing id *)ioValue matchesExpression:(NSString *)expression required:(BOOL)required outError:(out NSError *__autoreleasing *)outError errorMessage:(NSString *)errorMessage {
    return [self ioValue:ioValue matchesExpression:expression required:required caseSensitive:NO outError:outError errorMessage:errorMessage];
}

+ (BOOL)ioValue:(inout __autoreleasing id *)ioValue matchesExpression:(NSString *)expression caseSensitive:(BOOL)caseSensitive outError:(out NSError *__autoreleasing *)outError errorMessage:(NSString *)errorMessage {
    return [self ioValue:ioValue matchesExpression:expression required:NO caseSensitive:caseSensitive outError:outError errorMessage:errorMessage];
}

+ (BOOL)ioValue:(inout __autoreleasing id *)ioValue matchesExpression:(NSString *)expression required:(BOOL)required caseSensitive:(BOOL)caseSensitive outError:(out NSError *__autoreleasing *)outError errorMessage:(NSString *)errorMessage {
    NSString *value = [MLCEntity stringFromValue:*ioValue];

	if ([value length] == 0 && !required) {
		return YES;
	}
    NSMutableArray *a;
    [a containsObject:nil];
	NSPredicate *predicate;
    if (caseSensitive) {
        predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", expression];
    }

	if (value && [predicate evaluateWithObject:value]) {
		return YES;
	}

	if (outError) {
		*outError = [self validationErrorWithMessage:errorMessage];
	}

	return NO;
} */

//@end
