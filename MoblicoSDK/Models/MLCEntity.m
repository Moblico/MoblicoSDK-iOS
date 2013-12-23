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

@implementation MLCEntity

- (NSMutableDictionary *)_scalarValues {
    if (!__scalarValues) {
        self._scalarValues = [[NSMutableDictionary alloc] init];
    }
    
    return __scalarValues;
}

+ (NSString *)resourceName {
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByReplacingOccurrencesOfString:@"MLC" withString:@""];
    className = [className lowercaseString];
    return className;
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
    id key =[[self class] uniqueIdentifierKey];
    id value = [self valueForKey:key];
//    NSLog(@"uniqueIdentifier key: %@ value: %@", key, value);
    return [MLCEntity stringFromValue:value];
}

- (void)setSafeValue:(id)value forKey:(NSString *)key {
//    NSLog(@"setSafeValue: %@ forKey: %@", value, key);
	if (!key) [NSException raise:NSInvalidArgumentException format:@"Key must not be nil"];
    NSDictionary *properties = [self properties];
    id type = properties[key];

    [self setValue:value forKey:key type:type];
}

- (void)setValue:(id)value forKey:(NSString *)key {
//    NSLog(@"Set Value[%@] = %@", key, value);
    NSDictionary *properties = [self properties];
    id type = properties[key];
    
    if ([type characterAtIndex:0] == '@') {
        [super setValue:value forKey:key];
        return;
    }
//    NSLog(@"Set Scalar[%@] = %@", key, value);
    if (value) {
        self._scalarValues[key] = value;
    }
    else {
        [self._scalarValues removeObjectForKey:key];
    }

    [super setValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key {
    NSDictionary *properties = [self properties];
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
		value = [value stringValue];
	}
	else if (![value isKindOfClass:[NSString class]]) {
		value = nil;
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
	NSNumber *timeStamp = @(timeInterval *1000.0);
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
	return [value integerValue];
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
    value = [self stringFromValue:value];
    return [NSURL URLWithString:value];
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
    return @{@"id": [self uniqueIdentifierKey],
             @"description": @"details"};
}

+ (instancetype)deserialize:(id)jsonObject {
    if (jsonObject == nil) return nil;
    
    MLCEntity *object = [[[self class] alloc] init];
//	NSDictionary *properties = [object properties];
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
//        NSLog(@"deserialize setValue:%@ forKey:%@ type:%@", value, key, properties[key]);
        [object setSafeValue:value forKey:key];
//        [object setValue:value forKey:key type:properties[key]];
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
    NSDictionary *properties = [self properties];
    
    NSMutableDictionary *serializedObject = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
    
    NSString *uniqueId = [[[self class] resourceName] stringByAppendingString:@"Id"];
    
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
        id value = [self valueForKey:key];
        if (!value || value == [NSNull null] || [key isEqualToString:uniqueId]) return;
        if ([[MLCEntity classFromType:type] isSubclassOfClass:[NSDate class]]) value = [MLCEntity timeStampFromDate:value];
        if ([type characterAtIndex:0] == 'c') value = [MLCEntity boolFromValue:value] ? @"true" : @"false";
        if ([[[self class] ignoredPropertiesDuringSerialization] containsObject:key]) {
            return;
        }
        if ([[self class] renamedPropertiesDuringSerialization][key]) {
            key = [[self class] renamedPropertiesDuringSerialization][key];
        }

        if (key && value) serializedObject[key] = value;
    }];

//    [serializedObject removeObjectForKey:uniqueId];
    
    return [serializedObject copy];
}

- (NSMutableDictionary *)properties {
    return [self propertiesForClass:[self class]];
}

- (NSMutableDictionary *)propertiesForClass:(Class)cls {
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *propertyName = @(property_getName(property));
        if ([propertyName hasPrefix:@"_"]) continue;
        NSString *propertyAttributes = @(property_getAttributes(property));
        
        propertyAttributes = [propertyAttributes componentsSeparatedByString:@","][0];
        propertyAttributes = [propertyAttributes substringFromIndex:1];
        
        results[propertyName] = propertyAttributes;
    }
    free(properties);
    
    if ([cls superclass] != [NSObject class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[cls superclass]]];
    }
	
    return results;
}

