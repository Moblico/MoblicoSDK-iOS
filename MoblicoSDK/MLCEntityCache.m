//
//  MLCEntityCache.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/27/15.
//  Copyright © 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCEntityCache.h"

@implementation MLCEntityCache

+ (NSURL *)documentsURL {
    static dispatch_once_t onceToken;
    static NSURL *documentsDirectory = nil;
    dispatch_once(&onceToken, ^{
        NSArray *paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        documentsDirectory = paths.firstObject;
    });

    return documentsDirectory;
}

+ (NSURL *)URL:(NSString *)key {
    NSString *component = [key stringByAppendingPathExtension:@"archive"];
    return [[self documentsURL] URLByAppendingPathComponent:component];
}

+ (BOOL)entityExistsWithKey:(NSString *)key {
    return [NSFileManager.defaultManager fileExistsAtPath:[self URL:key].path];
}

+ (id)retrieveEntityWithKey:(NSString *)key {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self URL:key].path];
}

+ (BOOL)persistEntity:(id)object key:(NSString *)key error:(NSError **)error {
    NSString *path = [self URL:key].path;

    return [NSKeyedArchiver archiveRootObject:object
                                       toFile:path]
    && [NSFileManager.defaultManager setAttributes:@{
                                                     NSFileProtectionKey:
                                                         NSFileProtectionNone
                                                     }
                                      ofItemAtPath:path
                                             error:error];
}

+ (BOOL)clearEntityWithKey:(NSString *)key error:(NSError **)error {
    return [NSFileManager.defaultManager removeItemAtURL:[self URL:key] error:error];
}

+ (BOOL)clearCache:(NSError * __autoreleasing *)error {
    __block BOOL hadError = YES;
    NSArray *contents = [NSFileManager.defaultManager contentsOfDirectoryAtURL:[self documentsURL]
                                                    includingPropertiesForKeys:nil
                                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                         error:error];
    if (!contents) {
        return NO;
    }

    [contents enumerateObjectsWithOptions:NSEnumerationConcurrent
                               usingBlock:^(NSURL *fileURL, __unused NSUInteger idx, BOOL *stop) {
                                   if (![NSFileManager.defaultManager removeItemAtURL:fileURL
                                                                                error:error]) {
                                       *stop = YES;
                                       hadError = YES;
                                   }
                               }];

    return !hadError;
}

@end
