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
    if (![self isValid]) {
        return self.errors[0];
    }

    return nil;
}

- (NSError *)multipleErrorsError {
    if (![self isValid]) {
        if (self.errors.count == 1) {
            return [self firstError];
        }
        
        return [NSError errorWithDomain:MLCValidationErrorDomain
                                   code:MLCValidationMultipleErrorsError
                               userInfo:@{MLCValidationDetailedErrorsKey: self.errors}];
    }

    return nil;
}


- (BOOL)isValid:(out NSError *__autoreleasing *)outError {
    if (outError) {
        *outError = [self firstError];
    }

    return [self isValid];
}

- (BOOL)isValid {
    return [self.errors count] == 0;
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
    if ([expression length]) {
        if (caseSensitive) {
            [validation validateFormat:expression errorMessage:errorMessage];
        }
        else {
            [validation validateCaseInsensitiveFormat:expression errorMessage:errorMessage];
        }
    }

    if (outError) {
        *outError = [validation firstError];
    }

    return [validation isValid];
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

@end