+ (Class)classFromType:(NSString *)type {
    if ([type characterAtIndex:0] != @encode(id)[0]) return nil;
    
    NSMutableString *className = [type mutableCopy];
    [className replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, [className length])];
    if ([className hasPrefix:@"@"]) {
        [className deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    return NSClassFromString(className);

}

- (void)setValue:(id)value forKey:(NSString *)key type:(NSString *)type {
//    NSLog(@"START setValue:%@ forKey:%@ type:%@", value, key, type);
    /*
     Code clean up inspired by Mike Ash:
     http://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
     */
    
    NSString *firstCapChar = [[key substringToIndex:1] capitalizedString];
    NSString *capitalizedKey = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];

    NSString *setterName = [NSString stringWithFormat: @"set%@:", capitalizedKey];
    SEL setterSEL = NSSelectorFromString(setterName);
	
	if (![self respondsToSelector:setterSEL]) {
//        NSLog(@"[%@] does not respond to [%@]", [self class], NSStringFromSelector(setterSEL));
        return;
    }

	const unichar typeChar = [type characterAtIndex:0];
	IMP imp = [self methodForSelector:setterSEL];

    
    // Class
	if(typeChar == @encode(Class)[0]) {
		((void (*)(id, SEL, id))imp)(self, setterSEL, value);
//        NSLog(@"CLASS setValue:%@ forKey:%@ type:%@", value, key, type);
        [self setValue:value forKey:key];
        return;
	}
    
	// Object
    if (typeChar == @encode(id)[0]) {
        Class ClassType = [MLCEntity classFromType:type];
        
        if ([ClassType conformsToProtocol:@protocol(MLCEntity)]) {
            value = [ClassType deserialize:value];
        }
        else {
            if ([ClassType isSubclassOfClass:[NSString class]]) value = [MLCEntity stringFromValue:value];
            if ([ClassType isSubclassOfClass:[NSDate class]]) value = [MLCEntity dateFromTimeStampValue:value];
            if ([ClassType isSubclassOfClass:[NSNumber class]]) value = [MLCEntity numberFromDoubleValue:value];
            if ([ClassType isSubclassOfClass:[NSURL class]]) value = [MLCEntity URLFromValue:value];
            if ([ClassType isSubclassOfClass:[NSArray class]]) value = [MLCEntity arrayFromValue:value];
            if ([ClassType isSubclassOfClass:[NSDictionary class]]) value = [MLCEntity dictionaryFromValue:value];
        }
//		((void (*)(id, SEL, id))imp)(self, setterSEL, value);
//        NSLog(@"OBJECT setValue:%@ forKey:%@ type:%@", value, key, type);
        [self setValue:value forKey:key];
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
//    NSLog(@"OTHER setValue:%@ forKey:%@ type:%@", value, key, type);

    [self setValue:value forKey:key];
}

- (NSString *)description {
    objc_property_t descriptionProperty = class_getProperty([self class], "description");
    objc_property_t detailsProperty = class_getProperty([self class], "details");
    if (descriptionProperty && detailsProperty) {
        return [self valueForKey:@"details"];
    }

    NSMutableString *description = [[super description] mutableCopy];

    [description appendString:@" ("];
    NSDictionary *properties = self.properties;

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:properties.count];
    for (NSString *key in properties) {
        id value = [self valueForKey:key];
        [array addObject:[NSString stringWithFormat:@"%@: %@", key, value]];
    }
    [description appendString:[array componentsJoinedByString:@"; "]];
    [description appendString:@")"];

    return [description copy];
}

- (BOOL)validate:(NSError**)outError {
    
	NSDictionary *properties = [self propertiesForClass:[self class]];
	NSMutableArray *errors = [NSMutableArray arrayWithCapacity:[properties count]];
    //	[properties enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id type, BOOL *stop) {
	for (id key in properties) {
		id value = [self valueForKey:key];
		NSError *error = nil;
		if (![self validateValue:&value forKey:key error:&error]) {
			if (!error) {
				error = [[NSError alloc] initWithDomain:@"MLCEntityErrorDomain" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error" }];
			}
			[errors addObject:error];
		}
	}//];
	
	if ([errors count] == 0) return YES;
	
	if (outError != NULL) {
		if ([errors count] == 1) *outError = [errors lastObject];
		else *outError = [[NSError alloc] initWithDomain:@"MLCEntityErrorDomain" code:-1 userInfo:@{ @"MLCEntityValidationDetailedErrorsKey" : errors }];
	}
	
	return NO;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    NSDictionary *properties = [self properties];
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

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
	if (self) {
        NSDictionary *properties = [self properties];
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
        NSDictionary *properties = [self properties];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
            id value = [self valueForKey:key];
            [copyedObject setValue:value forKey:key type:type];
        }];
    }
    return copyedObject;
}

- (BOOL)isEqual:(MLCEntity *)anObject {
    return [self.uniqueIdentifier isEqual:anObject.uniqueIdentifier];
    // If it's an object. Otherwise use a simple comparison like self.personId == anObject.personId
}

- (NSUInteger)hash
{
    return [self.uniqueIdentifier hash]; //Must be a unique unsigned integer
}
@end
