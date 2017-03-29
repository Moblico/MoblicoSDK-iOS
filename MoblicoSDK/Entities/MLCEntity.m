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
#import "MLCLogger.h"


//#define MLCEntityLog(fmt, ...) MLCInfoLog(fmt, ##__VA_ARGS__);
#define MLCEntityLog(...)

@implementation MLCEntity

+ (MLCValidations *)validations {
    return nil;
}

- (BOOL)validate:(out NSError *__autoreleasing *)outError {
    NSDictionary *properties = self._properties;
    NSMutableArray * errors = [NSMutableArray arrayWithCapacity:properties.count];

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

    if (errors.count == 0) return YES;

    if (outError != NULL) {
        if (errors.count == 1) *outError = errors.firstObject;
        else *outError = [NSError errorWithDomain:MLCValidationErrorDomain code:MLCValidationMultipleErrorsError userInfo:@{ MLCValidationDetailedErrorsKey : errors }];
    }

    return NO;
}

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable __autoreleasing *)outError {

    if (![super validateValue:ioValue forKey:inKey error:outError]) {
        return NO;
    }
    if (self.class.validations == nil) {
        return YES;
    }

    MLCValidationResults *results = [self.class.validations validate:self key:inKey value:ioValue];
    if (outError) {
        *outError = results.firstError;
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

    return [MLCEntity stringFromValue:value];
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
        [properties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull type, BOOL * _Nonnull stop) {

            if ([type characterAtIndex:0] != '@') {
                @try {
                    [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
                } @catch (NSException * __unused exception) {}
            }
        }];
        //        id type = properties[key];

        //        unsigned int propertyCount;
        //        objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
        //        for(unsigned int i = 0; i < propertyCount; i++)
        //            [self addObserver:self
        //                   forKeyPath:[NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding]
        //                      options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    NSDictionary *properties = [self propertiesForClass:[self class]];
    [properties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull type, BOOL * _Nonnull stop) {

        if ([type characterAtIndex:0] != '@') {
            @try {
                [self removeObserver:self forKeyPath:key];
            }
            @catch (NSException *exception) {}
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id value = [super valueForKey:keyPath];//change[NSKeyValueChangeNewKey];
    MLCEntityLog(@"Changed value at key path: %@ change: %@ value: %@", keyPath, change, value);
    NSDictionary *properties = self._properties;
    id type = properties[keyPath];
    //    id value = [super valueForKey:keyPath];//change[NSKeyValueChangeNewKey];
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

+ (NSDate *)dateFromTimeStampValue:(id)value {
    double timestamp = [self doubleFromValue:value];

    if (timestamp) {
        return [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000.0)];
    }

    return nil;
}

+ (NSNumber *)timeStampFromDate:(NSDate *)date {
    if (!date) return nil;
    NSTimeInterval timeInterval = date.timeIntervalSince1970;
    NSNumber *timeStamp = @(timeInterval * 1000.0);

    return @(timeStamp.longLongValue);
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

//+ (instancetype)deserialize:(id)jsonObject {
//    return [[[self class] alloc] initWithJSONObject:jsonObject];
//}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[[self uniqueIdentifierKey]];
}

+ (NSDictionary *)renamedPropertiesDuringSerialization {
    return @{@"details": @"description"};
}

+ (NSDictionary *)serialize:(id<MLCEntityProtocol>)entityObject {
    if (![entityObject isKindOfClass:[MLCEntity class]]) {
        return nil;
    }

    MLCEntity *entity = entityObject;

    NSDictionary *properties = entity._properties;

    NSMutableDictionary *serializedObject = [NSMutableDictionary dictionaryWithCapacity:properties.count];

    NSArray *ignore = [self ignoredPropertiesDuringSerialization];
    NSDictionary *rename = [self renamedPropertiesDuringSerialization];

    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
        MLCEntityLog(@"Key: %@ Type: %@", key, type);
        if ([key isEqualToString:@"properties"] || [key isEqualToString:@"_properties"] || [key isEqualToString:@"debugDescription"] || [key isEqualToString:@"description"]) {
            return;
        }
        if ([ignore containsObject:key]) {
            return;
        }
        id value = [entity valueForKey:key];
        if (!value || value == [NSNull null]) return;

        Class ValueClass = [MLCEntity classFromType:type];
        if ([ValueClass isSubclassOfClass:[MLCEntity class]]) {
            value = [ValueClass serialize:value];
        } else if ([ValueClass isSubclassOfClass:[NSDate class]]) {
            value = [MLCEntity timeStampFromDate:value];
        } else if ([ValueClass isSubclassOfClass:[NSURL class]]) {
            NSURL *url = value;
            value = url.absoluteString;
        } else if ([type characterAtIndex:0] == 'c' || [type characterAtIndex:0] == @encode(BOOL)[0] || [type characterAtIndex:0] == @encode(bool)[0]) {
            MLCEntityLog(@"it's a bool! %@", value);
            value = [MLCEntity boolFromValue:value] ? @"true" : @"false";
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

- (NSDictionary *)propertiesForClass:(Class)cls {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    unsigned int outCount, idx;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);

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

    if ([cls superclass] != [MLCEntity class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[cls superclass]]];
    }

    return [results copy];
}

+ (Class)classFromType:(NSString *)type {
    if ([type characterAtIndex:0] != @encode(id)[0]) return nil;

    NSMutableString *className = [type mutableCopy];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wassign-enum"
    [className replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, className.length)];
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

    //    NSString *firstCapChar = [key substringToIndex:1].capitalizedString;
    //    NSString *capitalizedKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCapChar];

    //    NSString *setterName = [NSString stringWithFormat: @"set%@:", capitalizedKey];
    //    SEL setterSEL = NSSelectorFromString(setterName);

    //	if (![self respondsToSelector:setterSEL]) {
    //        MLCEntityLog(@"%@ Not responding to setter: %@", [self class],  setterName);
    //        return;
    //    }

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

        if ([value isKindOfClass:[MLCEntity class]]) {
            obj = value;
        } else if ([ClassType conformsToProtocol:@protocol(MLCEntityProtocol)]) {
            obj = [[ClassType alloc] initWithJSONObject:value];
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

    //    MLCEntityLog(@"Not Object or Class - key: %@ value: %@ type: %@ value class: %@", key, value, type, [value class]);
#define CASE_SEL(ctype, selectorpart) \
if(typeChar == @encode(ctype)[0]) { \
if ([value isKindOfClass:[NSString class]]) { \
if (((NSString *)value).length == 0) return; \
NSNumberFormatter *f = [[NSNumberFormatter alloc] init]; \
f.numberStyle = NSNumberFormatterDecimalStyle; \
NSNumber *number = [f numberFromString:value]; \
if(number)value=number;\
}\
NSNumber *number = @([MLCEntity selectorpart ## FromValue: value ]); \
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

    //    MLCEntityLog(@"Ok, what? value: %@ key: %@ type: %@", value, key, type);
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
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
        id value = [self valueForKey:key];

        [coder encodeObject:value forKey:key];
    }];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];

    if (self) {
        NSDictionary *properties = self._properties;
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
            id value = [coder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id copyedObject = [[[self class] allocWithZone:zone] init];

    if (copyedObject) {
        NSDictionary *properties = self._properties;
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id type, __unused BOOL *stop) {
            id value = [self valueForKey:key];
            [copyedObject setValue:value forKey:key type:type];
        }];
    }

    return copyedObject;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        //        MLCEntityLog(@"These objects have a different class.");
        return NO;
    }
    NSDictionary *this = [[self class] serialize:self];
    NSDictionary *other = [[self class] serialize:object];
    //    MLCEntityLog(@"this: %@ other: %@", this, other);
    BOOL equal = [this isEqualToDictionary:other];
    //    MLCEntityLog(@"Objects are %@", equal? @"equal": @"not equal");
    return equal;
    //    return [self.uniqueIdentifier isEqual:entity.uniqueIdentifier];
}

- (NSUInteger)hash {
    NSDictionary *this = [[self class] serialize:self];
    return this.description.hash;
}

- (NSString *)setterToGetter:(NSString *)sel {
    if ([sel hasPrefix:@"set"] && [sel hasSuffix:@":"]) {
        NSString *prop = [sel substringWithRange:NSMakeRange(3, sel.length - 4)];
        NSString *firstCharacter = [prop substringToIndex:1].lowercaseString;
        return [prop stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
    }
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    //    MLCEntityLog(@"methodSignatureForSelector: %@", NSStringFromSelector(selector));
    NSMethodSignature *sig = [super methodSignatureForSelector:selector];
    if (!sig) {
        MLCEntityLog(@"Selector Not Found Here!!!! sel: %@", NSStringFromSelector(selector));
    }

    NSString *sel = NSStringFromSelector(selector);
    NSString *setter = [self setterToGetter:sel];
    NSString *type = self._properties[setter ?: sel];
    if (type) {
        MLCEntityLog(@"Selector is in Properties.");
        NSString *format = setter ? @"v@:%@" : @"%@@:";
        NSString *types = [NSString stringWithFormat:format, type];
        MLCEntityLog(@"ObjCTypes: %@", types);
        return [NSMethodSignature signatureWithObjCTypes:[types cStringUsingEncoding:NSUTF8StringEncoding]];
    }

    //    if (setter) {
    //        if (self._properties[setter]) {
    //            NSString *type = self._properties[prop];
    //            NSString *name = [NSString stringWithFormat:@"v@:%@", type];
    //            MLCEntityLog(@"%@ %@", name, type);
    //            sig = [NSMethodSignature signatureWithObjCTypes:[name cStringUsingEncoding:NSUTF8StringEncoding]];
    //        }
    //        MLCEntityLog(@"sig: %@", sig);
    //        return sig;
    //    } else if (self._properties[sel]) {
    //        NSString *type = self._properties[sel];
    //        MLCEntityLog(@"Selector is in Properties.");
    //        NSString *name = [NSString stringWithFormat:@"%@@:", type];
    //
    //        return [NSMethodSignature signatureWithObjCTypes:[name cStringUsingEncoding:NSUTF8StringEncoding]];
    //    }

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

- (NSNumber *)numberWithBytes:(const void *)value objCType:(const char *)type {
    MLCEntityLog(@"intype: %s", type);
#define CASE(ctype, selectorpart) \
if(type[0] == @encode(ctype)[0]) {\
return [NSNumber numberWith ## selectorpart:(ctype)value];}

    CASE(char, Char);
    CASE(unsigned char, UnsignedChar);
    CASE(short, Short);
    CASE(unsigned short, UnsignedShort);
    CASE(int, Int);
    CASE(unsigned int, UnsignedInt);
    CASE(long, Long);
    CASE(unsigned long, UnsignedLong);
    CASE(long long, LongLong);
    CASE(unsigned long long, UnsignedLongLong);
    //    CASE(float, Float);
    //    CASE(double, Double);

#undef CASE

    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    MLCEntityLog(@"forwardInvocation: %@", invocation);
    //    return;
    NSString *key = NSStringFromSelector(invocation.selector);
    MLCEntityLog(@"forwardInvocation: %@ selector: %@", invocation, key);
    NSString *setter = [self setterToGetter:key];
    NSString *type = self._properties[setter ?: key];
    
    if (type) {
        MLCEntityLog(@"getting %@ (%@)", key, type);
        if ([key hasPrefix:@"set"]) {
            MLCEntityLog(@"SETTER!!");
            if ([type isEqualToString:@"@"]) {
                id obj = nil;
                [invocation getArgument:&obj atIndex:2];
                self._undefinedValues[setter] = obj;
            }
            else {
                const char * atype = [invocation.methodSignature getArgumentTypeAtIndex:2];
                NSNumber *value = nil;
                
#define CASE(ctype, selectorpart) \
if(atype[0] == @encode(ctype)[0]) {\
MLCEntityLog(@"Type: %s", @encode(ctype)); \
ctype val = 0; \
[invocation getArgument:&val atIndex:2]; \
value = [NSNumber numberWith ## selectorpart:val];}
                
                CASE(char, Char);
                CASE(unsigned char, UnsignedChar);
                CASE(short, Short);
                CASE(unsigned short, UnsignedShort);
                CASE(int, Int);
                CASE(unsigned int, UnsignedInt);
                CASE(long, Long);
                CASE(unsigned long, UnsignedLong);
                CASE(long long, LongLong);
                CASE(unsigned long long, UnsignedLongLong);
                CASE(float, Float);
                CASE(double, Double);
#undef CASE
                
                //                void* val = NULL;
                //                [invocation getArgument:&val atIndex:2];
                //                id value = [NSValue valueWithPointer:val];
                //                NSNumber *value = [self numberWithBytes:&val objCType:];
                //                MLCEntityLog(@"number: %@", value);
                //                id value = [NSValue valueWithBytes:val objCType:[type cStringUsingEncoding:NSUTF8StringEncoding]];
                //                id value = [NSValue value:&val withObjCType:];
                [self setValue:value forKey:setter type:type];
                //                self._scalarValues[setter] = value;
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
        }
        else if ([obj isKindOfClass:[NSValue class]]) {
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
