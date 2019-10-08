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

#import "MLCEntity.h"
#import <objc/runtime.h>
#import "MLCEntity_Private.h"
#import "MLCValidation.h"

static void *MLCEntityKeyValueChangedContext = &MLCEntityKeyValueChangedContext;
//#define MLCEntityLog(fmt, ...) MLCInfoLog(fmt, ##__VA_ARGS__);
#define MLCEntityLog(...)

@implementation MLCEntity

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (MLCValidations *)validations {
    MLCValidations *validations = objc_getAssociatedObject(self, @selector(validations));
    if (!validations) {
        validations = [[MLCValidations alloc] init];
        objc_setAssociatedObject(self, @selector(validations), validations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return validations;
}

- (BOOL)validate:(out NSError **)outError {
    NSDictionary *properties = self._properties;
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:properties.count];

    for (id key in properties) {
        id value = [self valueForKey:key];
        MLCValidationError *error = nil;
        if (![self validateValue:&value forKey:key error:&error]) {
            if (!error) {
                error = MLCValidationError.unknownError;
            }

            if ([error isKindOfClass:[MLCValidationError class]] && error.errors.count > 0) {
                [errors addObjectsFromArray:error.errors];
            } else {
                [errors addObject:error];
            }
        }
    }

    if (errors.count == 0) {
        return YES;
    }

    if (outError != NULL) {
        if (errors.count == 1) {
            *outError = errors.firstObject;
        } else {
            *outError = [MLCValidationError errorWithErrors:errors];
        }
    }

    return NO;
}

- (BOOL)validateValue:(inout id _Nullable *_Nonnull)ioValue forKey:(NSString *)inKey error:(out NSError **)outError {

    if (![super validateValue:ioValue forKey:inKey error:outError]) {
        return NO;
    }
    if ([self class].validations == nil) {
        return YES;
    }

    MLCValidation *results = [[self class].validations validate:self key:inKey value:ioValue];
    if (outError) {
        *outError = results.error;
    }
    return results.isValid;
}

- (NSMutableDictionary *)_scalarValues {
    if (!__scalarValues) {
        self._scalarValues = [[NSMutableDictionary alloc] init];
    }

    return __scalarValues;
}

- (NSMutableDictionary *)_undefinedValues {
    if (!__undefinedValues) {
        self._undefinedValues = [[NSMutableDictionary alloc] init];
    }

    return __undefinedValues;
}

+ (NSString *)resourceName {
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByReplacingOccurrencesOfString:@"MLC" withString:@""];
    NSString *firstCharacter = [className substringToIndex:1].lowercaseString;

    return [className stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
}

+ (NSString *)collectionName {
    return [[self resourceName] stringByAppendingString:@"s"];
}

+ (NSString *)uniqueIdentifierKey {
    return [[self resourceName] stringByAppendingString:@"Id"];
}

- (NSString *)uniqueIdentifier {
    id key = [[self class] uniqueIdentifierKey];
    id value = [self valueForKey:key];

    return [[self class] stringFromValue:value];
}

- (void)setSafeValue:(id)value forKey:(NSString *)key {
    if (!key) [NSException raise:NSInvalidArgumentException format:@"Key must not be nil"];
    NSDictionary *properties = self._properties;
    id type = properties[key];

    [self setValue:value forKey:key type:type];
}

- (instancetype)init {
    self = [super init];

    if (self) {
        NSDictionary *properties = [self propertiesForClass:[self class]];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {

            if ([type characterAtIndex:0] != '@') {
                @try {
                    [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:MLCEntityKeyValueChangedContext];
                } @catch (NSException *__unused exception) {}
            }
        }];
    }
    return self;
}

