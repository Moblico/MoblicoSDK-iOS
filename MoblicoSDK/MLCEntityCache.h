//
//  MLCEntityCache.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/27/15.
//  Copyright © 2015 Moblico Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLCEntityCache : NSObject

+ (id)retrieveEntityWithKey:(NSString *)key;
+ (BOOL)persistEntity:(id)object key:(NSString *)key;
+ (BOOL)clearEntityWithKey:(NSString *)key;
+ (BOOL)clearCache;
+ (BOOL)entityExistsWithKey:(NSString *)key;

@end
