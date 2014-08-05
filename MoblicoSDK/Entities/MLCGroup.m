//
//  MLCGroup.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/22/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCEntity_Private.h"
#import "MLCGroup.h"

@implementation MLCGroup

+ (NSDictionary *)renamedPropertiesDuringSerialization {
    NSMutableDictionary *properties = [[super renamedPropertiesDuringSerialization] mutableCopy];
    properties[@"registerable"] = @"isRegisterable";

    return [properties copy];
}

+ (NSDictionary *)renamedPropertiesDuringDeserialization {
    NSMutableDictionary *properties = [[super renamedPropertiesDuringDeserialization] mutableCopy];
    properties[@"isRegisterable"] = @"registerable";
    
    return [properties copy];
}

@end
