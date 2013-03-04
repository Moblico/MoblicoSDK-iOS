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

+ (NSString *)collectionName {
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByReplacingOccurrencesOfString:@"MLC" withString:@""];
    className = [className lowercaseString];
    return [className stringByAppendingString:@"s"];
}

- (NSString *)collectionName {
    return [[self class] collectionName];
}

+ (NSString *)uniqueIdentifierKey {
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByReplacingOccurrencesOfString:@"MLC" withString:@""];
    className = [className lowercaseString];
    return [className stringByAppendingString:@"Id"];
}

- (NSString *)uniqueIdentifier {
    id value = [self valueForKey:[[self class] uniqueIdentifierKey]];
    return [MLCEntity stringFromValue:value];
}

- (void)setSafeValue:(id)value forKey:(NSString *)key {
	if (!key) [NSException raise:NSInvalidArgumentException format:@"Key must not be nil"];
	
	NSString *capitalizedKey = [[[key substringToIndex:1] uppercaseString] stringByAppendingString:[key substringFromIndex:1]];
	NSString *setterString = [NSString stringWithFormat:@"set%@:", capitalizedKey];
	SEL setter = NSSelectorFromString(setterString);
	if ([self respondsToSelector:setter]) {
		[self setValue:value forKey:key];
	}
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

+ (id)deserialize:(id)jsonObject {
    if (jsonObject == nil) return nil;
    
    id object = [[[self class] alloc] init];
	NSDictionary *properties = [object properties];
    [jsonObject enumerateKeysAndObjectsUsingBlock:^(id originalKey, id obj, BOOL *stop) {
        id key = originalKey;
        id value = obj;
        if ([value isEqual:[NSNull null]]) value = nil;
		if ([key isEqualToString:@"id"]) {
            NSString *className = NSStringFromClass([self class]);
            className = [className stringByReplacingOccurrencesOfString:@"MLC" withString:@""];
            className = [className lowercaseString];
            key = [className stringByAppendingString:@"Id"];
        }

        [object setValue:value forKey:key type:properties[key]];
    }];
    
	return object;
}

- (id)serialize {
    NSDictionary *properties = [self properties];
    NSMutableDictionary *serializedObject = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
    
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByReplacingOccurrencesOfString:@"MLC" withString:@""];
    className = [className lowercaseString];
    NSString *uniqueId = [className stringByAppendingString:@"Id"];

    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *type = properties[key];
        id value = [self valueForKey:key];
        if ([type isEqualToString:@"@\"NSDate\""]) value = [MLCEntity timeStampFromDate:value];
        if ([type characterAtIndex:0] == 'c') value = [MLCEntity boolFromValue:value] ? @"true" : @"false";
        if (key && value) serializedObject[key] = value;
    }];

    [serializedObject removeObjectForKey:uniqueId];
    
    return serializedObject;
}

- (NSMutableDictionary *)properties {
    return [self propertiesForClass:[self class]];
}

- (NSMutableDictionary *)propertiesForClass:(Class)klass {
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *pname = @(property_getName(property));
        NSString *pattrs = @(property_getAttributes(property));
        
        pattrs = [pattrs componentsSeparatedByString:@","][0];
        pattrs = [pattrs substringFromIndex:1];
        
        results[pname] = pattrs;
    }
    free(properties);
    
    if ([klass superclass] != [NSObject class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[klass superclass]]];
    }
	
    return results;
}

- (void)setValue:(id)originalValue forKey:(NSString *)key type:(NSString *)type {
    NSString *firstLetter = [[key substringWithRange:NSMakeRange(0,1)] uppercaseString];
    NSString *capitolized = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstLetter];
    NSString *setter = [NSString stringWithFormat:@"set%@:", capitolized];
    
    NSMethodSignature *signature = nil;
    NSInvocation *invocation = nil;
    
    @try {
        signature =  [self methodSignatureForSelector:NSSelectorFromString(setter)];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
    }
    @catch (NSException *exception) {
        return;
    }
    
    [invocation setSelector:NSSelectorFromString(setter)];
    [invocation setTarget:self];
    
    switch ([type characterAtIndex:0]) {
        case '@':   // object
        {
            id value = originalValue;
            if ([type isEqualToString:@"@\"NSString\""]) value = [MLCEntity stringFromValue:value];
            if ([type isEqualToString:@"@\"NSDate\""]) value = [MLCEntity dateFromTimeStampValue:value];
            if ([type isEqualToString:@"@\"NSNumber\""]) value = [MLCEntity numberFromDoubleValue:value];
            if ([type isEqualToString:@"@\"NSURL\""]) value = [MLCEntity URLFromValue:value];
            if ([type isEqualToString:@"@\"NSArray\""]) value = [MLCEntity arrayFromValue:value];
            if ([type isEqualToString:@"@\"NSDictionary\""]) value = [MLCEntity dictionaryFromValue:value];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'c':   // bool
        {
            BOOL value = [MLCEntity boolFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'f':   // float
        {
            float value = [MLCEntity floatFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'd':   // double
        {
            double value = [MLCEntity doubleFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'i':   // int
        {
            int value = [MLCEntity intFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'L':   // unsigned long
        {
            unsigned long value = [MLCEntity unsignedLongFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'Q':   // unsigned long long
        {
            unsigned long long value = [MLCEntity unsignedLongLongFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'l':   // long
        {
            long value = [MLCEntity longFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 'I':   // unsigned
        {
            unsigned value = [MLCEntity unsignedFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
            break;
        }
        case 's':   // short
        {
            short value = [MLCEntity shortFromValue:originalValue];
            [invocation setArgument:&value atIndex:2];
            [invocation invoke];
        }
            break;
            
        default:
            break;
    }
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
				error = [[NSError alloc] initWithDomain:@"com.moblico.Core.EntityError" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error" }];
			}
			[errors addObject:error];
		}
	}//];
	
	if ([errors count] == 0) return YES;
	
	if (outError != NULL) {
		if ([errors count] == 1) *outError = [errors lastObject];
		else *outError = [[NSError alloc] initWithDomain:@"com.moblico.Core.EntityError" code:-1 userInfo:@{ @"MLCValidationDetailedErrorsKey" : errors }];
	}
	
	return NO;
}

@end
