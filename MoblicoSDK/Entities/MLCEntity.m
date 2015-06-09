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
@import ObjectiveC.runtime;
#import "MLCEntity_Private.h"
#import "MLCValidation.h"

@implementation MLCEntity

- (BOOL)validate:(out NSError *__autoreleasing *)outError {

	NSDictionary *properties = [self _properties];
	NSMutableArray * errors = [NSMutableArray arrayWithCapacity:[properties count]];

	for (id key in properties) {
		id value = [self valueForKey:key];
		NSError * error = nil;
		if (![self validateValue:&value forKey:key error:&error]) {
			if (!error) {
				error = [NSError errorWithDomain:MLCValidationErrorDomain code:MLCValidationUnknownError userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error" }];
			}
			[errors addObject:error];
		}
	}

	if ([errors count] == 0) return YES;

	if (outError != NULL) {
		if ([errors count] == 1) *outError = [errors lastObject];
		else *outError = [NSError errorWithDomain:MLCValidationErrorDomain code:MLCValidationMultipleErrorsError userInfo:@{ MLCValidationDetailedErrorsKey : errors }];
	}

	return NO;
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
    NSString *firstCharacter = [[className substringToIndex:1] lowercaseString];

    return [className stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
}

- (NSString *)resourceName {
    return [[self class] resourceName];
}

+ (NSString *)collectionName {
    return [[self resourceName] stringByAppendingString:@"s"];
}

- (NSString *)collectionName {
    return [[self class] collectionName];
}

+ (NSString *)uniqueIdentifierKey {
    return [[self resourceName] stringByAppendingString:@"Id"];
}

- (NSString *)uniqueIdentifier {
    id key = [[self class] uniqueIdentifierKey];
    id value = [self valueForKey:key];

    return [MLCEntity stringFromValue:value];
}

- (void)setSafeValue:(id)value forKey:(NSString *)key {
	if (!key) [NSException raise:NSInvalidArgumentException format:@"Key must not be nil"];
    NSDictionary *properties = [self _properties];
    id type = properties[key];

    [self setValue:value forKey:key type:type];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    NSDictionary *properties = [self _properties];
    id type = properties[key];
    
    if ([type characterAtIndex:0] == '@') {
        [super setValue:value forKey:key];
        return;
    }

    if (value) {
        self._scalarValues[key] = value;
    } else {
        [self._scalarValues removeObjectForKey:key];
    }

    [super setValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key {
    NSDictionary *properties = [self _properties];
    id type = properties[key];
    
    if ([type characterAtIndex:0] == '@') {
        id value = [super valueForKey:key];
//        NSLog(@"Get Value[%@] = %@", key, value);
        return value;
    }

    id value = self._scalarValues[key];
//    NSLog(@"Get Scalar[%@] = %@", key, value);

    return value;
}

+ (NSString *)stringFromValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]] && [value objCType][0] == 'c') {
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

+ (NSDate *)dateFromTimeStampValue:(id)value {
	double timestamp = [self doubleFromValue:value];

	if (timestamp) {
		return [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000.0)];
	}
	
	return nil;
}

+ (NSNumber *)timeStampFromDate:(NSDate *)date {
    if (!date) return nil;
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
	NSNumber *timeStamp = @(timeInterval * 1000.0);

	return @([timeStamp longLongValue]);
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

+ (int)intFromValue:(id)value {
	if (![value respondsToSelector:@selector(integerValue)]) return 0;

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
    return [NSURL URLWithString:[self stringFromValue:value]];
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

+ (instancetype)deserialize:(id)jsonObject {
    if (jsonObject == nil) return nil;
    
    MLCEntity *object = [[[self class] alloc] init];

    [jsonObject enumerateKeysAndObjectsUsingBlock:^(id originalKey, id obj, __unused BOOL *stop) {
        id key = originalKey;
        id value = obj;
        if (value == [NSNull null]) value = nil;
        if ([[self ignoredPropertiesDuringDeserialization] containsObject:key]) {
            return;
        }

        if ([self renamedPropertiesDuringDeserialization][key]) {
            key = [self renamedPropertiesDuringDeserialization][key];
        }

        [object setSafeValue:value forKey:key];

    }];
    
	return object;
}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[[self uniqueIdentifierKey]];
}

+ (NSDictionary *)renamedPropertiesDuringSerialization {
    return @{@"details": @"description"};
}

- (NSDictionary *)serialize {
    NSDictionary *properties = [self _properties];
    
    NSMutableDictionary *serializedObject = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
    
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
		NSLog(@"Key: %@ Type: %@", key, type);
        if ([key isEqualToString:@"properties"] || [key isEqualToString:@"_properties"] || [key isEqualToString:@"debugDescription"] || [key isEqualToString:@"description"]) {
            return;
        }
        if ([[[self class] ignoredPropertiesDuringSerialization] containsObject:key]) {
            return;
        }
        id value = [self valueForKey:key];
        if (!value || value == [NSNull null]) return;

        if ([[MLCEntity classFromType:type] isSubclassOfClass:[NSDate class]]) {
            value = [MLCEntity timeStampFromDate:value];
        } else if ([type characterAtIndex:0] == 'c') {
            value = [MLCEntity boolFromValue:value] ? @"true" : @"false";
        }

        if ([[self class] renamedPropertiesDuringSerialization][key]) {
            key = [[self class] renamedPropertiesDuringSerialization][key];
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

- (NSDictionary *)propertiesForClass:(Class)cls {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    unsigned int outCount, idx;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);

    for (idx = 0; idx < outCount; idx++) {
        objc_property_t property = properties[idx];

        NSString *propertyName = @(property_getName(property));
        if ([propertyName hasPrefix:@"_"]) continue;
        NSString *propertyAttributes = @(property_getAttributes(property));

        propertyAttributes = [[propertyAttributes componentsSeparatedByString:@","] firstObject];
        propertyAttributes = [propertyAttributes substringFromIndex:1];

        results[propertyName] = propertyAttributes;
    }
    free(properties);

    if ([cls superclass] != [NSObject class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[cls superclass]]];
    }

    return [results copy];
}

+ (Class)classFromType:(NSString *)type {
    if ([type characterAtIndex:0] != @encode(id)[0]) return nil;
    
    NSMutableString *className = [type mutableCopy];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wassign-enum"
    [className replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, [className length])];
    #pragma clang diagnostic pop

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

- (void)setValue:(id)value forKey:(NSString *)key type:(NSString *)type {
    /*
     Code clean up inspired by Mike Ash:
     http://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
     */
    
    NSString *firstCapChar = [[key substringToIndex:1] capitalizedString];
    NSString *capitalizedKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCapChar];

    NSString *setterName = [NSString stringWithFormat: @"set%@:", capitalizedKey];
    SEL setterSEL = NSSelectorFromString(setterName);

	if (![self respondsToSelector:setterSEL]) {
        NSLog(@"%@ Not responding to setter: %@", [self class],  setterName);
//        return;
    }

	const unichar typeChar = [type characterAtIndex:0];

    // Class
	if (typeChar == @encode(Class)[0]) {
        [self setValue:value forKey:key];
        return;
	}
    
	// Object
    if (typeChar == @encode(id)[0]) {
        Class ClassType = [MLCEntity classFromType:type];
        id obj = nil;

        if ([ClassType conformsToProtocol:@protocol(MLCEntity)]) {
            obj = [ClassType deserialize:value];
        } else {
            if ([ClassType isSubclassOfClass:[NSString class]]) obj = [MLCEntity stringFromValue:value];
            if ([ClassType isSubclassOfClass:[NSDate class]]) obj = [MLCEntity dateFromTimeStampValue:value];
            if ([ClassType isSubclassOfClass:[NSNumber class]]) obj = [MLCEntity numberFromDoubleValue:value];
            if ([ClassType isSubclassOfClass:[NSURL class]]) obj = [MLCEntity URLFromValue:value];
            if ([ClassType isSubclassOfClass:[NSArray class]]) obj = [MLCEntity arrayFromValue:value];
            if ([ClassType isSubclassOfClass:[NSDictionary class]]) obj = [MLCEntity dictionaryFromValue:value];
        }
        [self setValue:obj forKey:key];
        return;
    }
    
    #define CASE_SEL(ctype, selectorpart) \
        if(typeChar == @encode(ctype)[0]) { \
            [self setValue:@([MLCEntity selectorpart ## FromValue: value ]) forKey:key]; \
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
    NSMutableString *debugDescription = [[super debugDescription] mutableCopy];

    [debugDescription appendString:@" ("];
    NSDictionary *properties = [self _properties];

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
    NSDictionary *properties = [self _properties];
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
        id value = [self valueForKey:key];

        if ([type characterAtIndex:0] == @encode(id)[0]) {
            Class ClassType = [[self class] classFromType:type];

            if (![ClassType conformsToProtocol:@protocol(NSCoding)]) {
                value = nil;
            }
        }
        if (key && value) [coder encodeObject:value forKey:key];
    }];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];

	if (self) {
        NSDictionary *properties = [self _properties];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
            id value = [coder decodeObjectForKey:key];
            [self setValue:value forKey:key type:type];
        }];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
	id copyedObject = [[[self class] allocWithZone:zone] init];

    if (copyedObject) {
        NSDictionary *properties = [self _properties];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
            id value = [self valueForKey:key];
            [copyedObject setValue:value forKey:key type:type];
        }];
    }

    return copyedObject;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    MLCEntity *entity = (MLCEntity *)object;
    return [self.uniqueIdentifier isEqual:entity.uniqueIdentifier];
}