- (void)dealloc {
    NSDictionary *properties = [self propertiesForClass:[self class]];
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {

        if ([type characterAtIndex:0] != '@') {
            @try {
                [self removeObserver:self forKeyPath:key];
            }
            @catch (NSException *exception) {}
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object != self || context != MLCEntityKeyValueChangedContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    id value = [super valueForKey:keyPath];
    MLCEntityLog(@"Changed value at key path: %@ change: %@ value: %@", keyPath, change, value);
    NSDictionary *properties = self._properties;
    id type = properties[keyPath];
    if (type && [type characterAtIndex:0] != '@') {
        if (value) {
            MLCEntityLog(@"set _scalarValues[%@] = %@", keyPath, value);
            self._scalarValues[keyPath] = value;
        } else {
            MLCEntityLog(@"remove _scalarValues[%@] (%@)", keyPath, value);
            [self._scalarValues removeObjectForKey:keyPath];
        }
        return;
    }

}

- (void)setValue:(id)value forKey:(NSString *)key {
    MLCEntityLog(@"setValue[%@] = %@", key, value);
    NSDictionary *properties = self._properties;
    id type = properties[key];

    if ([type characterAtIndex:0] == '@') {
        [super setValue:value forKey:key];
        return;
    }

    if (value) {
        MLCEntityLog(@"set _scalarValues[%@] = %@", key, value);
        self._scalarValues[key] = value;
    } else {
        MLCEntityLog(@"remove _scalarValues[%@] (%@)", key, value);
        [self._scalarValues removeObjectForKey:key];
    }

    [super setValue:value forKey:key];
}

- (void)setNilValueForKey:(NSString *)key {
    MLCEntityLog(@"setNilValueForKey: %@", key);
    [super setValue:@(0) forKey:key];
}

- (id)valueForKey:(NSString *)key {
    NSDictionary *properties = self._properties;
    id type = properties[key];

    if ([type characterAtIndex:0] == '@') {
        id value = [super valueForKey:key];
        MLCEntityLog(@"Get Value[%@] = %@", key, value);
        if (value) {
            return value;
        }
        return self._undefinedValues[key];
    }

    id value = self._scalarValues[key];
    if (value == nil) {
        return [super valueForKey:key];
    }
    MLCEntityLog(@"get _scalarValues[%@] (%@)", key, value);

    return value;
}

+ (NSString *)nilIfEmptyStringFromValue:(id)value {
    NSString *string = [self stringFromValue:value];
    if (string.length == 0) {
        return nil;
    }
    return string;
}

+ (NSString *)stringFromValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]
            && (

            [value objCType][0] == @encode(BOOL)[0] ||
                    [value objCType][0] == @encode(bool)[0] ||
                    [value objCType][0] == 'c'
    )
            ) {
        return [value boolValue] ? @"true" : @"false";
    }

    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }

    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }

    return value;
}

