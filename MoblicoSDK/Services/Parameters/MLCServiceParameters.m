//
//  MLCServiceParameter.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/11/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCServiceParameters.h"

@interface MLCServiceParameters ()
@property (nonatomic, strong) NSMutableDictionary *parameters;
@end

@implementation MLCServiceParameters

- (id)valueForKey:(NSString *)key {
    if (key) {
        return self.parameters[key];
    }

    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (!key) {
        return;
    }
    
    if (value) {
        self.parameters[key] = value;
    }
    else {
        [self.parameters removeObjectForKey:key];
    }
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    NSString *stringKey = nil;
    if ([(id)key isKindOfClass:[NSString class]]) {
        stringKey = (NSString *)key;
    }
    else if ([(id)key respondsToSelector:@selector(stringValue)]) {
        stringKey = [(id)key stringValue];
    }
    return [self valueForKey:stringKey];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    NSString *stringKey = nil;
    if ([(id)key isKindOfClass:[NSString class]]) {
        stringKey = (NSString *)key;
    }
    else if ([(id)key respondsToSelector:@selector(stringValue)]) {
        stringKey = [(id)key stringValue];
    }
    [self setValue:obj forKey:stringKey];
}

@end
