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

#import "MLCValidation.h"
#import "MLCEntity.h"
#import "MLCEntity_Private.h"

NSErrorDomain const MLCValidationErrorDomain = @"MLCValidationErrorDomain";
NSErrorUserInfoKey const MLCValidationDetailedErrorsKey = @"MLCValidationDetailedErrorsKey";

@interface MLCValidations ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<MLCValidate *> *> *validations;

@end

@interface MLCValidate ()

@property (nonatomic, copy) MLCValidateTest test;
@property (nonatomic, copy) NSString *message;

@end

@interface MLCValidation ()

@property (nonatomic, readwrite, strong, nullable) MLCValidationError *error;
- (void)addMessage:(NSString *)message;

@end

@implementation MLCValidations

- (NSString *)description {
    NSMutableString *description = [super.description mutableCopy];
    [description appendFormat:@" %@", self.validations];
    return description;
}

- (NSUInteger)count {
    return self.validations.count;
}

- (NSMutableDictionary<NSString *, NSMutableArray<MLCValidate *> *> *)validations {
    if (!_validations) {
        _validations = [NSMutableDictionary<NSString *, NSMutableArray<MLCValidate *> *> dictionary];
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

- (void)appendRule:(MLCValidate *)rule forKey:(NSString *)key {
    NSMutableArray *validationRules = self.validations[key];
    if (validationRules) {
        [validationRules addObject:rule];
    } else {
        self.validations[key] = [@[rule] mutableCopy];
    }
}

- (void)appendRules:(NSArray<MLCValidate *> *)rules forKey:(NSString *)key {
    NSMutableArray *validationRules = self.validations[key];
    if (validationRules) {
        [validationRules addObjectsFromArray:rules];
    } else {
        self.validations[key] = [rules mutableCopy];
    }
}

- (void)setObject:(NSArray<MLCValidate *> *)obj forKeyedSubscript:(NSString *)key {
    self.validations[key] = [obj mutableCopy];
}

- (MLCValidation *)validate:(MLCEntity *)entity key:(NSString *)key value:(inout id _Nullable __autoreleasing *)ioValue {
    MLCValidation *results = [[MLCValidation alloc] init];
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
    NSMutableString *description = [super.description mutableCopy];
    [description appendFormat:@" message: %@", self.message];
    return description;
}

- (instancetype)initWithMessage:(NSString *)message validateTest:(MLCValidateTest)test {
    self = [super init];
    if (self) {
        _test = test;
        _message = message;
    }
    return self;
}

+ (instancetype)validatePresenceWithMessage:(NSString *)message {
    return [[self alloc] initWithMessage:message validateTest:^BOOL(__unused MLCEntity *entity, __unused NSString *key, NSString *value) {
        return value != nil && value.length > 0;
    }];
}

+ (instancetype)validateFormat:(NSString *)format message:(NSString *)message {
    return [self validateFormat:format caseSensitive:NO message:message];
}

+ (instancetype)validateCaseSensitiveFormat:(NSString *)format message:(NSString *)message {
    return [self validateFormat:format caseSensitive:YES message:message];
}

+ (instancetype)validateFormat:(NSString *)format caseSensitive:(BOOL)caseSensitive message:(NSString *)message {
    NSString *predicateFormat = caseSensitive ? @"SELF MATCHES %@" : @"SELF MATCHES[c] %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, format];
    return [self validateWithPredicate:predicate errorMessage:message];
}

+ (instancetype)validateWithPredicate:(NSPredicate *)predicate errorMessage:(NSString *)message {
    return [[self alloc] initWithMessage:message validateTest:^BOOL(__unused MLCEntity *entity, __unused NSString *key, NSString *value) {
        return value.length == 0 || [predicate evaluateWithObject:value];
    }];
}

@end

@implementation MLCValidation

- (void)addMessage:(NSString *)message {
    if (!self.error) {
        self.error = [MLCValidationError errorWithMessage:message];
    } else {
        NSMutableArray *errors = [self.error.errors mutableCopy];
        if (errors.count == 0) {
            errors = [NSMutableArray array];
            [errors addObject:self.error];
        }
        [errors addObject:[MLCValidationError errorWithMessage:message]];
        self.error = [MLCValidationError errorWithErrors:errors];
    }
}

- (BOOL)isValid {
    return self.error == nil;
}

@end

@implementation MLCValidationError

+ (MLCValidationError *)unknownError {
    static dispatch_once_t onceToken;
    static MLCValidationError *error;
    dispatch_once(&onceToken, ^{
        error = [self errorWithDomain:MLCValidationErrorDomain
                                 code:MLCValidationErrorUnknown
                             userInfo:@{NSLocalizedDescriptionKey: @"Unknown error"}];
    });
    return error;
}

- (NSArray<MLCValidationError *> *)errors {
    return self.userInfo[MLCValidationDetailedErrorsKey];
}

+ (instancetype)errorWithErrors:(NSArray<MLCValidationError *> *)errors {
    return [self errorWithDomain:MLCValidationErrorDomain
                            code:MLCValidationErrorMultipleFailures
                        userInfo:@{MLCValidationDetailedErrorsKey: errors}];
}

+ (instancetype)errorWithMessage:(NSString *)message {
    return [self errorWithDomain:MLCValidationErrorDomain
                            code:MLCValidationErrorFailure
                        userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, nil)}];
}

@end