+ (NSDate *)dateFromTimestampValue:(id)value {
    if ([value isKindOfClass:[NSDate class]]) {
        return value;
    }

    NSString *stringValue = [self stringFromValue:value];
    if (stringValue.length == 0) {
        return nil;
    }
    NSDecimalNumber *milliseconds = [NSDecimalNumber decimalNumberWithString:stringValue];
    if ([milliseconds isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return nil;
    }
    NSDecimalNumber *timestamp = [milliseconds decimalNumberByMultiplyingByPowerOf10:-3];

    if (timestamp.boolValue) {
        return [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
    }

    return nil;
}

+ (NSNumber *)timestampFromDate:(NSDate *)date {
    if (!date) return nil;
    return [[NSDecimalNumber decimalNumberWithDecimal:@(date.timeIntervalSince1970).decimalValue] decimalNumberByMultiplyingByPowerOf10:3];
}

+ (BOOL)boolFromValue:(id)value {
    if (![value respondsToSelector:@selector(boolValue)]) return NO;

    return [value boolValue];
}

+ (float)floatFromValue:(id)value {
    if (![value respondsToSelector:@selector(floatValue)]) return 0.0;

    return [value floatValue];
}

+ (double)doubleFromValue:(id)value {
    if (![value respondsToSelector:@selector(doubleValue)]) return 0.0;

    return [value doubleValue];
}

+ (NSInteger)integerFromValue:(id)value {
    if (![value respondsToSelector:@selector(integerValue)]) return 0;

    return [value integerValue];
}

+ (NSUInteger)unsignedIntegerFromValue:(id)value {
    if (![value respondsToSelector:@selector(unsignedIntegerValue)]) return 0;

    return [value unsignedIntegerValue];
}

+ (int)intFromValue:(id)value {
    if (![value respondsToSelector:@selector(intValue)]) return 0;

    return [value intValue];
}

+ (unsigned int)unsignedIntFromValue:(id)value {
    if (![value respondsToSelector:@selector(unsignedIntValue)]) return 0;

    return [value unsignedIntValue];
}

+ (unsigned long)unsignedLongFromValue:(id)value {
    if (![value respondsToSelector:@selector(unsignedLongValue)]) return 0;

    return [value unsignedLongValue];
}

+ (unsigned long long)unsignedLongLongFromValue:(id)value {
    if (![value respondsToSelector:@selector(unsignedLongLongValue)]) return 0;

    return [value unsignedLongLongValue];
}

+ (long)longFromValue:(id)value {
    if (![value respondsToSelector:@selector(longValue)]) return 0;

    return [value longValue];
}

+ (unsigned)unsignedFromValue:(id)value {
    if (![value respondsToSelector:@selector(unsignedIntValue)]) return 0;

    return [value unsignedIntValue];
}

+ (short)shortFromValue:(id)value {
    if (![value respondsToSelector:@selector(shortValue)]) return 0;

    return [value shortValue];
}

+ (NSNumber *)numberFromDoubleValue:(id)value {
    if (![value respondsToSelector:@selector(doubleValue)]) return nil;

    return @([value doubleValue]);
}

+ (NSNumber *)numberFromIntegerValue:(id)value {
    if (![value respondsToSelector:@selector(integerValue)]) return nil;

    return @([value integerValue]);
}

+ (NSNumber *)numberFromBoolValue:(id)value {
    if (![value respondsToSelector:@selector(boolValue)]) return nil;

    return @([value boolValue]);
}

+ (NSURL *)URLFromValue:(id)value {
    NSString *string = [self stringFromValue:value];
    if (string.length <= 0) {
        return nil;
    }

    NSURLComponents *components = [NSURLComponents componentsWithString:string];
    if (components.scheme == nil) {
        components.scheme = @"http";
    }
    return components.URL;
}

+ (NSArray *)arrayFromValue:(id)value {
    if (value == nil) return nil;
    if ([value isKindOfClass:[NSArray class]]) return value;

    return @[value];
}

+ (NSDictionary *)dictionaryFromValue:(id)value {
    if ([value isKindOfClass:[NSDictionary class]]) return value;

    return nil;
}

+ (NSArray *)ignoredPropertiesDuringDeserialization {
    return nil;
}

+ (NSDictionary *)renamedPropertiesDuringDeserialization {
    return @{@"id": [self uniqueIdentifierKey], @"description": @"details"};
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    if (jsonObject == nil) return nil;

    self = [self init];
    if (self) {
        NSArray *ignore = [[self class] ignoredPropertiesDuringDeserialization];
        NSDictionary *rename = [[self class] renamedPropertiesDuringDeserialization];

        [jsonObject enumerateKeysAndObjectsUsingBlock:^(id originalKey, id obj, __unused BOOL *stop) {
            id key = originalKey;
            id value = obj;
            if (value == [NSNull null]) value = nil;
            if ([ignore containsObject:key]) {
                return;
            }

            if (rename[key]) {
                key = rename[key];
            }

            [self setSafeValue:value forKey:key];
        }];
    }

    return self;
}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[[self uniqueIdentifierKey]];
}

+ (NSDictionary *)renamedPropertiesDuringSerialization {
    return @{@"details": @"description"};
}

+ (BOOL)entity:(MLCEntity *)entity equals:(MLCEntity *)otherEntity {
    if (![entity isEquivalent:otherEntity]) {
        return NO;
    }

    NSDictionary *properties = entity._properties;

    NSArray *ignore = [self ignoredPropertiesDuringSerialization];

    for (NSString *key in properties) {
        if ([key isEqualToString:@"properties"] || [key isEqualToString:@"debugDescription"] || [key isEqualToString:@"description"] || [key hasPrefix:@"mlc_"] || [key hasPrefix:@"_"]) {
            continue;
        }
        if ([ignore containsObject:key]) {
            continue;
        }
        id entityValue = [entity valueForKey:key];
        id otherValue = [otherEntity valueForKey:key];
        if (!entityValue && !otherValue) {
            continue;
        }
        if (![entityValue isEqual:otherValue]) {
            return NO;
        }
    }

    return YES;
}

+ (NSDictionary *)serialize:(MLCEntity *)entityObject {
    if (![entityObject isKindOfClass:[MLCEntity class]]) {
        return nil;
    }

    MLCEntity *entity = entityObject;

    NSDictionary *properties = entity._properties;

    NSMutableDictionary *serializedObject = [NSMutableDictionary dictionaryWithCapacity:properties.count];

    NSArray *ignore = [self ignoredPropertiesDuringSerialization];
    NSDictionary *rename = [self renamedPropertiesDuringSerialization];

    [properties enumerateKeysAndObjectsUsingBlock:^(id name, id type, __unused BOOL *stop) {
        id key = name;
        MLCEntityLog(@"Key: %@ Type: %@", key, type);
        if ([key isEqualToString:@"properties"] || [key isEqualToString:@"debugDescription"] || [key isEqualToString:@"description"] || [key hasPrefix:@"mlc_"] || [key hasPrefix:@"_"]) {
            return;
        }
        if ([ignore containsObject:key]) {
            return;
        }
        id value = [entity valueForKey:key];
        if (!value || value == [NSNull null]) return;

        Class ValueClass = [self classFromType:type];
        if ([ValueClass isSubclassOfClass:[MLCEntity class]]) {
            value = [ValueClass serialize:value];
        } else if ([ValueClass isSubclassOfClass:[NSDate class]]) {
            value = [self timestampFromDate:value];
        } else if ([ValueClass isSubclassOfClass:[NSURL class]]) {
            NSURL *url = value;
            value = url.absoluteString;
        } else if ([type characterAtIndex:0] == 'c' || [type characterAtIndex:0] == @encode(BOOL)[0] || [type characterAtIndex:0] == @encode(bool)[0]) {
            MLCEntityLog(@"it's a bool! %@", value);
            value = [self boolFromValue:value] ? @"true" : @"false";
        }

        if (rename[key]) {
            key = rename[key];
        }

        if (key && value) serializedObject[key] = value;
    }];

    return [serializedObject copy];
}

- (NSDictionary *)_properties {
    if (__properties) return __properties;

    __properties = [self propertiesForClass:[self class]];

    return __properties;
}

- (NSDictionary *)propertiesForClass:(Class)classType {
    if (classType == [MLCEntity class]) {
        return @{};
    }

    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    unsigned int outCount, idx;
    objc_property_t *properties = class_copyPropertyList(classType, &outCount);

    for (idx = 0; idx < outCount; idx++) {
        objc_property_t property = properties[idx];

        NSString *propertyName = @(property_getName(property));
        if ([propertyName hasPrefix:@"_"]) continue;
        char *ivar = property_copyAttributeValue(property, "V");
        if (ivar) {
            NSString *ivarName = @(ivar);
            free(ivar);
            if (![ivarName isEqualToString:propertyName] && ![ivarName isEqualToString:[@"_" stringByAppendingString:propertyName]]) continue;
        }

        NSString *propertyAttributes = @(property_getAttributes(property));
        MLCEntityLog(@"propertyName: %@ propertyAttributes: %@", propertyName, propertyAttributes);
        propertyAttributes = [propertyAttributes componentsSeparatedByString:@","].firstObject;
        propertyAttributes = [propertyAttributes substringFromIndex:1];

        results[propertyName] = propertyAttributes;
    }
    free(properties);

    if ([classType superclass] != [MLCEntity class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[classType superclass]]];
    }

    return [results copy];
}