- (NSUInteger)hash {
    return [self.uniqueIdentifier hash]; //Must be a unique unsigned integer
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSLog(@"methodSignatureForSelector: %@", NSStringFromSelector(selector));
    NSMethodSignature *sig = [super methodSignatureForSelector:selector];
    if(!sig)
    {
        NSLog(@"Selector Not Found Here!!!!");
    }

    NSString *sel = NSStringFromSelector(selector);
    if ([sel rangeOfString:@"set"].location == 0) {
        NSLog(@"Dynamic Setters Not Supported.");
//        return sig;
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    } else if ([self _properties][sel]) {
            NSLog(@"Selector is in Properties.");
            return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }

    return sig;
}

//- (id)forwardValueForKey:(NSString *)key type:(NSString *)type {
//    const unichar typeChar = [type characterAtIndex:0];
//
//    id rawValue = self._scalarValues[key];
//    if (!rawValue) {
//        return nil;
//    }
//
//    if (typeChar == @encode(Class)[0] || typeChar == @encode(id)[0]) {
//        return rawValue;
//    }
//
//#define CASE_SEL(ctype, selectorpart) \
//if(typeChar == @encode(ctype)[0]) { \
//return [MLCEntity selectorpart ## FromValue: rawValue ]; \
//}
//
//#define CASE(ctype) CASE_SEL(ctype, ctype)
//
//    CASE(float);
//    CASE(double);
//    CASE(int);
//    CASE(long);
//    CASE(unsigned);
//    CASE(short);
//
//    CASE_SEL(BOOL, bool);
//    CASE_SEL(unsigned int, unsignedInt);
//    CASE_SEL(unsigned long, unsignedLong);
//    CASE_SEL(unsigned long long, unsignedLongLong);
//
//#undef CASE
//#undef CASE_SEL
//    
//    
//}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSLog(@"forwardInvocation: %@", invocation);
//    return;
    NSString *key = NSStringFromSelector([invocation selector]);
    NSString *type = [self _properties][key];

    if (type) {
        NSLog(@"getting %@ (%@)", key, type);
        if ([key hasPrefix:@"set"]) {
            NSLog(@"SETTER!!");
            return;
        }
        id obj = self._undefinedValues[key];
        if (!obj) {
            NSLog(@"Value not set");
            int zero = 0;
            [invocation setReturnValue:&zero];
            return;
        }

        if (invocation.methodSignature.methodReturnType[0] == '@') {
            [invocation setReturnValue:&obj];
        }
        else if ([obj isKindOfClass:[NSValue class]]) {
            NSLog(@"NSValue type: %@ (%@) (%@)", obj, @([obj objCType]), @(invocation.methodSignature.methodReturnType));
            NSValue *currentVal = (NSValue *)obj;
            char *returnValue = calloc(invocation.methodSignature.methodReturnLength, sizeof(char));
            [currentVal getValue:returnValue];
            [invocation setReturnValue:returnValue];
            free(returnValue);
        } else {
            NSLog(@"Not NSValue type");
            [invocation setReturnValue:&obj];
        }
    }
}

//- (void)doesNotRecognizeSelector:(SEL)aSelector {
//    NSString *selectorName = NSStringFromSelector(aSelector);
//    BOOL setter = NO;
//    if ([selectorName hasPrefix:@"set"]) {
////        if (selectorName.length < 3) {
//            [super doesNotRecognizeSelector:aSelector];
//            return;
////        }
//        selectorName = [selectorName substringFromIndex:3];
//        NSString *firstLowerChar = [[selectorName substringToIndex:1] lowercaseString];
//        selectorName = [selectorName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLowerChar];
//    }
//
//}

@end