+ (Class)classFromType:(NSString *)type {
    if ([type characterAtIndex:0] != @encode(id)[0]) return nil;

    NSMutableString *className = [type mutableCopy];
    [className replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, className.length)];

    if ([className hasPrefix:@"@"]) {
        [className deleteCharactersInRange:NSMakeRange(0, 1)];
    }

    return NSClassFromString(className);

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if (value) {
        self._undefinedValues[key] = value;
    } else {
        [self._undefinedValues removeObjectForKey:key];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return self._undefinedValues[key];
}

- (void)setValue:(id)newValue forKey:(NSString *)key type:(NSString *)type {
    id value = newValue;
    /*
     Code clean up inspired by Mike Ash:
     http://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
     */

    const unichar typeChar = [type characterAtIndex:0];

    // Class
    if (typeChar == @encode(Class)[0]) {
        [self setValue:value forKey:key];
        return;
    }

    // Object
    if (typeChar == @encode(id)[0]) {
        Class ClassType = [[self class] classFromType:type];
        id obj = nil;

        if ([value isKindOfClass:ClassType]) {
            obj = value;
        } else if ([ClassType isSubclassOfClass:[MLCEntity class]]) {
            obj = [(__kindof MLCEntity *)[ClassType alloc] initWithJSONObject:value];
        } else {
            if ([ClassType isSubclassOfClass:[NSString class]]) obj = [[self class] stringFromValue:value];
            if ([ClassType isSubclassOfClass:[NSDate class]]) obj = [[self class] dateFromTimestampValue:value];
            if ([ClassType isSubclassOfClass:[NSNumber class]]) obj = [[self class] numberFromDoubleValue:value];
            if ([ClassType isSubclassOfClass:[NSURL class]]) obj = [[self class] URLFromValue:value];
            if ([ClassType isSubclassOfClass:[NSArray class]]) obj = [[self class] arrayFromValue:value];
            if ([ClassType isSubclassOfClass:[NSDictionary class]]) obj = [[self class] dictionaryFromValue:value];
        }
        [self setValue:obj forKey:key];
        return;
    }

#define CASE_SEL(ctype, selectorPart) \
if(typeChar == @encode(ctype)[0]) { \
if ([value isKindOfClass:[NSString class]]) { \
if (((NSString *)value).length == 0) return; \
NSNumberFormatter *f = [[NSNumberFormatter alloc] init]; \
f.numberStyle = NSNumberFormatterDecimalStyle; \
NSNumber *number = [f numberFromString:value]; \
if(number != nil)value=number;\
}\
NSNumber *number = @([[self class] selectorPart ## FromValue: value ]); \
[self setValue:number forKey:key]; \
return; \
}

#define CASE(ctype) CASE_SEL(ctype, ctype)

    CASE(float);
    CASE(double);
    CASE(int);
    CASE(long);
    CASE(unsigned);
    CASE(short);

    CASE_SEL(BOOL, bool);
    CASE_SEL(unsigned int, unsignedInt);
    CASE_SEL(unsigned long, unsignedLong);
    CASE_SEL(unsigned long long, unsignedLongLong);

#undef CASE
#undef CASE_SEL

    [self setValue:value forKey:key];
}

- (NSString *)debugDescription {
    NSMutableString *debugDescription = [super.debugDescription mutableCopy];

    [debugDescription appendString:@" ("];
    NSDictionary *properties = self._properties;

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:properties.count];

    for (NSString *key in properties) {
        if ([key isEqualToString:@"description"] || [key isEqualToString:@"debugDescription"]) continue;
        id value = [self valueForKey:key];
        [array addObject:[NSString stringWithFormat:@"%@: %@", key, value]];
    }
    [debugDescription appendString:[array componentsJoinedByString:@"; "]];
    [debugDescription appendString:@")"];

    return [debugDescription copy];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    NSDictionary *properties = self._properties;
    for (NSString *key in properties) {
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];

    if (self) {
        NSDictionary *properties = self._properties;
        for (NSString *key in properties) {
            id value = [coder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];

    if (copiedObject) {
        NSDictionary *properties = self._properties;
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
            id value = [self valueForKey:key];
            [copiedObject setValue:value forKey:key type:type];
        }];
    }

    return copiedObject;
}

- (BOOL)isEqual:(id)object {
    return [[self class] entity:self equals:object];
}

- (BOOL)isEquivalent:(id)object {
    if (![self isKindOfClass:[object class]]) {
        return NO;
    }

    MLCEntity *otherEntity = (MLCEntity *)object;
    return [self.uniqueIdentifier isEqual:otherEntity.uniqueIdentifier];
}

- (NSUInteger)hash {
    NSDictionary *this = [[self class] serialize:self];
    return this.description.hash;
}

- (NSString *)setterToGetter:(NSString *)selector {
    if ([selector hasPrefix:@"set"] && [selector hasSuffix:@":"]) {
        NSString *prop = [selector substringWithRange:NSMakeRange(3, selector.length - 4)];
        NSString *firstCharacter = [prop substringToIndex:1].lowercaseString;
        return [prop stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
    }
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        MLCEntityLog(@"Selector Not Found Here!!!! sel: %@", NSStringFromSelector(selector));
    }

    NSString *selectorString = NSStringFromSelector(selector);
    NSString *setter = [self setterToGetter:selectorString];
    NSString *type = self._properties[setter ?: selectorString];
    if (type) {
        MLCEntityLog(@"Selector is in Properties.");
        NSString *format = setter ? @"v@:%@" : @"%@@:";
        NSString *types = [NSString stringWithFormat:format, type];
        MLCEntityLog(@"ObjCTypes: %@", types);
        return [NSMethodSignature signatureWithObjCTypes:[types cStringUsingEncoding:NSUTF8StringEncoding]];
    }

    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    MLCEntityLog(@"forwardInvocation: %@", invocation);
    NSString *key = NSStringFromSelector(invocation.selector);
    MLCEntityLog(@"forwardInvocation: %@ selector: %@", invocation, key);
    NSString *setter = [self setterToGetter:key] ?: key;
    NSString *type = self._properties[setter];

    if (type) {
        MLCEntityLog(@"getting %@ (%@)", key, type);
        if ([key hasPrefix:@"set"]) {
            MLCEntityLog(@"SETTER!!");
            if ([type isEqualToString:@"@"]) {
                id obj = nil;
                [invocation getArgument:&obj atIndex:2];
                self._undefinedValues[setter] = obj;
            } else {
                const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:2];
                NSNumber *value = nil;

#define CASE_SEL(ctype, selectorPart) \
if(argumentType[0] == @encode(ctype)[0]) {\
MLCEntityLog(@"Type: %s", @encode(ctype)); \
ctype val = 0; \
[invocation getArgument:&val atIndex:2]; \
value = [NSNumber numberWith ## selectorPart:val];}

                CASE_SEL(char, Char);
                CASE_SEL(unsigned char, UnsignedChar);
                CASE_SEL(short, Short);
                CASE_SEL(unsigned short, UnsignedShort);
                CASE_SEL(int, Int);
                CASE_SEL(unsigned int, UnsignedInt);
                CASE_SEL(long, Long);
                CASE_SEL(unsigned long, UnsignedLong);
                CASE_SEL(long long, LongLong);
                CASE_SEL(unsigned long long, UnsignedLongLong);
                CASE_SEL(float, Float);
                CASE_SEL(double, Double);
#undef CASE_SEL
                [self setValue:value forKey:setter type:type];
            }
            return;
        }
        id obj = self._undefinedValues[key];
        if (!obj) {
            obj = self._scalarValues[key];
            if (!obj) {
                MLCEntityLog(@"Value not set");
                int zero = 0;
                [invocation setReturnValue:&zero];
                return;
            }
        }

        if (invocation.methodSignature.methodReturnType[0] == '@') {
            [invocation setReturnValue:&obj];
        } else if ([obj isKindOfClass:[NSValue class]]) {
            MLCEntityLog(@"NSValue type: %@ (%@) (%@)", obj, @([obj objCType]), @(invocation.methodSignature.methodReturnType));
            NSValue *currentVal = (NSValue *)obj;
            char *returnValue = calloc(invocation.methodSignature.methodReturnLength, sizeof(char));
            [currentVal getValue:returnValue];
            [invocation setReturnValue:returnValue];
            free(returnValue);
        } else {
            MLCEntityLog(@"Not NSValue type");
            [invocation setReturnValue:&obj];
        }
    }
}

@end

